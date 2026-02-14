from libcpp cimport bool

from cython.operator cimport dereference as deref
from lifelib_pyql.utilities.null cimport Null
from lifelib_pyql.instruments.dividendschedule cimport DividendSchedule
from lifelib_pyql.handle cimport static_pointer_cast, shared_ptr
from lifelib_pyql.types cimport Size, Real
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine as QlPricingEngine
from lifelib_pyql.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
from lifelib_pyql.methods.finitedifferences.solvers.fdmbackwardsolver cimport FdmSchemeDesc

cimport lifelib_pyql.processes._black_scholes_process as _bsp

cdef class FdBlackScholesVanillaEngine(PricingEngine):
    def __init__(self, GeneralizedBlackScholesProcess process,
                 Size t_grid=100,
                 Size x_grid=100,
                 Size damping_steps=0,
                 FdmSchemeDesc scheme=FdmSchemeDesc.Douglas(),
                 bool local_vol=False,
                 Real illegal_local_vol_overwrite=-Null[Real](),
                 CashDividendModel cash_dividend_model=Spot,
                 DividendSchedule dividends=None):
        cdef shared_ptr[_bsp.GeneralizedBlackScholesProcess] process_ptr = \
            static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](process._thisptr)
        if dividends is not None:
            self._thisptr.reset(
                new _fdbs.FdBlackScholesVanillaEngine(
                    process_ptr,
                    dividends.schedule,
                    t_grid,
                    x_grid,
                    damping_steps,
                    deref(scheme._thisptr),
                    local_vol,
                    illegal_local_vol_overwrite,
                    cash_dividend_model
                )
            )
        else:
            self._thisptr.reset(
                new _fdbs.FdBlackScholesVanillaEngine(
                    process_ptr,
                    t_grid,
                    x_grid,
                    damping_steps,
                    deref(scheme._thisptr),
                    local_vol,
                    illegal_local_vol_overwrite,
                    cash_dividend_model
                )
            )
