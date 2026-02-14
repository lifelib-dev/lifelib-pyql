from cython.operator cimport dereference as deref
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time.date cimport Period
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.indexes.swap_index cimport SwapIndex

cimport lifelib_pyql.indexes.swap._euribor_swap as _es
cimport lifelib_pyql._index as _in

cdef class EuriborSwapIsdaFixA(SwapIndex):
    def __init__(self, Period tenor, HandleYieldTermStructure forwarding=HandleYieldTermStructure(),
                 HandleYieldTermStructure discounting=None):
        if discounting is None:
             self._thisptr = shared_ptr[_in.Index](
                 new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                             forwarding.handle))
        else:
            self._thisptr = shared_ptr[_in.Index](
                new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                            forwarding.handle,
                                            discounting.handle)
            )

cdef class EuriborSwapIsdaFixB(SwapIndex):
    def __init__(self, Period tenor, HandleYieldTermStructure forwarding=HandleYieldTermStructure(),
                 HandleYieldTermStructure discounting=None):
        if discounting is None:
            self._thisptr = shared_ptr[_in.Index](
                new _es.EuriborSwapIsdaFixA(deref(tenor._thisptr),
                                            forwarding.handle))
        else:
            self._thisptr = shared_ptr[_in.Index](
                new _es.EuriborSwapIsdaFixB(deref(tenor._thisptr),
                                            forwarding.handle,
                                            discounting.handle)
            )
