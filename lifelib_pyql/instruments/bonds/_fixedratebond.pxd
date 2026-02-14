from lifelib_pyql.types cimport Natural, Rate, Real
from libcpp cimport bool
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._schedule cimport Schedule
from libcpp.vector cimport vector
from .._bond cimport Bond

cdef extern from 'ql/instruments/bonds/fixedratebond.hpp' namespace 'QuantLib' nogil:
    cdef cppclass FixedRateBond(Bond):
        FixedRateBond(Natural settlementDays,
                      Real faceAmount,
                      const Schedule& schedule,
                      vector[Rate]& coupons,
                      const DayCounter& accrualDayCounter,
                      BusinessDayConvention paymentConvention,
                      Real redemption, # 100.0
                      const Date& issueDate, # Date()
                      const Calendar& payemntCalendar, # Calendar()
                      const Period& exCouponPeriod, # Period()
                      const Calendar& exCouponCalendar, # Calendar()
                      const BusinessDayConvention exCouponConvention, # Unadjusted,
                      bool exCouponEndOfMonth, # false
                      const DayCounter& firstPeriodDayCounter, # = DayCounter()
                      ) except +
