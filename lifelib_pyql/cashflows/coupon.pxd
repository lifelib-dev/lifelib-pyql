from lifelib_pyql.cashflow cimport CashFlow
cimport lifelib_pyql.cashflows._coupon as _coupon

cdef class Coupon(CashFlow):
    cdef inline _coupon.Coupon* _get_coupon(self)
