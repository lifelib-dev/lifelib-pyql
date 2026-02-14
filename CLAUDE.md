# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

lifelib-pyql is a Cython-based Python binding for the QuantLib C++ library. It replaces SWIG wrappers with a more Pythonic API. The package is being renamed from `quantlib` to `lifelib_pyql` (rename in progress on the `main` branch).

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
```

## Build Requirements

- **C++ library**: QuantLib 1.41+ with Boost 1.78.0+
- **Python build deps**: Cython >= 3.0, numpy, setuptools < 74
- **Runtime deps**: tabulate, pandas, six
- **Windows**: Visual Studio 2022; paths to QuantLib/Boost are hardcoded in `setup.py` (look for `c:\Users\fumito\`)
- **Linux CI**: Uses QuantLib from PPA (`ppa:edd/misc`)

## Architecture

### Cython Binding Pattern

Each QuantLib C++ class is typically wrapped with three files:
- `_foo.pxd` — C++ declarations (`cdef extern from` blocks wrapping QuantLib headers)
- `foo.pxd` — Cython class declarations (`cdef class` with the C++ shared_ptr)
- `foo.pyx` — Python-facing implementation with docstrings and Pythonic API

### Package Structure (lifelib_pyql/)

| Subpackage | Purpose |
|---|---|
| `time/` | Dates, calendars, day counters, periods, schedules |
| `termstructures/` | Yield curves, volatility surfaces, rate helpers |
| `instruments/` | Bonds, swaps, options, CDS, swaptions |
| `pricingengines/` | Analytical, MC, FD, and tree-based pricing engines |
| `models/` | Short-rate (Hull-White, Vasicek, G2), equity (Heston, Bates) |
| `indexes/` | IBOR (Euribor, LIBOR, SOFR), inflation, swap indices |
| `cashflows/` | Coupon types (fixed, floating, CMS, inflation, overnight) |
| `math/` | Arrays, matrices, interpolation, optimization, RNGs |
| `methods/` | Monte Carlo paths/generators, finite difference solvers |
| `market/` | High-level market conventions and market class |
| `mlab/` | Simplified analytical functions (fixed income, options, term structures) |
| `sim/` | Simulation module (requires custom C++ in `cpp_layer/`) |
| `currency/` | Currency definitions and registry |
| `experimental/` | CMS spread coupons, cross-currency rate helpers |

### Special Build Mechanisms

- **Template rendering**: Yield curve `.pyx`/`.pxd` files in `termstructures/yields/` are generated from `.in` template files at build time (see `render_templates()` in `setup.py`).
- **Custom C++ support code**: Two extensions need files from `cpp_layer/`:
  - `sim.simulate` ← `cpp_layer/simulate_support_code.cpp`
  - `math.hestonhwcorrelationconstraint` ← `cpp_layer/constraint_support_code.cpp`
- **Windows DLL preloading**: `__init__.py` auto-loads QuantLib DLLs on Windows using `preload_dlls.txt`.

### Key Design Decisions

- QuantLib handles are hidden from users and managed internally via `shared_ptr`
- Observer pattern is used for market data updates (relinkable handles)
- Cython `embedsignature: True` exposes full function signatures in docstrings
- Compiler directive `language_level: '3str'` for Python 3 string semantics

## Testing

Tests use Python's `unittest` framework. Test files are in `test/` (58 modules). Test data fixtures are in `test/data/`. The test suite covers all major instrument types, term structures, models, and pricing engines.
