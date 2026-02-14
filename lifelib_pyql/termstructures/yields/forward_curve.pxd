from ..yield_term_structure cimport YieldTermStructure
cimport lifelib_pyql.math._interpolations as intpl
from . cimport _forward_curve as _fc


cdef class LinearInterpolatedForwardCurve(YieldTermStructure):
    cdef _fc.InterpolatedForwardCurve[intpl.Linear]* curve(self) noexcept nogil

cdef class LogLinearInterpolatedForwardCurve(YieldTermStructure):
    cdef _fc.InterpolatedForwardCurve[intpl.LogLinear]* curve(self) noexcept nogil

cdef class BackwardFlatInterpolatedForwardCurve(YieldTermStructure):
    cdef _fc.InterpolatedForwardCurve[intpl.BackwardFlat]* curve(self) noexcept nogil

cdef class CubicInterpolatedForwardCurve(YieldTermStructure):
    cdef _fc.InterpolatedForwardCurve[intpl.Cubic]* curve(self) noexcept nogil
