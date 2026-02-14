from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from ._inflation_coupon_pricer cimport InflationCouponPricer
cdef extern from 'ql/cashflows/cpicouponpricer.hpp' namespace 'QuantLib':
    cdef cppclass CPICouponPricer(InflationCouponPricer):
        CPICouponPricer(
            const Handle[YieldTermStructure]& nominalTermStructure) except +
