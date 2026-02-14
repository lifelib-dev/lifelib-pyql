from ..yield_term_structure cimport YieldTermStructure
cimport lifelib_pyql.math._interpolations as intpl
from . cimport _zero_curve as _zc


cdef class LinearInterpolatedZeroCurve(YieldTermStructure):
    cdef _zc.InterpolatedZeroCurve[intpl.Linear]* _curve


cdef class LogLinearInterpolatedZeroCurve(YieldTermStructure):
    cdef _zc.InterpolatedZeroCurve[intpl.LogLinear]* _curve


cdef class BackwardFlatInterpolatedZeroCurve(YieldTermStructure):
    cdef _zc.InterpolatedZeroCurve[intpl.BackwardFlat]* _curve


cdef class CubicInterpolatedZeroCurve(YieldTermStructure):
    cdef _zc.InterpolatedZeroCurve[intpl.Cubic]* _curve

