from setuptools import setup, find_packages, Extension

from distutils import log

import glob
import os
import platform
import sys

from Cython.Distutils import build_ext
from Cython.Build import cythonize
from Cython.Tempita import Template

if sys.platform == 'win32':
    VC_INCLUDE_REDIST = False  # Set to True to include C runtime dlls in distribution.
    ARCH = "x64" if platform.machine().endswith('64') else "x86"

try:
    import numpy
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

DEBUG = False

SUPPORT_CODE_INCLUDE = './cpp_layer'

QL_LIBRARY = 'QuantLib'

# Include/library paths can be overridden via environment variables:
#   QUANTLIB_INCLUDE_DIR, BOOST_INCLUDE_DIR, QUANTLIB_LIBRARY_DIR, QL_LIBRARY_NAME
if sys.platform == 'darwin':
    _ql_inc = os.environ.get('QUANTLIB_INCLUDE_DIR', '/usr/local/include')
    _boost_inc = os.environ.get('BOOST_INCLUDE_DIR', '/usr/local/include')
    _ql_lib = os.environ.get('QUANTLIB_LIBRARY_DIR', '/usr/local/lib')
    INCLUDE_DIRS = [
        _ql_inc, _boost_inc, '.',
        SUPPORT_CODE_INCLUDE
    ]
    LIBRARY_DIRS = [_ql_lib]

elif sys.platform == 'win32':
    QL_LIBRARY = os.environ.get(
        'QL_LIBRARY_NAME', 'QuantLib-%s-mt' % (ARCH,))

    _ql_inc = os.environ.get(
        'QUANTLIB_INCLUDE_DIR', r'c:\Users\fumito\QuantLib-1.41')
    _boost_inc = os.environ.get(
        'BOOST_INCLUDE_DIR', r'c:\Users\fumito\boost_1_78_0')
    _ql_lib = os.environ.get(
        'QUANTLIB_LIBRARY_DIR', r'c:\Users\fumito\QuantLib-1.41\lib')

    INCLUDE_DIRS = [
        _ql_inc,
        _boost_inc,
        '.',
        SUPPORT_CODE_INCLUDE
    ]
    LIBRARY_DIRS = [
        _ql_lib,
        '.',
        r'.\dll',
    ]
elif sys.platform.startswith('linux'):
    _ql_inc = os.environ.get('QUANTLIB_INCLUDE_DIR', '/usr/local/include')
    _boost_inc = os.environ.get('BOOST_INCLUDE_DIR', '/usr/include')
    _ql_lib = os.environ.get('QUANTLIB_LIBRARY_DIR', '/usr/local/lib')
    INCLUDE_DIRS = [_ql_inc, _boost_inc, '/usr/include', '.', SUPPORT_CODE_INCLUDE]
    LIBRARY_DIRS = [_ql_lib, '/usr/lib']

if HAS_NUMPY:
    INCLUDE_DIRS.append(numpy.get_include())


def get_define_macros():
    #defines = [ ('HAVE_CONFIG_H', None)]
    defines = []
    if sys.platform == 'win32':
        # based on the SWIG wrappers
        defines += [
            (name, None) for name in [
                '__WIN32__', 'WIN32', 'NDEBUG', '_WINDOWS', 'NOMINMAX', 'WINNT',
                '_WINDLL', '_SCL_SECURE_NO_DEPRECATE', '_CRT_SECURE_NO_DEPRECATE',
                '_SCL_SECURE_NO_WARNINGS'
            ]
        ]
    return defines


def get_extra_compile_args():
    if sys.platform == 'win32':
        args = ['/GR', '/FD', '/Zm250', '/EHsc', '/std:c++latest', '/FS']
        if DEBUG:
            args.append('/Z7')
    else:
        args = ["-flto=auto"]

    return args


def get_extra_link_args():
    if sys.platform == 'win32':
        args = ['/subsystem:windows', '/machine:%s' % ("X64" if ARCH == "x64" else "I386")]
        if DEBUG:
            args.append('/DEBUG')
    elif sys.platform == 'darwin':
        args = []  # Default libc++ is correct on modern macOS
    else:
        args = ['-Wl,--strip-all']

    return args

CYTHON_DIRECTIVES = {"embedsignature": True,
                     "language_level": '3str',
                     "auto_pickle": False}

