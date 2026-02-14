from cython.operator cimport dereference as deref

from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr, optional
from lifelib_pyql.pricingengines.vanilla.vanilla cimport PricingEngine
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure

cimport lifelib_pyql.pricingengines._swap as _swap
cimport lifelib_pyql.termstructures._yield_term_structure as _yts
from lifelib_pyql.time.date cimport Date

cdef class DiscountingSwapEngine(PricingEngine):

    def __init__(self, HandleYieldTermStructure discount_curve not None,
                 include_settlement_date_flows=None,
                 Date settlement_date=Date(),
                 Date npv_date=Date()):
        cdef optional[bool] include_settlement_date_flows_opt
        if include_settlement_date_flows is not None:
            include_settlement_date_flows_opt = <bool>include_settlement_date_flows
        self._thisptr.reset(
            new _swap.DiscountingSwapEngine(
                discount_curve.handle,
                include_settlement_date_flows_opt,
                settlement_date._thisptr,
                npv_date._thisptr
            )
        )
