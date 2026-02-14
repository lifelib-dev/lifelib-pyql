from lifelib_pyql.types cimport Natural, Rate, Real, Size

from libcpp.vector cimport vector
from libcpp cimport bool

from .._instrument cimport Instrument
from lifelib_pyql.time._calendar cimport BusinessDayConvention, Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Frequency, Period
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._schedule cimport Schedule
from lifelib_pyql._cashflow cimport Leg
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.indexes._inflation_index cimport ZeroInflationIndex
from lifelib_pyql.time._schedule cimport DateGeneration
from lifelib_pyql.compounding cimport Compounding

cdef extern from 'ql/instruments/bond.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Bond(Instrument):
        cppclass Price:
            enum Type:
                Dirty
                Clean
            Price()
            Price(Real amount, Type type)
            Real amount()
            Type type()
        Natural settlementDays()
        Calendar& calendar()
        vector[Real]& notionals()
        Real notional(Date d)
        const Leg& cashflows()
        const Leg& redemptions()
        Date startDate() const
        Date maturityDate()
        Date issueDate()
        Date settlementDate(Date d)
        bool isTradable(Date d)
        Real accruedAmount(Date d) except +


        Real cleanPrice() except +
        Real dirtyPrice() except +
        Real settlementValue() except +

        Rate bond_yield 'yield'(
            DayCounter& dc,
            Compounding comp,
            Frequency freq,
            Real accuracy, # = 1e-8
            Size maxEvaluations, # = 100
            Real guess, # = 0.05,
            Bond.Price.Type price_type # = Bond.Price.Clean
        ) except +

        Rate bond_yield 'yield'(
            Bond.Price price,
            DayCounter& dc,
            Compounding comp,
            Frequency freq,
            Date settlementDate, # = Date()
            Real accuracy, # = 1e-8
            Size maxEvaluations, # = 100
            Real guess, # = 0.05,
        ) except +

        Rate nextCouponRate(Date d) const

        Rate previousCouponRate(Date d) const

        Date nextCashFlowDate(Date d) except +
        Date previousCashFlowDate(Date d) except +