def render_templates():
    for basename in ["piecewise_yield_curve", "discount_curve", "forward_curve", "zero_curve"]:
        for ext in ("pxd", "pyx"):
            fname = f"lifelib_pyql/termstructures/yields/{basename}.{ext}.in"
            output = fname[:-3]
            if not os.path.exists(output) or (os.stat(output).st_mtime < os.stat(fname).st_mtime):
                template = Template.from_filename(fname, encoding="utf-8")
                with open(output, "wt") as f:
                    f.write(template.substitute())

def collect_extensions():
    """ Collect all the directories with Cython extensions and return the list
    of Extension.

    Th function combines static Extension declaration and calls to cythonize
    to build the list of extensions.
    """

    kwargs = {
        'language':'c++',
        'include_dirs':INCLUDE_DIRS,
        'library_dirs':LIBRARY_DIRS,
        'define_macros':get_define_macros(),
        'extra_compile_args':get_extra_compile_args(),
        'extra_link_args':get_extra_link_args(),
        'libraries':[QL_LIBRARY]
    }

    multipath_extension = Extension(
        name='lifelib_pyql.sim.simulate',
        sources=[
            'lifelib_pyql/sim/simulate.pyx',
            'cpp_layer/simulate_support_code.cpp'
        ],
        **kwargs
    )

    hestonhw_constraint_extension = Extension(
        name='lifelib_pyql.math.hestonhwcorrelationconstraint',
        sources=[
            'lifelib_pyql/math/hestonhwcorrelationconstraint.pyx',
            'cpp_layer/constraint_support_code.cpp'
        ],
        **kwargs
    )

    manual_extensions = [
        multipath_extension,
        hestonhw_constraint_extension,
    ]

    # remove  all the manual extensions from the collected ones
    if not HAS_NUMPY:
        # remove the multipath extension from the list
        manual_extensions = manual_extensions[1:]
        print('Numpy is not available, multipath extension not compiled')

    render_templates()

    collected_extensions = cythonize(
            manual_extensions +
            [Extension('*', ['**/*.pyx'], **kwargs)],
            compiler_directives=CYTHON_DIRECTIVES, nthreads = 4)

    return collected_extensions

class pyql_build_ext(build_ext):
    """
    Custom build command for lifelib_pyql that on Windows copies the quantlib dll
    and optionally c runtime dlls to the lifelib_pyql package.
    """
    def build_extensions(self):
        build_ext.build_extensions(self)

    def run(self):
        build_ext.run(self)

        # When building under cibuildwheel, skip DLL bundling --
        # delvewheel/auditwheel/delocate handle it instead.
        if os.environ.get('CIBUILDWHEEL'):
            return

        # Find the quantlib dll and copy it to the built package
        if sys.platform == "win32":
            dlls = []

            for libdir in LIBRARY_DIRS:
                if os.path.exists(os.path.join(libdir, QL_LIBRARY + ".dll")):
                    dlls.append(os.path.join(libdir, QL_LIBRARY + ".dll"))
                    break
            else:
                log.warn("%s.dll not found in %s", QL_LIBRARY, LIBRARY_DIRS)

            if dlls:
                # For inplace builds, copy to the package source dir;
                # otherwise copy to the build_lib staging directory.
                if self.inplace:
                    dest_dir = os.path.join(os.path.dirname(__file__), "lifelib_pyql")
                else:
                    dest_dir = os.path.join(self.build_lib, "lifelib_pyql")
                os.makedirs(dest_dir, exist_ok=True)

                for dll in dlls:
                    self.copy_file(dll, os.path.join(dest_dir, os.path.basename(dll)))

                # Write the list of dlls to be pre-loaded
                filename = os.path.join(dest_dir, "preload_dlls.txt")
                log.info("writing preload dlls list to %s", filename)
                if not self.dry_run:
                    with open(filename, "wt") as fh:
                        fh.write("\n".join(map(os.path.basename, dlls)))

if __name__ == '__main__':
    setup(
        name = 'lifelib-pyql',
        version = '0.0.1',
        author = 'Didrik Pinte,Patrick Henaff',
        license = 'BSD',
        packages = find_packages(),
        include_package_data = True,
        ext_modules = collect_extensions(),
        setup_requires=['cython'],
        cmdclass = {'build_ext': pyql_build_ext},
        install_requires = ['tabulate', 'pandas', 'six'],
        zip_safe = False
    )
