from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql._quote cimport Quote
from ._flat_forward cimport YieldTermStructure
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter


cdef extern from 'ql/termstructures/yield/forwardspreadedtermstructure.hpp' namespace 'QuantLib':

    cdef cppclass ForwardSpreadedTermStructure(YieldTermStructure):

        ForwardSpreadedTermStructure(
            Handle[YieldTermStructure]& yieldtermstruct,
            Handle[Quote]& spread
        ) except +
