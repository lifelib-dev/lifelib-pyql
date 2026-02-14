cimport lifelib_pyql.time._calendar as _calendar
cimport lifelib_pyql.time.calendars._japan as _jp
from lifelib_pyql.time.calendar cimport Calendar

cdef class Japan(Calendar):
    ''' Japan calendars.
   '''

    def __cinit__(self):

        self._thisptr = _jp.Japan()
