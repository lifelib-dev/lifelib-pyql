from lifelib_pyql.types cimport Natural, Rate, Real, Spread
from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql._cashflow cimport CashFlow
from lifelib_pyql._interest_rate cimport InterestRate
from lifelib_pyql.cashflows._coupon cimport Coupon
from ._coupon_pricer cimport FloatingRateCouponPricer
from lifelib_pyql.indexes._interest_rate_index cimport InterestRateIndex

cdef extern from 'ql/cashflows/floatingratecoupon.hpp' namespace 'QuantLib' nogil:
    cdef cppclass FloatingRateCoupon(Coupon):
        FloatingRateCoupon(const Date& paymentDate,
                           Real nominal,
                           const Date& startDate,
                           const Date& endDate,
                           Natural fixingDays,
                           const shared_ptr[InterestRateIndex] index,
                           Real gearing, #= 1.0,
                           Spread spread, #= 0.0,
                           const Date& refPeriodStart, #= Date(),
                           const Date& refPeriodEnd, #= Date(),
                           const DayCounter& dayCounter, #= DayCounter(),
                           bool isInArrears) #=false

        const shared_ptr[InterestRateIndex]& index()
        Natural fixingDays()
        Date fixingDate()
        Real gearing()
        Spread spread()
        Rate indexFixing()
        Rate convexityAdjustment() except +
        Rate adjustedFixing() except +
        bool isInArrears()
        void setPricer(const shared_ptr[FloatingRateCouponPricer]&)
