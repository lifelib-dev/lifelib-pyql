include '../types.pxi'

from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._schedule cimport DateGeneration
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.instruments._vanillaswap cimport VanillaSwap
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/instruments/makevanillaswap.hpp' namespace 'QuantLib':
    cdef cppclass MakeVanillaSwap:
        MakeVanillaSwap(const Period& swapTenor,
                        const shared_ptr[IborIndex]& iborIndex,
                        Rate fixedRate, # = Null<Rate>())
                        const Period& forwardStart) #= 0*Days)

        VanillaSwap operator()
        shared_ptr[VanillaSwap] operator()

        MakeVanillaSwap& receiveFixed(bool flag) # = true);
        MakeVanillaSwap& withType(VanillaSwap.Type type)
        MakeVanillaSwap& withNominal(Real n)

        MakeVanillaSwap& withSettlementDays(Natural settlementDays)
        MakeVanillaSwap& withEffectiveDate(const Date&)
        MakeVanillaSwap& withTerminationDate(const Date&)
        MakeVanillaSwap& withRule(DateGeneration r)

        MakeVanillaSwap& withFixedLegTenor(const Period& t)
        MakeVanillaSwap& withFixedLegCalendar(const Calendar& cal)
        MakeVanillaSwap& withFixedLegConvention(BusinessDayConvention bdc)
        MakeVanillaSwap& withFixedLegTerminationDateConvention(
                                                   BusinessDayConvention bdc)
        MakeVanillaSwap& withFixedLegRule(DateGeneration r)
        MakeVanillaSwap& withFixedLegEndOfMonth(bool flag) # = true)
        MakeVanillaSwap& withFixedLegFirstDate(const Date& d)
        MakeVanillaSwap& withFixedLegNextToLastDate(const Date& d)
        MakeVanillaSwap& withFixedLegDayCount(const DayCounter& dc)

        MakeVanillaSwap& withFloatingLegTenor(const Period& t)
        MakeVanillaSwap& withFloatingLegCalendar(const Calendar& cal)
        MakeVanillaSwap& withFloatingLegConvention(BusinessDayConvention bdc)
        MakeVanillaSwap& withFloatingLegTerminationDateConvention(
                                                   BusinessDayConvention bdc)
        MakeVanillaSwap& withFloatingLegRule(DateGeneration r)
        MakeVanillaSwap& withFloatingLegEndOfMonth(bool flag)# = true)
        MakeVanillaSwap& withFloatingLegFirstDate(const Date& d)
        MakeVanillaSwap& withFloatingLegNextToLastDate(const Date& d)
        MakeVanillaSwap& withFloatingLegDayCount(const DayCounter& d)
        MakeVanillaSwap& withFloatingLegSpread(Spread sp)

        MakeVanillaSwap& withDiscountingTermStructure(
            const Handle[YieldTermStructure]& discountCurve)
        MakeVanillaSwap& withPricingEngine(
            const shared_ptr[PricingEngine]& engine);
