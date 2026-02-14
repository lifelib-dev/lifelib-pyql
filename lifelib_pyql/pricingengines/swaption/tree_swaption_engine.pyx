from lifelib_pyql.handle cimport Handle, shared_ptr, static_pointer_cast
from lifelib_pyql.types cimport Size
cimport lifelib_pyql.models._model as _mo
from lifelib_pyql.models.model cimport ShortRateModel
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.time_grid cimport TimeGrid
from . cimport _tree_swaption_engine as _tse

cdef class TreeSwaptionEngine(PricingEngine):
    def __init__(self, ShortRateModel model, time_steps_or_time_grid, HandleYieldTermStructure term_structure=HandleYieldTermStructure()):
        if isinstance(time_steps_or_time_grid, TimeGrid):
            self._thisptr.reset(
                new _tse.TreeSwaptionEngine(static_pointer_cast[_mo.ShortRateModel](model._thisptr),
                                            (<TimeGrid>time_steps_or_time_grid)._thisptr,
                                            term_structure.handle)
            )
        elif isinstance(time_steps_or_time_grid, int):
            self._thisptr.reset(
                new _tse.TreeSwaptionEngine(static_pointer_cast[_mo.ShortRateModel](model._thisptr),
                                            <Size>time_steps_or_time_grid,
                                            term_structure.handle)
            )
        else:
            raise ValueError("needs to pass either a number of time steps or a TimeGrid")
