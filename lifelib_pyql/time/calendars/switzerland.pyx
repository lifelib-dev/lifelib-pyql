cimport lifelib_pyql.time._calendar as _calendar
cimport lifelib_pyql.time.calendars._switzerland as _sw
from lifelib_pyql.time.calendar cimport Calendar

cdef class Switzerland(Calendar):
    ''' Swiss calendars.
   '''

    def __cinit__(self):

        self._thisptr = _sw.Switzerland()
