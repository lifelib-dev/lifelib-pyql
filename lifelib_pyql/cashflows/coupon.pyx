from cython.operator cimport dereference as deref
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time.date cimport Date, date_from_qldate
cimport lifelib_pyql.time._date as _date
from lifelib_pyql.time.daycounter cimport DayCounter
cimport lifelib_pyql.time._daycounter as _dc
cimport lifelib_pyql._cashflow as _cf

cdef class Coupon(CashFlow):

    cdef inline _coupon.Coupon* _get_coupon(self):
        return <_coupon.Coupon*>self._thisptr.get()

    @property
    def nominal(self):
        return self._get_coupon().nominal()

    @property
    def accrual_start_date(self):
        return date_from_qldate(
            self._get_coupon().accrualStartDate())

    @property
    def accrual_end_date(self):
        return date_from_qldate(
            self._get_coupon().accrualEndDate())

    @property
    def reference_period_start(self):
        return date_from_qldate(
            self._get_coupon().referencePeriodStart())

    @property
    def reference_period_end(self):
        return date_from_qldate(
            self._get_coupon().referencePeriodEnd())

    @property
    def accrual_days(self):
        return self._get_coupon().accrualDays()

    @property
    def accrual_period(self):
        return self._get_coupon().accrualPeriod()

    def accrued_period(self, Date date):
        return self._get_coupon().accruedPeriod(date._thisptr)

    def accrued_days(self, Date date):
        return self._get_coupon().accruedDays(date._thisptr)

    def accrued_amount(self, Date date):
        return self._get_coupon().accruedAmount(date._thisptr)

    @property
    def rate(self):
        return self._get_coupon().rate()

    @property
    def day_counter(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new _dc.DayCounter(self._get_coupon().dayCounter())
        return dc
