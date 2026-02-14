include '../../types.pxi'
from libcpp.string cimport string
from lifelib_pyql.handle cimport shared_ptr, Handle, optional
from ._cms_spread_coupon cimport CmsSpreadCouponPricer
from lifelib_pyql.cashflows._coupon_pricer cimport CmsCouponPricer
from lifelib_pyql._quote cimport Quote
from lifelib_pyql.termstructures.volatility.volatilitytype cimport VolatilityType
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/experimental/coupons/lognormalcmsspreadpricer.hpp' namespace 'QuantLib':
    cdef cppclass LognormalCmsSpreadPricer(CmsSpreadCouponPricer):
        LognormalCmsSpreadPricer(
            const shared_ptr[CmsCouponPricer] cmsPricer,
            const Handle[Quote] &correlation,
            const Handle[YieldTermStructure] &couponDiscountCurve, # = Handle[YieldTermStructure]()
            const Size IntegrationPoints, # = 16,
            optional[VolatilityType] volatilityType, # = boost::none,
            const Real shift1, # = Null<Real>
            const Real shift2) # = Null<Real>
