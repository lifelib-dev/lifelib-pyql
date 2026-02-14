include '../types.pxi'

from . cimport _conundrum_pricer as _conp
from . cimport _coupon_pricer as _cp
cimport lifelib_pyql.termstructures.volatility.swaption._swaption_vol_structure as _svs
from lifelib_pyql.termstructures.volatility.swaption.swaption_vol_structure \
    cimport SwaptionVolatilityStructure
from lifelib_pyql.handle cimport Handle, shared_ptr, static_pointer_cast
from lifelib_pyql.quote cimport Quote

cpdef enum YieldCurveModel:
    Standard = _conp.Standard
    ExactYield = _conp.ExactYield
    ParallelShifts = _conp.ParallelShifts
    NonParallelShifts = _conp.NonParallelShifts


cdef class NumericHaganPricer(CmsCouponPricer):
    def __init__(self, swaption_vol not None,
                 YieldCurveModel yieldcurve_model,
                 Quote mean_reversion not None,
                 Rate lower_limit=0.,
                 Rate upper_limit=1.,
                 Real precision=1e-6):

        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](new _conp.NumericHaganPricer(
            SwaptionVolatilityStructure.swaption_vol_handle(swaption_vol),
            yieldcurve_model,
            mean_reversion.handle(),
            lower_limit,
            upper_limit,
            precision
        ))

cdef class AnalyticHaganPricer(CmsCouponPricer):
    def __init__(self, swaption_vol not None,
                 YieldCurveModel yieldcurve_model,
                 Quote mean_reversion not None):
        self._thisptr = shared_ptr[_cp.FloatingRateCouponPricer](new _conp.AnalyticHaganPricer(
            SwaptionVolatilityStructure.swaption_vol_handle(swaption_vol),
            yieldcurve_model,
            mean_reversion.handle()))
