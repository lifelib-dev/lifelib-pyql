from ._swaption_vol_structure cimport SwaptionVolatilityStructure
from lifelib_pyql.handle cimport Handle
from lifelib_pyql._quote cimport Quote

cdef extern from 'ql/termstructures/volatility/swaption/spreadedswaptionvol.hpp' namespace 'QuantLib':
    cdef cppclass SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
         SpreadedSwaptionVolatility(const Handle[SwaptionVolatilityStructure]&,
                                    const Handle[Quote]& spread)
