from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.types cimport Size
from lifelib_pyql.models.shortrate._onefactor_model cimport ShortRateModel
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql._time_grid cimport TimeGrid
from .._pricing_engine cimport PricingEngine

cdef extern from 'ql/pricingengines/swaption/treeswaptionengine.hpp' namespace 'QuantLib':
    cdef cppclass TreeSwaptionEngine(PricingEngine):
        TreeSwaptionEngine(const shared_ptr[ShortRateModel],
                           const Size time_steps,
                           Handle[YieldTermStructure] term_structure) # = Handle[YieldTermStructure]()
        TreeSwaptionEngine(shared_ptr[ShortRateModel],
                           const TimeGrid time_grid,
                           Handle[YieldTermStructure] term_structure) # = Handle[YieldTermStructure]()
