from cython.operator cimport dereference as deref
from lifelib_pyql.types cimport Natural, Rate, Real
from libcpp cimport bool
from libcpp.vector cimport vector
from . cimport _cpibond

from lifelib_pyql.handle cimport static_pointer_cast
cimport lifelib_pyql.indexes._inflation_index as _inf
from lifelib_pyql.indexes.inflation_index cimport ZeroInflationIndex
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention, Following, Unadjusted
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.time.schedule cimport Schedule
from lifelib_pyql.time.date cimport Date, Period
from lifelib_pyql.time.daycounter cimport DayCounter

cdef class CPIBond(Bond):
    """ CPI bond """
    def __init__(self, Natural settlement_days, Real face_amount, bool growth_only,
                 Real baseCPI, Period observation_lag not None,
                 ZeroInflationIndex cpi_index not None,
                 InterpolationType observation_interpolation,
                 Schedule schedule, vector[Rate] coupons,
                 DayCounter accrual_day_counter,
                 BusinessDayConvention payment_convention=Following,
                 Date issue_date=Date(), Calendar payment_calendar=Calendar(),
                 Period ex_coupon_period=Period(), Calendar ex_coupon_calendar=Calendar(),
                 BusinessDayConvention ex_coupon_convention=Unadjusted,
                 bool ex_coupon_end_of_month=False):

        self._thisptr.reset(
            new _cpibond.CPIBond(
                settlement_days, face_amount, growth_only, baseCPI,
                deref(observation_lag._thisptr),
                static_pointer_cast[_inf.ZeroInflationIndex](
                    cpi_index._thisptr),
                observation_interpolation,
                schedule._thisptr, coupons,
                deref(accrual_day_counter._thisptr), payment_convention,
                issue_date._thisptr,
                payment_calendar._thisptr, deref(ex_coupon_period._thisptr),
                ex_coupon_calendar._thisptr, ex_coupon_convention,
                ex_coupon_end_of_month
            )
        )
