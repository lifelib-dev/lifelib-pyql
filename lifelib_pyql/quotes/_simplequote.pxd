from lifelib_pyql.types cimport Real
from lifelib_pyql._quote cimport Quote

cdef extern from 'ql/quotes/simplequote.hpp' namespace 'QuantLib' nogil:

    cdef cppclass SimpleQuote(Quote):
        SimpleQuote(Real value)
        Real setValue(Real value)
        void reset()
