from ..yield_term_structure cimport YieldTermStructure
from . cimport _bootstraptraits as _trait
from .bootstraptraits cimport BootstrapTrait as Trait
from . cimport _piecewise_yield_curve as _pyc

cimport lifelib_pyql.math._interpolations as intpl




cdef class DiscountLinearPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class DiscountLogLinearPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class DiscountBackwardFlatPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class DiscountCubicPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ZeroYieldLinearPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ZeroYieldLogLinearPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ZeroYieldBackwardFlatPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ZeroYieldCubicPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ForwardRateLinearPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ForwardRateLogLinearPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ForwardRateBackwardFlatPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat]* curve(self) noexcept nogil
    cdef readonly Trait trait


cdef class ForwardRateCubicPiecewiseYieldCurve(YieldTermStructure):
    cdef _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic]* curve(self) noexcept nogil
    cdef readonly Trait trait

