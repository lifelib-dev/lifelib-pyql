# Install pre-built QuantLib (static library) for Windows CI.
# Called by cibuildwheel via CIBW_BEFORE_ALL_WINDOWS.
# Downloads a pre-built QuantLib zip from a GitHub Release asset.
#
# This is the static-linking alternative to install_quantlib_windows.ps1
# (which builds QuantLib as a DLL from source).
#
# Expected zip structure (mirrors local dev directories):
#   QuantLib-1.41/      - QuantLib headers + lib/ + bin/
#   boost_1_78_0/       - Boost headers

$ErrorActionPreference = "Stop"

$DepUrl = $env:QUANTLIB_DEPS_URL
if (-not $DepUrl) {
    $DepUrl = "https://github.com/lifelib-dev/lifelib-pyql/releases/download/quantlib-deps/quantlib-1.41-win64.zip"
}
$DestDir = "C:\quantlib-deps"

Write-Host "==> Downloading QuantLib pre-built binaries from $DepUrl"
$ZipPath = "$env:TEMP\quantlib-deps.zip"
Invoke-WebRequest -Uri $DepUrl -OutFile $ZipPath -UseBasicParsing

Write-Host "==> Extracting to $DestDir"
Expand-Archive -Path $ZipPath -DestinationPath $DestDir -Force

Write-Host "==> Contents of $DestDir"
Get-ChildItem -Recurse $DestDir | Select-Object FullName

Write-Host "==> QuantLib static dependencies installed successfully"
