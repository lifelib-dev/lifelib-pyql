from lifelib_pyql.types cimport Rate, Real, Time
from libcpp.vector cimport vector
from libcpp.pair cimport pair

from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

from lifelib_pyql.compounding cimport Compounding
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time.frequency cimport Frequency

cdef extern from 'ql/termstructures/yield/zerocurve.hpp' namespace 'QuantLib' nogil:

     cdef cppclass InterpolatedZeroCurve[I](YieldTermStructure):
        InterpolatedZeroCurve(const vector[Date]& dates,
                              vector[Rate]& forwards,
                              const DayCounter& dayCounter,
                              const Calendar& cal, # = Calendar()
                              const I& interpolator,
                              Compounding compounding, # = Continuous,
                              Frequency frequency  # = Annual
        ) except +
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[Rate]& zeroRates()
        const vector[Date]& dates()
        vector[pair[Date, Real]]& nodes()
