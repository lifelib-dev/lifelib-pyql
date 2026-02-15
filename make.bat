@echo off
REM make.bat - Windows batch file equivalent of the Makefile
REM Usage: make <target>
REM Targets: build, docs, install, uninstall, tests, clean, help

if "%1"=="" goto help
goto %1

:build
python setup.py build_ext --inplace -j 8
goto end

:docs
pushd docs
call make.bat html
popd
goto end

:install
pip install .
goto end

:uninstall
pip uninstall lifelib_pyql
goto end

:tests
call :build
if errorlevel 1 goto end
python -m unittest discover -v
goto end

:clean
REM Remove compiled extensions (.pyd on Windows, .so on Linux)
for /r lifelib_pyql %%f in (*.pyd *.so) do del /q "%%f" 2>nul
REM Remove compiled Python files
for /r lifelib_pyql %%f in (*.pyc) do del /q "%%f" 2>nul
REM Remove Cython-generated C/C++ and header files
for /r lifelib_pyql %%f in (*.cpp *.c *.h) do del /q "%%f" 2>nul
REM Remove template-generated yield curve files
for %%n in (piecewise_yield_curve discount_curve forward_curve zero_curve) do (
    for %%e in (.pxd .pyx) do (
        if exist "lifelib_pyql\termstructures\yields\%%n%%e" del /q "lifelib_pyql\termstructures\yields\%%n%%e"
    )
)
REM Remove build and dist directories
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
echo Clean complete.
goto end

:help
echo Usage: make ^<target^>
echo.
echo Targets:
echo   build      Build Cython extensions in-place (8 parallel jobs)
echo   docs       Build documentation (requires Sphinx)
echo   install    Install the package via pip
echo   uninstall  Uninstall the package via pip
echo   tests      Build and run all tests
echo   clean      Remove compiled extensions and generated files
echo   help       Show this help message
goto end

:end
