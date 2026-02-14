from lifelib_pyql.types cimport Real, Spread
from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.indexes._swap_index cimport SwapIndex
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.instruments._swap cimport Swap
from lifelib_pyql.cashflows._coupon_pricer cimport CmsCouponPricer
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time.dategeneration cimport DateGeneration
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/instruments/makecms.hpp' namespace 'QuantLib':
    cdef cppclass MakeCms:
        MakeCms(const Period& swapTenor,
                const shared_ptr[SwapIndex]& swapIndex,
                const shared_ptr[IborIndex]& iborIndex,
                Spread iborSpread, # = 0.0,
                const Period& forwardStart) # = 0*Days)
        MakeCms(const Period& swapTenor,
                const shared_ptr[SwapIndex]& swapIndex,
                Spread iborSpread, # = 0.0,
                const Period& forwardStart) # = 0*Days)
        shared_ptr[Swap] operator()
        MakeCms& receiveCms(bool flag = true);
        MakeCms& withNominal(Real n)
        MakeCms& withEffectiveDate(const Date&)

        MakeCms& withCmsLegTenor(const Period& t)
        MakeCms& withCmsLegCalendar(const Calendar& cal)
        MakeCms& withCmsLegConvention(BusinessDayConvention bdc)
        MakeCms& withCmsLegTerminationDateConvention(BusinessDayConvention)
        MakeCms& withCmsLegRule(DateGeneration r)
        MakeCms& withCmsLegEndOfMonth(bool flag = True)
        MakeCms& withCmsLegFirstDate(const Date& d)
        MakeCms& withCmsLegNextToLastDate(const Date& d)
        MakeCms& withCmsLegDayCount(const DayCounter& dc)

        MakeCms& withFloatingLegTenor(const Period& t)
        MakeCms& withFloatingLegCalendar(const Calendar& cal)
        MakeCms& withFloatingLegConvention(BusinessDayConvention bdc)
        MakeCms& withFloatingLegTerminationDateConvention(
                                                    BusinessDayConvention bdc)
        MakeCms& withFloatingLegRule(DateGeneration r)
        MakeCms& withFloatingLegEndOfMonth(bool flag = True)
        MakeCms& withFloatingLegFirstDate(const Date& d)
        MakeCms& withFloatingLegNextToLastDate(const Date& d)
        MakeCms& withFloatingLegDayCount(const DayCounter& dc)

        MakeCms& withAtmSpread(bool flag = True)

        MakeCms& withDiscountingTermStructure(
            Handle[YieldTermStructure]& discountingTermStructure)
        MakeCms& withCmsCouponPricer(
            shared_ptr[CmsCouponPricer]& couponPricer)
