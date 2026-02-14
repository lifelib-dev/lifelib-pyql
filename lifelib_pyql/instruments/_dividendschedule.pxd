from libcpp.vector cimport vector
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.cashflows._dividend cimport Dividend

cdef extern from 'ql/instruments/dividendschedule.hpp' namespace 'QuantLib' nogil:
    ctypedef vector[shared_ptr[Dividend]] DividendSchedule
