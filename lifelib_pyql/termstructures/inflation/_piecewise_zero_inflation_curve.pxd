from lifelib_pyql.types cimport Real
from libcpp.vector cimport vector
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Frequency
from lifelib_pyql.time._daycounter cimport DayCounter
from ._interpolated_zero_inflation_curve cimport InterpolatedZeroInflationCurve
from ._seasonality cimport Seasonality
from .inflation_traits cimport ZeroInflationTraits

cdef extern from 'ql/termstructures/inflation/piecewisezeroinflationcurve.hpp' namespace 'QuantLib' nogil:
    cdef cppclass PiecewiseZeroInflationCurve[T](InterpolatedZeroInflationCurve[T]):
        PiecewiseZeroInflationCurve(const Date& referenceDate,
                                    Date baseDate,
                                    Frequency frequency,
                                    const DayCounter& dayCounter,
                                    const vector[shared_ptr[ZeroInflationTraits.helper]]& instruments,
                                    shared_ptr[Seasonality] seasonality,
                                    Real accuracy) #= 1.0e-12,
