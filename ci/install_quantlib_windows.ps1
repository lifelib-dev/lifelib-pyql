# Install pre-built QuantLib for Windows CI.
# Called by cibuildwheel via CIBW_BEFORE_ALL_WINDOWS.
# Downloads a pre-built QuantLib zip from a GitHub Release asset.
#
# Expected zip structure:
#   include/    - QuantLib + Boost headers
#   lib/        - QuantLib-x64-mt.lib (import library)
#   bin/        - QuantLib-x64-mt.dll

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

Write-Host "==> QuantLib dependencies installed successfully"
