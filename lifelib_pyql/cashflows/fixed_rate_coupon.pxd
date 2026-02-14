from lifelib_pyql.cashflows.coupon cimport Coupon
from lifelib_pyql.cashflow cimport Leg
cimport lifelib_pyql.cashflows._fixed_rate_coupon as _frc

cdef class FixedRateCoupon(Coupon):
    pass

cdef class FixedRateLeg(Leg):
    cdef _frc.FixedRateLeg* frl
