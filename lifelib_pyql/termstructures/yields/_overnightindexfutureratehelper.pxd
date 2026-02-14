from lifelib_pyql.types cimport Real
from lifelib_pyql.cashflows.rateaveraging cimport RateAveraging
from ._rate_helpers cimport RateHelper
from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.indexes._ibor_index cimport OvernightIndex
from lifelib_pyql.time._date cimport Date, Month, Year
from lifelib_pyql.time.frequency cimport Frequency
from lifelib_pyql._quote cimport Quote

cdef extern from 'ql/termstructures/yield/overnightindexfutureratehelper.hpp' namespace 'QuantLib':
    cdef cppclass OvernightIndexFutureRateHelper(RateHelper):
        OvernightIndexFutureRateHelper(
            Handle[Quote]& price,
            Date& value_date, # first day of reference period
            Date& maturity_date, # delivery Date
            shared_ptr[OvernightIndex] overnightIndex,
            Handle[Quote] convexityAdjustment, # = Handle[Quote](),
            RateAveraging averagingMethod)# = RateAveraging.Compound);

        Real convexityAdjustment()

    cdef cppclass SofrFutureRateHelper(OvernightIndexFutureRateHelper):
        SofrFutureRateHelper(Handle[Quote]& price,
                             Month referenceMonth,
                             Year referenceYear,
                             Frequency referenceFreq,
                             Handle[Quote]& convexityAdjustment) # = Handle<Quote>(),
        SofrFutureRateHelper(Real price,
                             Month referenceMonth,
                             Year referenceYear,
                             Frequency referenceFreq,
                             Real convexityAdjustment) # = 0,
