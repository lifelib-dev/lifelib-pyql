from lifelib_pyql.cashflows.floating_rate_coupon cimport FloatingRateCoupon
from lifelib_pyql.cashflow cimport Leg

cdef class IborCoupon(FloatingRateCoupon):
    pass

cdef class IborLeg(Leg):
    pass

cdef class IborCouponSettings:
    pass
