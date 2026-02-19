# Build QuantLib as a shared library (DLL) on Windows.
# Called by cibuildwheel via CIBW_BEFORE_ALL_WINDOWS.
#
# Builds QuantLib from source with -DBUILD_SHARED_LIBS=ON after patching
# cmake/Platform.cmake to remove the MSVC DLL build block.
#
# Requires: CMake, Visual Studio 2022 (C++ workload), Boost headers.

$ErrorActionPreference = "Stop"

$QuantLibVersion = if ($env:QUANTLIB_VERSION) { $env:QUANTLIB_VERSION } else { "1.41" }
$BoostVersion    = if ($env:BOOST_VERSION)    { $env:BOOST_VERSION }    else { "1.87.0" }
$BoostVersionU   = $BoostVersion -replace '\.', '_'
$DestDir         = "C:\quantlib-deps"
$BuildJobs       = if ($env:BUILD_JOBS)       { $env:BUILD_JOBS }       else { (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors }

# ---------------------------------------------------------------------------
# 1. Download and extract Boost headers
# ---------------------------------------------------------------------------
Write-Host "==> Downloading Boost $BoostVersion headers"
$BoostUrl  = "https://archives.boost.io/release/$BoostVersion/source/boost_${BoostVersionU}.zip"
$BoostZip  = "$env:TEMP\boost.zip"
Invoke-WebRequest -Uri $BoostUrl -OutFile $BoostZip -UseBasicParsing

Write-Host "==> Extracting Boost headers to $DestDir"
Expand-Archive -Path $BoostZip -DestinationPath $DestDir -Force

$BoostDir = "$DestDir\boost_$BoostVersionU"
Write-Host "==> Boost headers at $BoostDir"

# ---------------------------------------------------------------------------
# 2. Download and extract QuantLib source
# ---------------------------------------------------------------------------
Write-Host "==> Downloading QuantLib $QuantLibVersion source"
$QLUrl = "https://github.com/lballabio/QuantLib/releases/download/v${QuantLibVersion}/QuantLib-${QuantLibVersion}.tar.gz"
$QLTarGz = "$env:TEMP\QuantLib.tar.gz"
Invoke-WebRequest -Uri $QLUrl -OutFile $QLTarGz -UseBasicParsing

Write-Host "==> Extracting QuantLib source"
# tar is available on windows-2022 runners
tar xzf $QLTarGz -C $env:TEMP

$QLSrcDir = "$env:TEMP\QuantLib-$QuantLibVersion"

# ---------------------------------------------------------------------------
# 3. Patch Platform.cmake to allow DLL builds on MSVC
# ---------------------------------------------------------------------------
Write-Host "==> Patching cmake/Platform.cmake to enable DLL builds"
$PlatformCmake = "$QLSrcDir\cmake\Platform.cmake"
$content = Get-Content $PlatformCmake -Raw
$content = $content -replace 'message\(FATAL_ERROR\s*\r?\n\s*"Shared library \(DLL\) builds for QuantLib on MSVC are not supported"\)', `
    '# Patched: DLL build enabled (FATAL_ERROR removed by lifelib-pyql CI)'
Set-Content $PlatformCmake -Value $content -NoNewline

Write-Host "==> Patched Platform.cmake:"
Select-String -Path $PlatformCmake -Pattern "Patched|EXPORT_ALL"

# ---------------------------------------------------------------------------
# 4. Build QuantLib as shared library (DLL)
# ---------------------------------------------------------------------------
$QLInstallDir = "$DestDir\QuantLib-$QuantLibVersion"

Write-Host "==> Configuring QuantLib (shared library build)"
cmake -S $QLSrcDir -B "$QLSrcDir\build" `
    -G "Visual Studio 17 2022" -A x64 `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_INSTALL_PREFIX=$QLInstallDir `
    -DBUILD_SHARED_LIBS=ON `
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON `
    -DBOOST_ROOT=$BoostDir `
    -DQL_BUILD_BENCHMARK=OFF `
    -DQL_BUILD_EXAMPLES=OFF `
    -DQL_BUILD_TEST_SUITE=OFF

Write-Host "==> Building QuantLib ($BuildJobs parallel jobs)"
cmake --build "$QLSrcDir\build" --config Release --parallel $BuildJobs

Write-Host "==> Installing QuantLib to $QLInstallDir"
cmake --install "$QLSrcDir\build" --config Release

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
