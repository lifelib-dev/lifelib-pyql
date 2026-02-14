from libcpp.vector cimport vector
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time.frequency cimport Frequency

from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql._quote cimport Quote
from lifelib_pyql.math._interpolations cimport Linear
from lifelib_pyql.compounding cimport Compounding

cdef extern from 'ql/termstructures/yield/piecewisezerospreadedtermstructure.hpp' namespace 'QuantLib':
    cdef cppclass InterpolatedPiecewiseZeroSpreadedTermStructure[I](YieldTermStructure):
        InterpolatedPiecewiseZeroSpreadedTermStructure(
            const Handle[YieldTermStructure]&,
            const vector[Handle[Quote]]& spreads,
            const vector[Date]& dates,
            Compounding comp, # = Continuous,
            Frequency freq, # = NoFrequency,
            const DayCounter& dc), # = DayCounter(),
            #const Interpolator& factory) # = Interpolator())
    ctypedef InterpolatedPiecewiseZeroSpreadedTermStructure[Linear] PiecewiseZeroSpreadedTermStructure
