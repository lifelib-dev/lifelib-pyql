include '../../types.pxi'
from libcpp cimport bool
from libcpp.vector cimport vector

from lifelib_pyql.handle cimport Handle, optional, shared_ptr
from lifelib_pyql.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper, CdsHelper
from lifelib_pyql.termstructures.yields._rate_helpers cimport RateHelper

cdef extern from 'ql/pricingengines/credit/isdacdsengine.hpp' namespace 'QuantLib':

    cdef cppclass IsdaCdsEngine(PricingEngine):
        IsdaCdsEngine(
            Handle[DefaultProbabilityTermStructure]&,
            Real recoveryRate,
            Handle[YieldTermStructure]& discountCurve,
            optional[bool] includeSettlementDateFlows, # = none
            NumericalFix, # = Taylor
            AccrualBias, # = NoBias
            ForwardsInCouponPeriod # = Piecewise
        )
        const Handle[YieldTermStructure]& isdaRateCurve()
        const Handle[DefaultProbabilityTermStructure]& isdaCreditCurve()
        void calculate()

cdef extern from 'ql/pricingengines/credit/isdacdsengine.hpp' namespace 'QuantLib::IsdaCdsEngine':

    cdef enum NumericalFix:
        No "QuantLib::IsdaCdsEngine::None"
        Taylor

    cdef enum AccrualBias:
        HalfDayBias
        NoBias

    cdef enum ForwardsInCouponPeriod:
        Flat
        Piecewise
