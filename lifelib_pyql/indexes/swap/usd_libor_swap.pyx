from cython.operator cimport dereference as deref
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time.date cimport Period
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.indexes.swap_index cimport SwapIndex

cimport lifelib_pyql.indexes.swap._usd_libor_swap as _ls
cimport lifelib_pyql._index as _in

cdef class UsdLiborSwapIsdaFixAm(SwapIndex):
    def __init__(self, Period tenor, HandleYieldTermStructure forwarding=HandleYieldTermStructure(),
                 HandleYieldTermStructure discounting=None):
        if discounting is None:
            self._thisptr = shared_ptr[_in.Index](
                new _ls.UsdLiborSwapIsdaFixAm(deref(tenor._thisptr),
                                              forwarding.handle)
            )
        else:
            self._thisptr = shared_ptr[_in.Index](
                new _ls.UsdLiborSwapIsdaFixAm(deref(tenor._thisptr),
                                              forwarding.handle,
                                              discounting.handle)
            )

cdef class UsdLiborSwapIsdaFixPm(SwapIndex):
    def __init__(self, Period tenor, HandleYieldTermStructure forwarding=HandleYieldTermStructure(),
                 HandleYieldTermStructure discounting=None):
        if discounting is None:
            self._thisptr = shared_ptr[_in.Index](
                new _ls.UsdLiborSwapIsdaFixPm(deref(tenor._thisptr),
                                              forwarding.handle)
            )
        else:
             self._thisptr = shared_ptr[_in.Index](
                new _ls.UsdLiborSwapIsdaFixPm(deref(tenor._thisptr),
                                              forwarding.handle,
                                              discounting.handle)
             )
