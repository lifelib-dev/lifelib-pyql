from ._black_vol_term_structure cimport BlackVolTermStructure
from lifelib_pyql.pricingengines.vanilla._analytic_heston_engine cimport AnalyticHestonEngine
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.models.equity._heston_model cimport HestonModel

cdef extern from 'ql/termstructures/volatility/equityfx/hestonblackvolsurface.hpp' namespace 'QuantLib' nogil:

    cdef cppclass HestonBlackVolSurface(BlackVolTermStructure):
        HestonBlackVolSurface(const Handle[HestonModel]& hestonModel,
                              AnalyticHestonEngine.ComplexLogFormula cplxLogFormula, # = AnalyticHestonEngine::Gatheral
                              AnalyticHestonEngine.Integration integration) # = AnalyticHestonEngine::Integration::gaussLaguerre(164)
