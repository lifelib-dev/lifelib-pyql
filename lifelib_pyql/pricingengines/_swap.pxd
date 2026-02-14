include '../types.pxi'

from lifelib_pyql.handle cimport Handle, optional
from lifelib_pyql.termstructures.yields._flat_forward cimport YieldTermStructure
from libcpp cimport bool
from lifelib_pyql.time._date cimport Date

from ._pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/swap/discountingswapengine.hpp' namespace 'QuantLib':

    cdef cppclass DiscountingSwapEngine(PricingEngine):
        DiscountingSwapEngine(const Handle[YieldTermStructure]& discount_curve,
                              optional[bool] includeSettlementDateFlows,
                              Date& settlementDate,
                              Date& npvDate)
        Handle[YieldTermStructure] discountCurve()
