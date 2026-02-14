from lifelib_pyql.types cimport Rate, Real, Spread, Size, Time

from lifelib_pyql.instruments._bond cimport Bond
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time._period cimport Frequency
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.compounding cimport Compounding
from lifelib_pyql._cashflow cimport Leg
from lifelib_pyql.cashflows.duration cimport Duration

cdef extern from 'ql/pricingengines/bond/bondfunctions.hpp' namespace 'QuantLib::BondFunctions' nogil:

    cdef Date startDate(Bond bond)
    cdef Leg.const_reverse_iterator previousCashFlow(const Bond& bond,
                                                     Date refDate) # = Date()
    cdef Time duration(Bond bond,
                    Rate yld,
                    DayCounter dayCounter,
                       Compounding compounding,
                    Frequency frequency,
                    Duration dur_type, #Duration.Modified
                    Date settlementDate ) except + # Date()

    cdef Rate bf_yield "QuantLib::BondFunctions::yield" (Bond bond,
                    Bond.Price Price,
                    DayCounter dayCounter,
                    Compounding compounding,
                    Frequency frequency,
                    Date settlementDate,
                    Real accuracy,
                    Size maxIterations,
                    Rate guess) except +

    cdef Real cleanPrice(Bond bond,
                         Rate yld,
                         DayCounter dayCounter,
                         Compounding compounding,
                         Frequency frequency,
                         Date settlementDate) except +

    cdef Real basisPointValue(Bond bond,
                        Rate yld,
                        DayCounter dayCounter,
                        Compounding compounding,
                        Frequency frequency,
                        Date settlementDate) except +

    cdef Real convexity(Bond bond,
                        Rate yld,
                        DayCounter dayCounter,
                        Compounding compounding,
                        Frequency frequency,
                        Date settlementDate) except +


    cdef Spread zSpread(Bond bond,
                        Bond.Price Price,
                shared_ptr[YieldTermStructure],
                DayCounter dayCounter,
                Compounding compounding,
                Frequency frequency,
                Date settlementDate,
                Real accuracy,
                Size maxIterations,
                Rate guess) except +
