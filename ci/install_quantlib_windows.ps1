# Build QuantLib as a shared library (DLL) on Windows.
# Called by cibuildwheel via CIBW_BEFORE_ALL_WINDOWS.
#
# Builds QuantLib from source with -DBUILD_SHARED_LIBS=ON after patching
# cmake/Platform.cmake to remove the MSVC DLL build block.
#
# Requires: CMake, Visual Studio 2022 (C++ workload), 7z.

$ErrorActionPreference = "Stop"

$QuantLibVersion = if ($env:QUANTLIB_VERSION) { $env:QUANTLIB_VERSION } else { "1.41" }
$BoostVersion    = if ($env:BOOST_VERSION)    { $env:BOOST_VERSION }    else { "1.87.0" }
$BoostVersionU   = $BoostVersion -replace '\.', '_'
$DestDir         = if ($env:QUANTLIB_DEPS_DIR) { $env:QUANTLIB_DEPS_DIR } else { "C:\quantlib-deps" }
$BuildJobs       = if ($env:BUILD_JOBS) { $env:BUILD_JOBS } else {
    (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors
}

New-Item -ItemType Directory -Path $DestDir -Force | Out-Null

# ---------------------------------------------------------------------------
# 1. Download and extract Boost headers (7z is much smaller/faster than zip)
# ---------------------------------------------------------------------------
Write-Host "==> Downloading Boost $BoostVersion (7z archive)"
$BoostUrl = "https://archives.boost.io/release/$BoostVersion/source/boost_${BoostVersionU}.7z"
$Boost7z  = "$env:TEMP\boost.7z"
Invoke-WebRequest -Uri $BoostUrl -OutFile $Boost7z -UseBasicParsing

Write-Host "==> Extracting Boost headers to $DestDir"
7z x $Boost7z -o"$DestDir" -y | Select-String -Pattern "^(Extracting|Everything)" | Write-Host
if ($LASTEXITCODE -ne 0) { throw "7z extraction failed with exit code $LASTEXITCODE" }

$BoostIncludeDir = "$DestDir\boost_$BoostVersionU"
Write-Host "==> Boost headers at $BoostIncludeDir"

# ---------------------------------------------------------------------------
# 2. Download and extract QuantLib source
# ---------------------------------------------------------------------------
Write-Host "==> Downloading QuantLib $QuantLibVersion source"
$QLUrl   = "https://github.com/lballabio/QuantLib/releases/download/v${QuantLibVersion}/QuantLib-${QuantLibVersion}.tar.gz"
$QLTarGz = "$env:TEMP\QuantLib.tar.gz"
Invoke-WebRequest -Uri $QLUrl -OutFile $QLTarGz -UseBasicParsing

Write-Host "==> Extracting QuantLib source"
tar xzf $QLTarGz -C $env:TEMP
if ($LASTEXITCODE -ne 0) { throw "tar extraction failed with exit code $LASTEXITCODE" }

$QLSrcDir = "$env:TEMP\QuantLib-$QuantLibVersion"

# ---------------------------------------------------------------------------
# 3. Patch Platform.cmake to allow DLL builds on MSVC
# ---------------------------------------------------------------------------
Write-Host "==> Patching cmake/Platform.cmake to enable DLL builds"
$PlatformCmake = "$QLSrcDir\cmake\Platform.cmake"
$original = Get-Content $PlatformCmake -Raw
$patched = $original -replace `
    'message\(FATAL_ERROR\s*\r?\n\s*"Shared library \(DLL\) builds for QuantLib on MSVC are not supported"\)', `
    '# Patched: DLL build enabled (FATAL_ERROR removed by lifelib-pyql CI)'
if ($patched -eq $original) {
    Write-Warning "Platform.cmake patch pattern did not match - file may have changed"
    Write-Host "==> Dumping relevant section for debugging:"
    Select-String -Path $PlatformCmake -Pattern "FATAL_ERROR|BUILD_SHARED|EXPORT_ALL" | Write-Host
}
[System.IO.File]::WriteAllText($PlatformCmake, $patched)

Write-Host "==> Patched Platform.cmake:"
Select-String -Path $PlatformCmake -Pattern "Patched|EXPORT_ALL" | Write-Host

# Also patch ql/CMakeLists.txt to add RUNTIME DESTINATION for DLL install.
# The upstream install() only has ARCHIVE and LIBRARY destinations, so the
# DLL (which is RUNTIME on Windows) is not installed by cmake --install.
Write-Host "==> Patching ql/CMakeLists.txt to add RUNTIME DESTINATION"
$qlCmake = "$QLSrcDir\ql\CMakeLists.txt"
$qlContent = Get-Content $qlCmake -Raw
$searchStr = 'LIBRARY DESTINATION ${QL_INSTALL_LIBDIR})'
$replaceStr = 'LIBRARY DESTINATION ${QL_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${QL_INSTALL_BINDIR})'
if ($qlContent.Contains($searchStr)) {
    $qlContent = $qlContent.Replace($searchStr, $replaceStr)
    [System.IO.File]::WriteAllText($qlCmake, $qlContent)
    Write-Host "==> Patched: added RUNTIME DESTINATION"
} else {
    Write-Warning "ql/CMakeLists.txt install() patch target not found"
}

# ---------------------------------------------------------------------------
# 3b. Patch QuantLib headers to export static const data members.
#     CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS does not export static const class
#     data members. We inject a QL_EXPORT macro and apply it to classes
#     that have static const members referenced by inline functions.
# ---------------------------------------------------------------------------
Write-Host "==> Patching QuantLib headers for DLL data symbol export"

# Add QL_EXPORT macro to qldefines.hpp.cfg (the CMake template).
# CMake's configure_file() generates qldefines.hpp in the build directory
# from this .cfg template, so we must patch the template, not the output.
$qlDefinesCfg = "$QLSrcDir\ql\qldefines.hpp.cfg"
$defContent = Get-Content $qlDefinesCfg -Raw
$exportMacro = @'

// DLL export/import macros for classes with static data members.
// QL_EXPORT: dllexport when building QuantLib, dllimport when consuming.
//   Use on classes whose static const members are NOT exported by
//   CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS (e.g. private static const).
// QL_IMPORT_ONLY: empty when building QuantLib, dllimport when consuming.
//   Use on classes whose members ARE already exported via .def file;
//   class-level dllexport would conflict (C2487).
#if defined(QL_COMPILATION) && defined(_MSC_VER)
#  define QL_EXPORT __declspec(dllexport)
#  define QL_IMPORT_ONLY
#elif defined(_MSC_VER)
#  define QL_EXPORT __declspec(dllimport)
#  define QL_IMPORT_ONLY __declspec(dllimport)
#else
#  define QL_EXPORT
#  define QL_IMPORT_ONLY
#endif
'@
if (-not $defContent.Contains('QL_EXPORT')) {
    # Insert before the final #endif (the include guard).
    $lastEndif = $defContent.LastIndexOf('#endif')
    if ($lastEndif -ge 0) {
        $before = $defContent.Substring(0, $lastEndif)
        $after  = $defContent.Substring($lastEndif)
        $defContent = $before + $exportMacro + "`n`n" + $after
    }
    [System.IO.File]::WriteAllText($qlDefinesCfg, $defContent)
    Write-Host "==> Added QL_EXPORT macro to qldefines.hpp.cfg"
    Write-Host "==> Last 20 lines of patched qldefines.hpp.cfg:"
    Get-Content $qlDefinesCfg -Tail 20 | ForEach-Object { Write-Host "  $_" }
}

# Apply QL_EXPORT to classes with static const data members
$normalDistHeader = "$QLSrcDir\ql\math\distributions\normaldistribution.hpp"
$ndContent = Get-Content $normalDistHeader -Raw
$ndContent = $ndContent.Replace(
    'class InverseCumulativeNormal {',
    'class QL_EXPORT InverseCumulativeNormal {')
$ndContent = $ndContent.Replace(
    'class MoroInverseCumulativeNormal {',
    'class QL_EXPORT MoroInverseCumulativeNormal {')
[System.IO.File]::WriteAllText($normalDistHeader, $ndContent)
Write-Host "==> Patched normaldistribution.hpp with QL_EXPORT"

# Patch LinearTsrPricer: annotate individual static const members with QL_EXPORT.
# Class-level __declspec causes C2487, but member-level works fine.
# These are private static const members that CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS skips.
$linearTsrHeader = "$QLSrcDir\ql\cashflows\lineartsrpricer.hpp"
$ltContent = Get-Content $linearTsrHeader -Raw
# Replace the comma-separated declaration with two QL_EXPORT declarations.
# Use regex to handle both LF and CRLF line endings.
$ltContent = $ltContent -replace `
    'static const Real defaultLowerBound,\s+defaultUpperBound;', `
    'QL_EXPORT static const Real defaultLowerBound; QL_EXPORT static const Real defaultUpperBound;'
[System.IO.File]::WriteAllText($linearTsrHeader, $ltContent)
Write-Host "==> Patched lineartsrpricer.hpp: QL_EXPORT on static const members"

Write-Host "==> Verifying QL_EXPORT define in qldefines.hpp.cfg:"
Select-String -Path $qlDefinesCfg -Pattern "QL_EXPORT" | ForEach-Object { Write-Host "  $_" }

# ---------------------------------------------------------------------------
# 4. Build QuantLib as shared library (DLL)
# ---------------------------------------------------------------------------
$QLInstallDir = "$DestDir\QuantLib-$QuantLibVersion"
$QLBuildDir   = "$QLSrcDir\build"

Write-Host "==> Configuring QuantLib (shared library build)"
$cmakeArgs = @(
    "-S", $QLSrcDir
    "-B", $QLBuildDir
    "-G", "Visual Studio 17 2022"
    "-A", "x64"
    "-DCMAKE_INSTALL_PREFIX=$QLInstallDir"
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON"
    '-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$<$<CONFIG:Debug>:Debug>DLL'
    "-DBoost_INCLUDE_DIR=$BoostIncludeDir"
    "-DQL_BUILD_BENCHMARK=OFF"
    "-DQL_BUILD_EXAMPLES=OFF"
    "-DQL_BUILD_TEST_SUITE=OFF"
    "-Wno-dev"
)
Write-Host "  cmake $($cmakeArgs -join ' ')"
cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) { throw "CMake configure failed with exit code $LASTEXITCODE" }

