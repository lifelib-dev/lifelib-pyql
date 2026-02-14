from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.termstructures.inflation.inflation_traits cimport (
    ZeroInflationTraits, YoYInflationTraits )

cdef class ZeroCouponInflationSwapHelper:
    cdef shared_ptr[ZeroInflationTraits.helper] _thisptr

cdef class YearOnYearInflationSwapHelper:
    cdef shared_ptr[YoYInflationTraits.helper] _thisptr
