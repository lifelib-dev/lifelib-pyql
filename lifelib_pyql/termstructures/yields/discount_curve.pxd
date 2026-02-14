from ..yield_term_structure cimport YieldTermStructure
cimport lifelib_pyql.math._interpolations as intpl
from . cimport _discount_curve as _dc


cdef class LinearInterpolatedDiscountCurve(YieldTermStructure):
    cdef _dc.InterpolatedDiscountCurve[intpl.Linear]* curve(self) noexcept nogil

cdef class LogLinearInterpolatedDiscountCurve(YieldTermStructure):
    cdef _dc.InterpolatedDiscountCurve[intpl.LogLinear]* curve(self) noexcept nogil

cdef class BackwardFlatInterpolatedDiscountCurve(YieldTermStructure):
    cdef _dc.InterpolatedDiscountCurve[intpl.BackwardFlat]* curve(self) noexcept nogil

cdef class CubicInterpolatedDiscountCurve(YieldTermStructure):
    cdef _dc.InterpolatedDiscountCurve[intpl.Cubic]* curve(self) noexcept nogil
