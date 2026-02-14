from lifelib_pyql.types cimport Real Size
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.models.shortrate.twofactormodels._g2 cimport G2
from lifelib_pyql.pricingengines._pricingengine cimport PricingEngine

cdef extern from 'ql/pricingengines/swaption/g2swaptionengine.hpp' namespace 'QuantLib' nogil:

    cdef cppclass G2SwaptionEngine(PricingEngine):
        G2SwaptionEngine(
            shared_ptr[G2]& model,
            Real range
            Size intervals)
