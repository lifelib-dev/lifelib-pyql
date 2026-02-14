from lifelib_pyql.types cimport Natural, Rate, Real
from libcpp cimport bool
from libcpp.vector cimport vector
from lifelib_pyql.handle cimport shared_ptr, Handle

from lifelib_pyql._quote cimport Quote
from lifelib_pyql.instruments._bond cimport Bond
from lifelib_pyql.termstructures._helpers cimport BootstrapHelper
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._schedule cimport Schedule
from ._flat_forward cimport YieldTermStructure
from ._rate_helpers cimport RateHelper


cdef extern from 'ql/termstructures/yield/bondhelpers.hpp' namespace 'QuantLib' nogil:

    cdef cppclass BondHelper(RateHelper):
        BondHelper(
            Handle[Quote]& cleanPrice,
            shared_ptr[Bond]& bond,
            Bond.Price.Type Type) except +

    cdef cppclass FixedRateBondHelper(BondHelper):
        FixedRateBondHelper(
            Handle[Quote]& cleanPrice,
            Natural settlementDays,
            Real faceAmount,
            Schedule& schedule,
            vector[Rate]& coupons,
            DayCounter& dayCounter,
            int paymentConv,  # Following
            Real redemption,  # 100.0
            Date& issueDate,  # Date()
            Calendar& paymentCalendar, # Calendar()
            Period& exCouponPeriod, # =Period()
            Calendar& exCouponCalendar, # = Calendar()
            BusinessDayConvention exCouponConvention, # = Unadjusted
            bool exCouponEndOfMonth, # = False
            Bond.Price.Type Type
        ) except +
