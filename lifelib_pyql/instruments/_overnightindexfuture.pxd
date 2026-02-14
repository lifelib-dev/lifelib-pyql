from libcpp cimport bool
from lifelib_pyql.types cimport Real
from lifelib_pyql.cashflows.rateaveraging cimport RateAveraging
from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.indexes._ibor_index cimport OvernightIndex
from lifelib_pyql._instrument cimport Instrument
from lifelib_pyql._quote cimport Quote
from lifelib_pyql.time._date cimport Date

cdef extern from 'ql/instruments/overnightindexfuture.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexFuture(Instrument):

        OvernightIndexFuture(
            shared_ptr[OvernightIndex] overnightIndex,
            const Date& valueDate,
            const Date& maturityDate,
            Handle[Quote] convexityAdjustment, # = Handle[Quote](),
            RateAveraging averagingMethod)# = RateAveraging.Compound);

        Real convexityAdjustment()
        bool isExpired()
