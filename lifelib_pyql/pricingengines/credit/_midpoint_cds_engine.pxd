include '../../types.pxi'
from libcpp cimport bool

from lifelib_pyql.handle cimport Handle, optional
from lifelib_pyql.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/credit/midpointcdsengine.hpp' namespace 'QuantLib':

    cdef cppclass MidPointCdsEngine(PricingEngine):
        MidPointCdsEngine(
              Handle[DefaultProbabilityTermStructure]&,
              Real recoveryRate,
              Handle[YieldTermStructure]& discountCurve,
              optional[bool] includeSettlementDateFlows
        )
