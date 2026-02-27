lifelib-pyql
============

Cython-based Python bindings for the [QuantLib](http://www.quantlib.org) C++ library.

This project is a fork of [PyQL](https://github.com/enthought/pyql) (originally developed by Enthought) that replaces SWIG wrappers with a more Pythonic API built on Cython. It provides comprehensive coverage of QuantLib's functionality, including term structures, instruments, pricing engines, short-rate and equity models, and more.

## Portfolio Module

Beyond the core QuantLib bindings, lifelib-pyql is developing a `portfolio` submodule for processing a large number of instruments of the same type efficiently.

When working with thousands or millions of instruments, creating a separate Python object for each one is too slow. The `portfolio` submodule provides a set of new APIs that let you create a single Python object representing a large set of instruments of the same type, whose methods operate on all instruments in the set at once rather than one at a time.

Currently, the `portfolio` module includes:

- **`Schedules`** -- A vectorized collection of payment schedules. It bulk-generates QuantLib `Schedule` objects from arrays of parameters and stores the resulting dates in a compact 2D NumPy `datetime64[D]` array.

```python
from lifelib_pyql.portfolio.api import Schedules
import numpy as np

schedules = Schedules(
    effective_dates=np.array(['2024-01-15', '2024-03-01'], dtype='datetime64[D]'),
    termination_dates=np.array(['2029-01-15', '2029-03-01'], dtype='datetime64[D]'),
    tenors=np.array([6, 3]),       # months
    max_size=20,
)

schedules.dates    # 2D datetime64[D] array, NaT-padded
schedules.size     # number of dates per schedule
schedules[0]       # returns a single Schedule object
schedules[0:1]     # returns a new Schedules slice
```

## Prerequisites

* [QuantLib](http://www.quantlib.org) 1.41 or higher (with [Boost](https://www.boost.org/) 1.78.0+)
* [Cython](http://www.cython.org) 3.0 or higher
* Python 3.10+
* NumPy

## Building

```bash
# Build Cython extensions in-place
make build

# Run the test suite
make tests

# Build documentation (requires Sphinx, nbsphinx)
make docs
```

See the [Getting started](docs/source/getting_started.rst) guide for full details.

## License

BSD 3-Clause. See [LICENSE.txt](LICENSE.txt). The original PyQL license is preserved in [LICENSE_ORIGINAL_PYQL.txt](LICENSE_ORIGINAL_PYQL.txt).
