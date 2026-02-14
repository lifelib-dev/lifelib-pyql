from lifelib_pyql.types cimport Real, Natural
from libcpp cimport bool
from lifelib_pyql.default cimport Protection
from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time.dategeneration cimport DateGeneration
from ._credit_default_swap cimport CreditDefaultSwap

cdef extern from 'ql/instruments/makecds.hpp' namespace 'QuantLib':
    """
    namespace QuantLib{
    static inline ext::shared_ptr<CreditDefaultSwap> cast(MakeCreditDefaultSwap& cds) { return (ext::shared_ptr<CreditDefaultSwap>)(cds);};
    }
    """
    cdef cppclass MakeCreditDefaultSwap:
        MakeCreditDefaultSwap(const Period& Tenor, Real couponRate)
        MakeCreditDefaultSwap(const Date& termDate, Real couponRate)

        CreditDefaultSwap operator() const
        shared_ptr[CreditDefaultSwap] operator() const

        MakeCreditDefaultSwap& withUpfrontRate(Real)
        MakeCreditDefaultSwap& withSide(Protection)
        MakeCreditDefaultSwap& withNominal(Real)
        MakeCreditDefaultSwap& withCouponTenor(Period)
        MakeCreditDefaultSwap& withDayCounter(DayCounter&)
        MakeCreditDefaultSwap& withLastPeriodDayCounter(DayCounter&)
        MakeCreditDefaultSwap& withDateGenerationRule(DateGeneration rule)
        MakeCreditDefaultSwap& withCashSettlementDays(Natural cashSettlementDays)

        MakeCreditDefaultSwap& withPricingEngine(const shared_ptr[PricingEngine]&)
    shared_ptr[CreditDefaultSwap] cast(MakeCreditDefaultSwap&) except +
