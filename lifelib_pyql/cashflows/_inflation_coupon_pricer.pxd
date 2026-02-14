from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql._cashflow cimport Leg
cdef extern from 'ql/cashflows/inflationcouponpricer.hpp' namespace 'QuantLib':
    cdef cppclass InflationCouponPricer:
        pass

    void setCouponPricer(const Leg& leg,
                         const shared_ptr[InflationCouponPricer]&)

    cdef cppclass YoYInflationCouponPricer(InflationCouponPricer):
        YoYInflationCouponPricer(
            const Handle[YieldTermStructure]& nominalTermStructure) except +
