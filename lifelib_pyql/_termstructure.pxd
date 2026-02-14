from lifelib_pyql.types cimport Natural, Time
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter

cdef extern from 'ql/termstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass TermStructure:
        TermStructure(DayCounter& dc) except +
        DayCounter dayCounter()
        Time timeFromReference(Date& d)
        Date referenceDate()
        Date maxDate()
        Time maxTime()
        Calendar calendar()
        Natural settlementDays() except +
