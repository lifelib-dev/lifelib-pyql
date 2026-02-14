cimport lifelib_pyql.pricingengines._pricing_engine as _pe
from lifelib_pyql.pricingengines.engine cimport PricingEngine

cdef enum RngTrait:
    PseudoRandom
    LowDiscrepance

cdef enum MCTrait:
    MultiVariate
    SingleVariate

cdef class MCVanillaEngine(PricingEngine):
    pass
