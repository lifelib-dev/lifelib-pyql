from libcpp.string cimport string

from lifelib_pyql.time._calendar cimport Calendar
from .jointcalendar cimport JointCalendarRule

cdef extern from 'ql/time/calendars/jointcalendar.hpp' namespace 'QuantLib' nogil:
    cdef cppclass JointCalendar(Calendar):
            JointCalendar(Calendar& c1,
                          Calendar& c2,
                          JointCalendarRule r) except +
