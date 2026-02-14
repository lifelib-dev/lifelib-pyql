"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string

from lifelib_pyql._index cimport Index
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.currency._currency cimport Currency


cdef extern from 'ql/indexes/interestrateindex.hpp' namespace 'QuantLib' nogil:

    cdef cppclass InterestRateIndex(Index):
        InterestRateIndex(string& familyName,
                         Period& tenor,
                         Natural settlementDays,
                         Currency& currency,
                         Calendar& fixingCalendar,
                         DayCounter& dayCounter) nogil
        bool isValidFixingDate(Date& fixingDate)
        Rate fixing(Date& fixingDate,
                    bool forecastTodaysFixing) except +

        Rate forecastFixing(const Date& fixingDate)

        string familyName()
        Period tenor()
        Natural fixingDays()
        Date fixingDate(Date& valueDate)
        Currency& currency()
        DayCounter& dayCounter()

        Date valueDate(Date& fixingDate)
        Date maturityDate(Date& valueDate)
