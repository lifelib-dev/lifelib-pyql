include '../../types.pxi'

from lifelib_pyql.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.handle cimport Handle
from lifelib_pyql._quote cimport Quote

cdef extern from 'ql/termstructures/credit/flathazardrate.hpp' namespace 'QuantLib':

    cdef cppclass FlatHazardRate(DefaultProbabilityTermStructure):
        FlatHazardRate(const Date& referenceDate,
                       const Handle[Quote]& hazardRate,
                       const DayCounter&)
        FlatHazardRate(const Date& referenceDate,
                       Rate hazardRate,
                       const DayCounter&)
        FlatHazardRate(Natural settlementDays,
                       const Calendar& calendar,
                       const Handle[Quote]& hazardRate,
                       const DayCounter&)
        FlatHazardRate(Natural settlementDays,
                       const Calendar& calendar,
                       Rate hazardRate,
                       const DayCounter&)
