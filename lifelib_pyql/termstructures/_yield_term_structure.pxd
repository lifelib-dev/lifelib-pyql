"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""
from lifelib_pyql.types cimport *

from libcpp cimport bool
from libcpp.vector cimport vector

from lifelib_pyql.handle cimport shared_ptr, Handle, RelinkableHandle
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date, Period
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._period cimport Frequency
cimport lifelib_pyql._quote as _qt
from lifelib_pyql._interest_rate cimport InterestRate
from lifelib_pyql.compounding cimport Compounding
from .._termstructure cimport TermStructure

cdef extern from 'ql/termstructures/yieldtermstructure.hpp' namespace 'QuantLib' nogil:

    cdef cppclass YieldTermStructure(TermStructure):
        YieldTermStructure(DayCounter& dc,
                           vector[Handle[_qt.Quote]]& jumps,
                           vector[Date]& jumpDates,
                           ) except +
        DiscountFactor discount(Date& d, bool extrapolate) except +
        DiscountFactor discount(Time t, bool extrapolate) except +
        InterestRate zeroRate(Date& d,
                              DayCounter& resultDayCounter,
                              Compounding comp,
                              Frequency freq,  # = Annual
                              bool extrapolate  # = False
                              ) except +
        InterestRate zeroRate(Time t,
                              Compounding comp,
                              Frequency freq, # = Annual
                              bool extrapolate
                              ) except +
        InterestRate forwardRate(Date& d1,
                                 Date& d2,
                                 DayCounter& resultDayCounter,
                                 Compounding comp,
                                 Frequency freq,  # = Annual
                                 bool extrapolate  # = False
                             ) except +
        InterestRate forwardRate(Date& d1,
                                 Period& p,
                                 DayCounter& resultDayCounter,
                                 Compounding comp,
                                 Frequency freq,
                                 bool extrapolate,
                                 ... # can't specify the types otherwise cython can't find suitable method
                                 # Date& d1,
                                 # Period& p,
                                 # DayCounter& resultDayCounter,
                                 # Compounding comp,
                                 # Frequency freq, # = Annual
                                 # bool extrapolate # = False
                                 ) except +
        InterestRate forwardRate(Time t1,
                                 Time t2,
                                 Compounding comp,
                                 Frequency freq, # = Annual
                                 bool extrapolate # = False
                                 ) except +

        bool allowsExtrapolation()
        void enableExtrapolation()
        void disableExtrapolation()
