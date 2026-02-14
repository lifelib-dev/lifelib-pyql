from cython.operator cimport dereference as deref
from libcpp cimport bool
from libcpp.vector cimport vector

from lifelib_pyql.handle cimport static_pointer_cast
cimport lifelib_pyql.indexes._ibor_index as _ii
from lifelib_pyql.indexes.ibor_index cimport IborIndex
from lifelib_pyql.types cimport Natural, Integer, Real, Rate, Spread
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention, Following, Unadjusted
from lifelib_pyql.time.schedule cimport Schedule
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.time.date cimport Date, Period
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.utilities.null cimport Null
from . cimport _amortizingfloatingratebond as _afb

cdef class AmortizingFloatingRateBond(Bond):
    def __init__(self, Natural settlement_days, vector[Real] notional, Schedule schedule, IborIndex index, DayCounter accrual_day_counter,
                 BusinessDayConvention payment_convention = Following, Natural fixing_days = Null[Natural](), vector[Real] gearings = [1.0],
                 vector[Spread] spreads = [0.0],
                 vector[Rate] caps=[], vector[Rate] floors=[], bool in_arrears = False, Date issue_date = Date(),
                 Period ex_coupon_period = Period(), Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False,
                 vector[Real] redemptions=[100.0],
                 Integer payment_lag = 0):
        self._thisptr.reset(
            new _afb.AmortizingFloatingRateBond(
                settlement_days,
                notional, schedule._thisptr, static_pointer_cast[_ii.IborIndex](index._thisptr),
                deref(accrual_day_counter._thisptr), payment_convention, fixing_days, gearings,
                spreads, caps, floors, in_arrears, issue_date._thisptr,
                deref(ex_coupon_period._thisptr), ex_coupon_calendar._thisptr,
                ex_coupon_convention, ex_coupon_end_of_month,
                redemptions,
                payment_lag
            )
        )
