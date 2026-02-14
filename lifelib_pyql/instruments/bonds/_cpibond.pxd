from lifelib_pyql.types cimport Natural, Rate, Real
from libcpp cimport bool
from libcpp.vector cimport vector
from .._bond cimport Bond

from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._schedule cimport Schedule
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.indexes._inflation_index cimport ZeroInflationIndex

from .cpibond cimport InterpolationType

cdef extern from 'ql/instruments/bonds/cpibond.hpp' namespace 'QuantLib' nogil:
    cdef cppclass CPIBond(Bond):
        CPIBond(Natural settlementDays,
                Real faceAmount,
                bool growthOnly,
                Real baseCPI,
                const Period& observationLag,
                shared_ptr[ZeroInflationIndex]& cpiIndex,
                InterpolationType observationInterpolation,
                const Schedule& schedule,
                vector[Rate]& coupons,
                const DayCounter& accrualDayCounter,
                BusinessDayConvention paymentConvention,
                const Date& issueDate, # Date()
                const Calendar& paymentCalendar, #Calendar()
                const Period& exCouponPeriod, # Period()
                const Calendar& exCouponCalendar, # Calendar()
                const BusinessDayConvention exCouponConvention,  # Unadjusted
                bool exCouponEndOfMonth # false
        ) except +
