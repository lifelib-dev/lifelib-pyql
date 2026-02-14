from lifelib_pyql.types cimport Natural, Real

from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from ._bond cimport Bond
from ._forward cimport Forward
from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.position cimport Position

cdef extern from "ql/instruments/bondforward.hpp" namespace "QuantLib" nogil:

    cdef cppclass BondForward(Forward):
         BondForward(
            const Date& valueDate,
            const Date& maturityDate,
            Position type,
            Real strike,
            Natural settlementDays,
            const DayCounter& dayCounter,
            const Calendar& calendar,
            BusinessDayConvention businessDayConvention,
            const shared_ptr[Bond]& bond,
            const Handle[YieldTermStructure]& discountCurve, # = Handle[YieldTermStructure](),
            const Handle[YieldTermStructure]& incomeDiscountCurve) # = Handle[YieldTermStructure]())

         Real forwardPrice() const

         Real cleanForwardPrice() const
