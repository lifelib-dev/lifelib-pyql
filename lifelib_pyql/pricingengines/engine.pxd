from lifelib_pyql.handle cimport shared_ptr
cimport lifelib_pyql.pricingengines._pricing_engine as _pe

cdef class PricingEngine:
    cdef shared_ptr[_pe.PricingEngine] _thisptr
