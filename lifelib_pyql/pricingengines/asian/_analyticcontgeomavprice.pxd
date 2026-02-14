from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine


cdef extern from 'ql/pricingengines/asian/analytic_cont_geom_av_price.hpp' namespace 'QuantLib':

  cdef cppclass AnalyticContinuousGeometricAveragePriceAsianEngine(PricingEngine):
    AnalyticContinuousGeometricAveragePriceAsianEngine(
       shared_ptr[GeneralizedBlackScholesProcess] process
    ) except +
    
