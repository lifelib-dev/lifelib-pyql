from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
cimport lifelib_pyql.models.shortrate._onefactor_model as _ofm


cdef extern from 'ql/pricingengines/swaption/jamshidianswaptionengine.hpp' namespace 'QuantLib' nogil:

    cdef cppclass JamshidianSwaptionEngine(PricingEngine):
        JamshidianSwaptionEngine(
              shared_ptr[_ofm.OneFactorAffineModel]& model,
              Handle[YieldTermStructure]& termStructure)
