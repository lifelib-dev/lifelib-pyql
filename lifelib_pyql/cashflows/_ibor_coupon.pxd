include '../types.pxi'

from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql._cashflow cimport CashFlow
from lifelib_pyql._interest_rate cimport InterestRate
from lifelib_pyql.cashflows._floating_rate_coupon cimport FloatingRateCoupon
from lifelib_pyql.indexes._ibor_index cimport IborIndex

cdef extern from 'ql/cashflows/iborcoupon.hpp' namespace 'QuantLib':
    cdef cppclass IborCoupon(FloatingRateCoupon):
        IborCoupon(const Date& paymentDate,
                   Real nominal,
                   const Date& startDate,
                   const Date& endDate,
                   Natural fixingDays,
                   const shared_ptr[IborIndex]& index,
                   Real gearing, #= 1.0,
                   Spread spread, #= 0.0,
                   const Date& refPeriodStart, #= Date(),
                   const Date& refPeriodEnd, #= Date(),
                   const DayCounter& dayCounter, #= DayCounter(),
                   bool isInArrears) #=false

        const shared_ptr[IborIndex]& ibor_index()
        const Date fixing_end_date()
        Rate index_fixing()

cdef extern from "ql/cashflows/iborcoupon.hpp" namespace "QuantLib::IborCoupon":
    cdef cppclass Settings:
        @staticmethod
        Settings& instance()
        void createAtParCoupons()

        # When called, IborCoupons are created as par coupons instead of indexed coupons.
        void createIndexedCoupons()

        # If true the IborCoupons are created as par coupons and vice versa.
        # The default depends on the compiler flag QL_USE_INDEXED_COUPON and can be overwritten by
        #    createAtParCoupons() and createIndexedCoupons() */
        bool usingAtParCoupons() const
