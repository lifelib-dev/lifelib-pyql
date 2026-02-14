from lifelib_pyql.cashflows.floating_rate_coupon cimport FloatingRateCoupon
from lifelib_pyql.cashflows.coupon_pricer cimport FloatingRateCouponPricer
from lifelib_pyql.cashflows.cap_floored_coupon cimport CappedFlooredCoupon

cdef class CmsSpreadCoupon(FloatingRateCoupon):
    pass

cdef class CappedFlooredCmsSpreadCoupon(CappedFlooredCoupon):
    pass

cdef class CmsSpreadCouponPricer(FloatingRateCouponPricer):
    pass
