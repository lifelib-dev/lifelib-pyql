# make.ps1 - Windows PowerShell equivalent of the Makefile
# Usage: .\make.ps1 <target>
# Targets: build, docs, install, uninstall, tests, clean, help

param(
    [Parameter(Position=0)]
    [string]$Target = "help"
)

function Invoke-Build {
    python setup.py build_ext --inplace -j 8
}

function Invoke-Docs {
    Push-Location docs
    try {
        .\make.bat html
    } finally {
        Pop-Location
    }
}

function Invoke-Install {
    pip install .
}

function Invoke-Uninstall {
    pip uninstall lifelib_pyql
}

function Invoke-Tests {
    Invoke-Build
    if ($LASTEXITCODE -eq 0) {
        python -m unittest discover -v
    }
}

function Invoke-Clean {
    # Remove compiled extensions (.pyd on Windows, .so on Linux)
    Get-ChildItem -Path lifelib_pyql -Recurse -Include *.pyd, *.so -ErrorAction SilentlyContinue |
        Remove-Item -Force
    # Remove compiled Python files
    Get-ChildItem -Path lifelib_pyql -Recurse -Include *.pyc -ErrorAction SilentlyContinue |
        Remove-Item -Force
    # Remove Cython-generated C/C++ and header files
    Get-ChildItem -Path lifelib_pyql -Recurse -Include *.cpp, *.c, *.h -ErrorAction SilentlyContinue |
        Remove-Item -Force
    # Remove template-generated yield curve files
    $yieldFiles = @(
        "piecewise_yield_curve", "discount_curve", "forward_curve", "zero_curve"
    )
    $yieldExts = @(".pxd", ".pyx")
    foreach ($name in $yieldFiles) {
        foreach ($ext in $yieldExts) {
            $path = "lifelib_pyql\termstructures\yields\$name$ext"
            if (Test-Path $path) {
                Remove-Item $path -Force
            }
        }
    }
    # Remove build and dist directories
    if (Test-Path build) { Remove-Item build -Recurse -Force }
    if (Test-Path dist) { Remove-Item dist -Recurse -Force }

    Write-Host "Clean complete."
}

function Show-Help {
    Write-Host "Usage: .\make.ps1 <target>"
    Write-Host ""
    Write-Host "Targets:"
    Write-Host "  build      Build Cython extensions in-place (8 parallel jobs)"
    Write-Host "  docs       Build documentation (requires Sphinx)"
    Write-Host "  install    Install the package via pip"
    Write-Host "  uninstall  Uninstall the package via pip"
    Write-Host "  tests      Build and run all tests"
    Write-Host "  clean      Remove compiled extensions and generated files"
    Write-Host "  help       Show this help message"
}

switch ($Target.ToLower()) {
    "build"     { Invoke-Build }
    "docs"      { Invoke-Docs }
    "install"   { Invoke-Install }
    "uninstall" { Invoke-Uninstall }
    "tests"     { Invoke-Tests }
    "clean"     { Invoke-Clean }
    "help"      { Show-Help }
    default     { Write-Host "Unknown target: $Target"; Show-Help }
}
