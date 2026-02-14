include '../../types.pxi'

from libcpp.vector cimport vector
from libcpp cimport bool

from lifelib_pyql.termstructures._inflation_term_structure cimport ZeroInflationTermStructure
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._period cimport Frequency, Period
from lifelib_pyql.handle cimport Handle, shared_ptr
from ._seasonality cimport Seasonality

cdef extern from 'ql/termstructures/inflation/interpolatedzeroinflationcurve.hpp' namespace 'QuantLib' nogil:
    cdef cppclass InterpolatedZeroInflationCurve[T](ZeroInflationTermStructure):
        InterpolatedZeroInflationCurve(const Date& referenceDate,
                                       vector[Date]& dates,
                                       vector[Rate]& rates,
                                       Frequency frequency,
                                       DayCounter dayCounter,
                                       shared_ptr[Seasonality] seasonality)
        vector[Date]& dates()
        vector[Real]& data()
        vector[Rate]& rates()
