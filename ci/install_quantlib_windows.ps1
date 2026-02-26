# Install pre-compiled QuantLib DLL and Boost headers on Windows.
# Called by cibuildwheel via CIBW_BEFORE_ALL_WINDOWS.
#
# Downloads a pre-built QuantLib DLL package from QuantLib-DLL releases
# containing runtime DLL, import library, patched headers, and Boost headers.
#
# Expected zip structure:
#   QuantLib-1.41/
#     bin/QuantLib-x64-mt.dll    (runtime DLL)
#     lib/QuantLib-x64-mt.lib    (import library)
#     include/ql/...             (QuantLib headers, DLL-patched)
#   boost_1_87_0/
#     boost/...                  (Boost headers)

$ErrorActionPreference = "Stop"

$QuantLibVersion = if ($env:QUANTLIB_VERSION) { $env:QUANTLIB_VERSION } else { "1.41" }
$DestDir         = if ($env:QUANTLIB_DEPS_DIR) { $env:QUANTLIB_DEPS_DIR } else { "C:\quantlib-deps" }

$DepUrl = $env:QUANTLIB_DLL_URL
if (-not $DepUrl) {
    $DepUrl = "https://github.com/lifelib-dev/QuantLib-DLL/releases/download/v${QuantLibVersion}/QuantLib-${QuantLibVersion}-x64-dll.zip"
}

New-Item -ItemType Directory -Path $DestDir -Force | Out-Null

# ---------------------------------------------------------------------------
# 1. Download pre-compiled QuantLib DLL package
# ---------------------------------------------------------------------------
Write-Host "==> Downloading pre-compiled QuantLib $QuantLibVersion DLL from $DepUrl"
$ZipPath = "$env:TEMP\quantlib-dll.zip"
Invoke-WebRequest -Uri $DepUrl -OutFile $ZipPath -UseBasicParsing

# ---------------------------------------------------------------------------
# 2. Extract to destination directory
# ---------------------------------------------------------------------------
Write-Host "==> Extracting to $DestDir"
Expand-Archive -Path $ZipPath -DestinationPath $DestDir -Force

# ---------------------------------------------------------------------------
# 3. Verify expected files exist
# ---------------------------------------------------------------------------
$QLInstallDir = "$DestDir\QuantLib-$QuantLibVersion"

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

Write-Host "==> Contents of $QLInstallDir\include\ql (first 10 items)"
if (Test-Path "$QLInstallDir\include\ql") {
    Get-ChildItem "$QLInstallDir\include\ql" | Select-Object -First 10 | Format-Table Name
}

Write-Host "==> QuantLib DLL installation completed successfully"
