from . cimport _spreaded_swaption_vol as _ssv
from .swaption_vol_structure cimport SwaptionVolatilityStructure
from lifelib_pyql.handle cimport shared_ptr

cdef class SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
    pass
