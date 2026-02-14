from lifelib_pyql.types cimport *

# These typedefs for time components are only defined in QuantLib when QL_HIGH_RESOLUTION_DATE is set
# Define them here as local typedefs for compatibility
ctypedef int Hour
ctypedef int Minute
ctypedef int Second
ctypedef int Millisecond
ctypedef int Microsecond

cdef extern from 'ql/time/date.hpp' namespace 'QuantLib' nogil:
    # These are always defined in QuantLib namespace
    ctypedef int Year
    ctypedef int Day

from libcpp cimport bool
from libcpp.string cimport string
from libc.stdint cimport int_fast32_t
from ._period cimport Period

cdef extern from "ostream" namespace "std":
    cdef cppclass ostream:
        pass

cdef extern from 'ql/time/weekday.hpp' namespace "QuantLib" nogil:

    cdef enum Weekday:
        pass

cdef extern from "ql/time/date.hpp" namespace "QuantLib::Date" nogil:
    ctypedef int_fast32_t serial_type
    cdef Date todaysDate()
    cdef Date minDate()
    cdef Date maxDate()
    cdef bool isLeap(Year y)
    cdef Date endOfMonth(Date& d) except +
    cdef bool isEndOfMonth(Date& d)
    cdef Date nextWeekday(Date& d, Weekday w) except +
    cdef Date nthWeekday(Size n, Weekday w,
                         Month m, Year y) except +
    # The following require QL_HIGH_RESOLUTION_DATE
    # cdef Date localDateTime()
    # cdef Date universalDateTime()


cdef extern from "ql/time/date.hpp" namespace "QuantLib" nogil:

    cdef enum Month:
        pass

    cdef cppclass Date:
        Date()
        Date(serial_type serialnumber) except +
        Date(const Date&)
        Date(Day d, Month m, Year y) except +
        # The following constructor and methods require QL_HIGH_RESOLUTION_DATE
        # Date(Day d, Month m, Year y, Hour h, Minute minutes, Second seconds,
        #      Millisecond millisec, Microsecond microsec)
        Day dayOfMonth() except +
        Month month()
        Year year()
        serial_type serialNumber() except +
        # Hour hours()
        # Minute minutes()
        # Second seconds()
        # Millisecond milliseconds()
        # Microsecond microseconds()
        # Time fractionOfDay()
        # Time fractionOfSecond()

        bool operator==(Date&)
        bool operator!=(Date&)
        bool operator<=(Date&)
        bool operator<(Date&)
        bool operator>=(Date&)
        bool operator>(Date&)

        Weekday weekday()
        Day dayOfYear()

        Date& operator++()
        Date& operator++(int value)
        Date& operator--()
        Date& operator--(int value)

        Date operator+(serial_type days)
        Date operator+(Period p)
        Date operator-(serial_type days)
        Date operator-(Period p)
        serial_type operator-(Date d)

        Date& i_add 'operator+='(serial_type days)
        Date& i_add 'operator+='(Period& period)
        Date& i_sub 'operator-='(Period& period)
        Date& i_sub 'operator-='(serial_type days)

    Time daysBetween(const Date&, const Date&)

cdef extern from "ql/time/date.hpp" namespace "QuantLib::detail":
    cdef cppclass iso_date_holder:
        pass
    cdef cppclass short_date_holder:
        pass
    # cdef cppclass iso_datetime_holder:  # Requires QL_HIGH_RESOLUTION_DATE
    #     pass
    cdef cppclass formatted_date_holder:
        pass

cdef extern from "ql/time/date.hpp" namespace "QuantLib::io" nogil:
    cdef short_date_holder short_date(const Date&)
    cdef iso_date_holder iso_date(const Date&)
    # cdef iso_datetime_holder iso_datetime(const Date&)  # Requires QL_HIGH_RESOLUTION_DATE
    cdef formatted_date_holder formatted_date(const Date&, const string& fmt)

cdef extern from "<sstream>" namespace "std" nogil:
    cdef cppclass stringstream:
        stringstream& operator<<(iso_date_holder)
        stringstream& operator<<(short_date_holder)
        # stringstream& operator<<(iso_datetime_holder)  # Requires QL_HIGH_RESOLUTION_DATE
        stringstream& operator<<(string)
        stringstream& operator<<(formatted_date_holder)
        string str()

cdef extern from 'ql/utilities/dataparsers.hpp' namespace "QuantLib::DateParser" nogil:
    Date parseISO(const string& str) except +
    Date parseFormatted(const string&, const string&) except +
