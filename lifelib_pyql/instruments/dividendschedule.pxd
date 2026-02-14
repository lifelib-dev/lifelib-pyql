from libcpp.vector cimport vector
from lifelib_pyql.cashflows._dividend cimport Dividend
from lifelib_pyql.handle cimport shared_ptr

cdef class DividendSchedule:
    cdef vector[shared_ptr[Dividend]] schedule
