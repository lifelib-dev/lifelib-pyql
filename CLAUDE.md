# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

lifelib-pyql is a Cython-based Python binding for the QuantLib C++ library. It replaces SWIG wrappers with a more Pythonic API. The package has been renamed from `quantlib` to `lifelib_pyql`. Requires Python >= 3.10.

## Build & Test Commands

```bash
# Build Cython extensions in-place (8 parallel jobs)
make build
# Or directly:
python setup.py build_ext --inplace -j 8

# Run all tests
make tests
# Or directly:
python -m unittest discover -v

# Run a single test file
python -m unittest test.test_bonds -v

# Run a single test case
python -m unittest test.test_bonds.BondTestCase.test_fixed_rate_bond -v

# Build documentation (requires Sphinx, nbsphinx)
make docs

# Clean compiled extensions and generated files
make clean

# Install / uninstall
make install    # pip install .
make uninstall  # pip uninstall lifelib_pyql
```

## Build Requirements

- **C++ library**: QuantLib 1.41+ with Boost 1.78.0+
- **Python**: >= 3.10
- **Python build deps**: Cython >= 3.0, numpy, setuptools < 74
- **Runtime deps**: tabulate, pandas, six
- **macOS**: `brew install boost quantlib`
- **Windows**: Visual Studio 2022; paths to QuantLib/Boost configurable via env vars (`QUANTLIB_INCLUDE_DIR`, `BOOST_INCLUDE_DIR`, `QUANTLIB_LIBRARY_DIR`, `QL_LIBRARY_NAME`) with defaults in `setup.py`
- **Linux CI**: Uses QuantLib from PPA (`ppa:edd/misc`)

## CI/CD

GitHub Actions workflows in `.github/workflows/`:
- **main.yml** — CI: builds and tests on Ubuntu 24.04 with Python 3.9/3.10/3.11, publishes docs to gh-pages on push
- **build.yml** — Cross-platform wheel builds via cibuildwheel (Python 3.10–3.14)
- **build-static-windows.yml** — Windows static build
- **publish.yml** — Package publishing

cibuildwheel configuration is in `pyproject.toml`. Platform-specific install scripts live in `ci/`.

## Architecture

### Cython Binding Pattern

Each QuantLib C++ class is typically wrapped with three files:
- `_foo.pxd` — C++ declarations (`cdef extern from` blocks wrapping QuantLib headers)
- `foo.pxd` — Cython class declarations (`cdef class` with the C++ shared_ptr)
- `foo.pyx` — Python-facing implementation with docstrings and Pythonic API

### Package Structure (lifelib_pyql/)

| Subpackage | Purpose |
|---|---|
| `cashflows/` | Coupon types (fixed, floating, CMS, inflation, overnight) |
| `currency/` | Currency definitions and registry |
| `experimental/` | CMS spread coupons, cross-currency rate helpers |
| `indexes/` | IBOR (Euribor, LIBOR, SOFR), inflation, swap indices |
| `instruments/` | Bonds, swaps, options, CDS, swaptions |
| `market/` | High-level market conventions and market class |
| `math/` | Arrays, matrices, interpolation, optimization, RNGs |
| `methods/` | Monte Carlo paths/generators, finite difference solvers |
| `mlab/` | Simplified analytical functions (fixed income, options, term structures) |
| `models/` | Short-rate (Hull-White, Vasicek, G2), equity (Heston, Bates) |
| `portfolio/` | Vectorized portfolio operations and schedule generation |
| `pricingengines/` | Analytical, MC, FD, and tree-based pricing engines |
| `processes/` | Stochastic processes (Black-Scholes, Heston, Hull-White, Bates) |
| `quotes/` | Market data quotes (SimpleQuote, FuturesConvAdjustmentQuote) |
| `reference/` | Data structure definitions and names registry |
| `sim/` | Simulation module (requires custom C++ in `cpp_layer/`) |
| `termstructures/` | Yield curves, volatility surfaces, rate helpers |
| `time/` | Dates, calendars, day counters, periods, schedules |
| `util/` | Python utilities (date converter, version, object registry) |
| `utilities/` | Cython-level utilities (null.pxd) |

### Special Build Mechanisms

- **Template rendering**: Yield curve `.pyx`/`.pxd` files in `termstructures/yields/` are generated from `.in` template files at build time (see `render_templates()` in `setup.py`).
- **Custom C++ support code**: Two extensions need files from `cpp_layer/`:
  - `sim.simulate` ← `cpp_layer/simulate_support_code.cpp`
  - `math.hestonhwcorrelationconstraint` ← `cpp_layer/constraint_support_code.cpp`
- **Windows DLL preloading**: `__init__.py` uses a three-tier strategy: (1) delvewheel `.libs/` directory for wheel installs, (2) `preload_dlls.txt` for dev/local installs, (3) PATH fallback.
- **Linux shared lib loading**: `__init__.py` sets `ctypes.RTLD_GLOBAL` for global symbol resolution.

### Key Design Decisions

- QuantLib handles are hidden from users and managed internally via `shared_ptr`
- Observer pattern is used for market data updates (relinkable handles)
- Cython `embedsignature: True` exposes full function signatures in docstrings
- Compiler directive `language_level: '3str'` for Python 3 string semantics

## Testing

Tests use Python's `unittest` framework. Test files are in `test/` (57 modules). Test data fixtures are in `test/data/`. The test suite covers all major instrument types, term structures, models, and pricing engines.
