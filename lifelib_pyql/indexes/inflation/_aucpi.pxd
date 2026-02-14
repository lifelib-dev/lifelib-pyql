from libcpp cimport bool
from .._inflation_index cimport ZeroInflationIndex, YoYInflationIndex
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._inflation_term_structure cimport ZeroInflationTermStructure, YoYInflationTermStructure
from lifelib_pyql.time.frequency cimport Frequency


cdef extern from 'ql/indexes/inflation/aucpi.hpp' namespace 'QuantLib' nogil:
    cdef cppclass AUCPI(ZeroInflationIndex):
        AUCPI(Frequency frequency,
              bool revised,
              const Handle[ZeroInflationTermStructure]& ts)

        YYAUCPI(Frequency frequency,
                bool revised,
                bool interpolated,
                const Handle[YoYInflationTermStructure]& ts)
