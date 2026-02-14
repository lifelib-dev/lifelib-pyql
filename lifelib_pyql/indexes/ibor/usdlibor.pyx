from lifelib_pyql.handle cimport Handle, shared_ptr

from cython.operator cimport dereference as deref
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _usdlibor as _usd
cimport lifelib_pyql._index as _in
from lifelib_pyql.time.date cimport Period


cdef class USDLibor(Libor):
    def __init__(self, Period tenor not None, HandleYieldTermStructure ts=HandleYieldTermStructure()):
        self._thisptr = shared_ptr[_in.Index](
            new _usd.USDLibor(
                deref(tenor._thisptr), ts.handle
            )
        )
