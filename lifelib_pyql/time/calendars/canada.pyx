cimport lifelib_pyql.time.calendars._canada as _ca
from lifelib_pyql.time.calendar cimport Calendar

cdef class Canada(Calendar):
    ''' Canada calendars.
   '''

    def __cinit__(self, Market market=Market.Settlement):
        self._thisptr = _ca.Canada(market)
