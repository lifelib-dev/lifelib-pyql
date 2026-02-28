# Build lifelib-pyql locally against QuantLib DLL.
# Downloads QuantLib dependencies and builds the extensions.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File build_local.ps1
#   powershell -ExecutionPolicy Bypass -File build_local.ps1 -SkipDeps

param(
    [switch]$SkipDeps = $false
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DepsDir = Join-Path $RepoRoot "quantlib-deps"

$QLVersion = if ($env:QUANTLIB_VERSION) { $env:QUANTLIB_VERSION } else { "1.41" }
$BoostVersion = if ($env:BOOST_VERSION) { $env:BOOST_VERSION } else { "1.87.0" }
$BoostVersionU = $BoostVersion -replace '\.', '_'

# ---------------------------------------------------------------------------
# 1. Download and extract QuantLib dependencies
# ---------------------------------------------------------------------------
if (-not $SkipDeps) {
    Write-Host "==> Installing QuantLib dependencies to $DepsDir"
    $env:QUANTLIB_DEPS_DIR = $DepsDir
    & "$RepoRoot\ci\install_quantlib_windows.ps1"
} else {
    Write-Host "==> Skipping QuantLib dependency download (-SkipDeps)"
}

# ---------------------------------------------------------------------------
# 2. Set environment variables for the build
# ---------------------------------------------------------------------------
$env:QUANTLIB_INCLUDE_DIR = "$DepsDir\QuantLib-$QLVersion\include"
$env:BOOST_INCLUDE_DIR    = "$DepsDir\boost_$BoostVersionU"
$env:QUANTLIB_LIBRARY_DIR = "$DepsDir\QuantLib-$QLVersion\lib"
$env:QL_LIBRARY_NAME      = "QuantLib-x64-mt"

Write-Host "==> Building lifelib-pyql"
Write-Host "  QUANTLIB_INCLUDE_DIR = $env:QUANTLIB_INCLUDE_DIR"
Write-Host "  BOOST_INCLUDE_DIR    = $env:BOOST_INCLUDE_DIR"
Write-Host "  QUANTLIB_LIBRARY_DIR = $env:QUANTLIB_LIBRARY_DIR"
Write-Host "  QL_LIBRARY_NAME      = $env:QL_LIBRARY_NAME"

# ---------------------------------------------------------------------------
# 3. Build
# ---------------------------------------------------------------------------
& "$RepoRoot\make.ps1" build
