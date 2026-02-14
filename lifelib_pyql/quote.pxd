cimport lifelib_pyql._quote as _qt
from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.observable cimport Observable

cdef class Quote(Observable):
    cdef shared_ptr[_qt.Quote] _thisptr
    cdef Handle[_qt.Quote] handle(self)
    @staticmethod
    cdef Handle[_qt.Quote] empty_handle()
