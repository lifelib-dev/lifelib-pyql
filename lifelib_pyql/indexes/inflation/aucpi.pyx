from libcpp cimport bool
from . cimport _aucpi
from lifelib_pyql.time.frequency cimport Frequency
from lifelib_pyql.termstructures.inflation_term_structure cimport ZeroInflationTermStructure

cdef class AUCPI(ZeroInflationIndex):
    def __init__(self,
                 Frequency frequency,
                 bool revised,
                 ZeroInflationTermStructure ts=ZeroInflationTermStructure()):
        self._thisptr.reset(new _aucpi.AUCPI(frequency, revised, ts._handle))
