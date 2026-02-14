from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.observable cimport Observable
from . cimport _instrument

cdef class Instrument(Observable):
    cdef shared_ptr[_instrument.Instrument] _thisptr
