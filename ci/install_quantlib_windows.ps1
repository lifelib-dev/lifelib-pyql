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
$DestDir         = "C:\quantlib-deps"
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
Set-Content $PlatformCmake -Value $patched -NoNewline

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
    Set-Content $qlCmake -Value $qlContent -NoNewline
    Write-Host "==> Patched: added RUNTIME DESTINATION"
} else {
    Write-Warning "ql/CMakeLists.txt install() patch target not found"
}

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

Write-Host "==> Building QuantLib with $BuildJobs parallel jobs"
cmake --build $QLBuildDir --config Release --parallel $BuildJobs
if ($LASTEXITCODE -ne 0) { throw "CMake build failed with exit code $LASTEXITCODE" }

# ---------------------------------------------------------------------------
# 4b. Generate supplementary .def file for unexported data symbols.
#     CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS misses static const data members.
#     We scan the built .obj files with dumpbin, find SECT/External symbols
#     of type "const" that are not already in the auto-generated .def, and
#     append them with DATA annotation.
# ---------------------------------------------------------------------------
Write-Host "==> Generating supplementary .def for static const data symbols"

# Locate dumpbin.exe from VS2022 installation
$dumpbin = Get-ChildItem -Recurse "C:\Program Files\Microsoft Visual Studio\2022" `
    -Filter "dumpbin.exe" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match 'Hostx64\\x64' } |
    Select-Object -First 1
if (-not $dumpbin) {
    # Fallback: search via vswhere
    $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
        -latest -property installationPath 2>$null
    if ($vsPath) {
        $dumpbin = Get-ChildItem -Recurse $vsPath -Filter "dumpbin.exe" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match 'Hostx64\\x64' } |
            Select-Object -First 1
    }
}
if ($dumpbin) {
    Write-Host "==> Found dumpbin at $($dumpbin.FullName)"
} else {
    Write-Warning "dumpbin.exe not found - skipping data symbol export"
}

$autoDefFile = Get-ChildItem -Recurse $QLBuildDir -Filter "ql_library.dir" |
    ForEach-Object { Get-ChildItem -Recurse $_.FullName -Filter "*.def" } |
    Select-Object -First 1
$objDir = Get-ChildItem -Recurse $QLBuildDir -Filter "ql_library.dir" |
    Select-Object -First 1

if ($objDir -and $dumpbin) {
    # Get all EXTERNAL symbols from object files that are in a SECT (defined)
    $objFiles = Get-ChildItem -Recurse $objDir.FullName -Filter "*.obj"
    $allSymbols = @()
    foreach ($obj in $objFiles) {
        $dump = & $dumpbin.FullName /SYMBOLS $obj.FullName 2>$null
        # Lines like: "00A SECT5  notype       External     | ?a1_@InverseCumulativeNormal@QuantLib@@0NB"
        # Const data: decorated name ends with @0NB (static const double)
        foreach ($line in $dump) {
            if ($line -match 'SECT\S+\s+notype\s+External\s+\|\s+(\S+)') {
                $sym = $Matches[1]
                # Static const data members have @0NB or @0NA suffix in MSVC mangling
                if ($sym -match '@0N[AB]$') {
                    $allSymbols += $sym
                }
            }
        }
    }
    $allSymbols = $allSymbols | Sort-Object -Unique

    if ($allSymbols.Count -gt 0) {
        # Read the auto-generated .def to see what's already exported
        $alreadyExported = @{}
        if ($autoDefFile) {
            foreach ($line in Get-Content $autoDefFile.FullName) {
                $trimmed = $line.Trim()
                if ($trimmed -and -not $trimmed.StartsWith('EXPORTS') -and -not $trimmed.StartsWith('LIBRARY')) {
                    $alreadyExported[$trimmed -replace '\s+DATA$',''] = $true
                }
            }
        }

        $missing = $allSymbols | Where-Object { -not $alreadyExported.ContainsKey($_) }
        Write-Host "==> Found $($allSymbols.Count) const data symbols, $($missing.Count) not in auto .def"

        if ($missing.Count -gt 0) {
            # Append to auto-generated .def, or create a new one and add to linker flags
            if ($autoDefFile) {
                $defPath = $autoDefFile.FullName
                $missing | ForEach-Object { Add-Content $defPath "    $_ DATA" }
                Write-Host "==> Appended $($missing.Count) DATA exports to $defPath"
            } else {
                # Create supplementary .def and inject via CMAKE_SHARED_LINKER_FLAGS
                $defPath = "$QLBuildDir\quantlib_extra_exports.def"
                "EXPORTS" | Set-Content $defPath
                $missing | ForEach-Object { Add-Content $defPath "    $_ DATA" }
                Write-Host "==> Created supplementary .def at $defPath with $($missing.Count) symbols"

                # Reconfigure with the extra .def
                cmake $QLBuildDir "-DCMAKE_SHARED_LINKER_FLAGS=/DEF:$defPath"
            }

            # Rebuild to pick up the new exports
            Write-Host "==> Rebuilding QuantLib with supplementary exports"
            cmake --build $QLBuildDir --config Release --parallel $BuildJobs
            if ($LASTEXITCODE -ne 0) { throw "CMake rebuild with .def failed" }
        }
    } else {
        Write-Host "==> No const data symbols found (this is unexpected)"
    }
} else {
    Write-Warning "Could not find ql_library.dir - skipping data symbol export"
}

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
