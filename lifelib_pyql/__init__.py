""" library for quantitative finance"""
import sys
import os

# preload the QuantLib shared libraries bundled in the package
if sys.platform == 'win32':
    import ctypes
    _pkg_dir = os.path.abspath(os.path.dirname(__file__))

    # delvewheel places DLLs in a .libs subdirectory
    _libs_dir = os.path.join(_pkg_dir, '.libs')
    if os.path.isdir(_libs_dir) and hasattr(os, 'add_dll_directory'):
        os.add_dll_directory(_libs_dir)

    # Also support the legacy preload_dlls.txt mechanism (local/dev installs)
    _preload_path = os.path.join(_pkg_dir, "preload_dlls.txt")
    if os.path.isfile(_preload_path):
        try:
            with open(_preload_path) as _f:
                for _dll in _f.read().splitlines():
                    _dll = _dll.strip()
                    if _dll:
                        ctypes.cdll.LoadLibrary(os.path.join(_pkg_dir, _dll))
        except OSError:
            pass

    # Fallback: add package directory to PATH
    if not os.path.isdir(_libs_dir) and not os.path.isfile(_preload_path):
        os.environ["PATH"] = _pkg_dir + ";" + os.environ.get("PATH", "")

elif sys.platform == "linux":
    import ctypes
    sys.setdlopenflags(2 | ctypes.RTLD_GLOBAL)
