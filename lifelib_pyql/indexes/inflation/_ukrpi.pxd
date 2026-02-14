from .._inflation_index cimport ZeroInflationIndex
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._inflation_term_structure cimport ZeroInflationTermStructure

cdef extern from 'ql/indexes/inflation/ukrpi.hpp' namespace 'QuantLib' nogil:
    cdef cppclass UKRPI(ZeroInflationIndex):
        UKRPI(const Handle[ZeroInflationTermStructure]& ts)
