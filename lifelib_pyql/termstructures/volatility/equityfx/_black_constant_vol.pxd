include '../../../types.pxi'
from lifelib_pyql.handle cimport Handle
from lifelib_pyql._quote cimport Quote
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._daycounter cimport DayCounter
from ._black_vol_term_structure cimport BlackVolatilityTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/blackconstantvol.hpp' namespace 'QuantLib':

    cdef cppclass BlackConstantVol(BlackVolatilityTermStructure):
        BlackConstantVol(Date& referenceDate,
                         Calendar& calendar,
                         Volatility volatility,
                         DayCounter& dayCounter)
        BlackConstantVol(const Date& referenceDate,
                         const Calendar&,
                         const Handle[Quote]& volatility,
                         const DayCounter& dayCounter)
        BlackConstantVol(Natural settlementDays,
                         const Calendar&,
                         Volatility volatility,
                         const DayCounter& dayCounter)
        BlackConstantVol(Natural settlementDays,
                         const Calendar&,
                         const Handle[Quote]& volatility,
                         const DayCounter& dayCounter)
