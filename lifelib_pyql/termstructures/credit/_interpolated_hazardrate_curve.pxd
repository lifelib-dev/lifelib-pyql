include '../../types.pxi'

from libcpp.vector cimport vector

from lifelib_pyql.termstructures._default_term_structure cimport (
    DefaultProbabilityTermStructure )

from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._calendar cimport Calendar

cdef extern from 'ql/termstructures/credit/interpolatedhazardratecurve.hpp' namespace 'QuantLib':

    cdef cppclass InterpolatedHazardRateCurve[T](DefaultProbabilityTermStructure):
        InterpolatedHazardRateCurve(const vector[Date]& dates,
                                    vector[Rate]& hazardRates,
                                    const DayCounter& dayCounter,
                                    const Calendar& cal # = Calendar()
        ) except +
        const vector[Time]& times()
        const vector[Real]& data()
        const vector[Rate]& hazardRates()
        const vector[Date]& dates()
