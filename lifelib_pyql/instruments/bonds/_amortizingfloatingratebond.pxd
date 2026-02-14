from lifelib_pyql.types cimport Integer, Natural, Rate, Real, Spread
from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._schedule cimport Schedule
from libcpp.vector cimport vector
from .._bond cimport Bond

cdef extern from "ql/instruments/bonds/amortizingfloatingratebond.hpp" namespace "QuantLib" nogil:
    cdef cppclass AmortizingFloatingRateBond(Bond):
        AmortizingFloatingRateBond(
            Natural settlementDays,
            const vector[Real]& notional,
            const Schedule& schedule,
            const shared_ptr[IborIndex]& index,
            const DayCounter& accrualDayCounter,
            BusinessDayConvention paymentConvention,# = Following,
            Natural fixingDays,# = Null<Natural>(),
            const vector[Real]& gearings, # = { 1.0 },
            const vector[Spread]& spreads, # = { 0.0 },
            const vector[Rate]& caps, # = {},
            const vector[Rate]& floors, # = {},
            bool inArrears,# = false,
            const Date& issueDate,# = Date(),
            const Period& exCouponPeriod,# = Period(),
            const Calendar& exCouponCalendar,# = Calendar(),
            BusinessDayConvention exCouponConvention,# = Unadjusted,
            bool exCouponEndOfMonth, # = false,
            const vector[Real]& redemptions, #= { 100.0 },
            Integer paymentLag # = 0
        ) except +
