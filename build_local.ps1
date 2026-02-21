# Build lifelib-pyql locally against QuantLib DLL.
# Run this after ci/install_quantlib_windows.ps1 has installed QuantLib.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File build_local.ps1
#
# Override QUANTLIB_DEPS_DIR if you installed to a custom location:
#   $env:QUANTLIB_DEPS_DIR = "C:\Users\fumito\quantlib-deps"
#   powershell -ExecutionPolicy Bypass -File build_local.ps1

$ErrorActionPreference = "Stop"

$DepsDir = if ($env:QUANTLIB_DEPS_DIR) { $env:QUANTLIB_DEPS_DIR } else { "C:\quantlib-deps" }
$QLVersion = if ($env:QUANTLIB_VERSION) { $env:QUANTLIB_VERSION } else { "1.41" }
$BoostVersion = if ($env:BOOST_VERSION) { $env:BOOST_VERSION } else { "1.87.0" }
$BoostVersionU = $BoostVersion -replace '\.', '_'

$env:QUANTLIB_INCLUDE_DIR = "$DepsDir\QuantLib-$QLVersion\include"
$env:BOOST_INCLUDE_DIR    = "$DepsDir\boost_$BoostVersionU"
$env:QUANTLIB_LIBRARY_DIR = "$DepsDir\QuantLib-$QLVersion\lib"
$env:QL_LIBRARY_NAME      = "QuantLib-x64-mt"

Write-Host "==> Building lifelib-pyql"
Write-Host "  QUANTLIB_INCLUDE_DIR = $env:QUANTLIB_INCLUDE_DIR"
Write-Host "  BOOST_INCLUDE_DIR    = $env:BOOST_INCLUDE_DIR"
Write-Host "  QUANTLIB_LIBRARY_DIR = $env:QUANTLIB_LIBRARY_DIR"
Write-Host "  QL_LIBRARY_NAME      = $env:QL_LIBRARY_NAME"

# python setup.py build_ext --inplace -j 8
./make build