# Verify the generated qldefines.hpp contains QL_EXPORT
$generatedDefines = "${QLBuildDir}\ql\qldefines.hpp"
if (Test-Path $generatedDefines) {
    Write-Host "==> Verifying QL_EXPORT in generated ${generatedDefines}:"
    Select-String -Path $generatedDefines -Pattern "QL_EXPORT" | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Warning "Generated qldefines.hpp not found at ${generatedDefines}"
}

Write-Host "==> Building QuantLib with $BuildJobs parallel jobs"
cmake --build $QLBuildDir --config Release --parallel $BuildJobs
if ($LASTEXITCODE -ne 0) { throw "CMake build failed with exit code $LASTEXITCODE" }

Write-Host "==> Installing QuantLib to $QLInstallDir"
cmake --install $QLBuildDir --config Release
if ($LASTEXITCODE -ne 0) { throw "CMake install failed with exit code $LASTEXITCODE" }

# ---------------------------------------------------------------------------
# 5. Verify the DLL was produced
# ---------------------------------------------------------------------------
Write-Host "==> Checking for QuantLib DLL"
$DllPath = Get-ChildItem -Recurse $QLInstallDir -Filter "QuantLib*.dll" | Select-Object -First 1
if (-not $DllPath) {
    Write-Error "QuantLib DLL not found under $QLInstallDir!"
    exit 1
}
Write-Host "==> Found DLL: $($DllPath.FullName)"

Write-Host "==> Contents of $QLInstallDir\lib"
Get-ChildItem "$QLInstallDir\lib" | Format-Table Name, Length

Write-Host "==> Contents of $QLInstallDir\bin"
if (Test-Path "$QLInstallDir\bin") {
    Get-ChildItem "$QLInstallDir\bin" | Format-Table Name, Length
}

Write-Host "==> QuantLib DLL build completed successfully"
