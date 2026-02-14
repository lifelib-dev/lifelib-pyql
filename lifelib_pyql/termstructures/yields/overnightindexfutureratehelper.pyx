from lifelib_pyql.types cimport Real
from cython.operator cimport dereference as deref
from lifelib_pyql.handle cimport static_pointer_cast
from lifelib_pyql.cashflows.rateaveraging cimport RateAveraging
from lifelib_pyql.time.frequency cimport Frequency
from lifelib_pyql.quote cimport Quote
from lifelib_pyql.time.date cimport Date
from lifelib_pyql.time._date cimport Month, Year
from lifelib_pyql.indexes.ibor_index cimport OvernightIndex
cimport lifelib_pyql.indexes._ibor_index as _ii
from . cimport _overnightindexfutureratehelper as _oifrh

cdef class OvernightIndexFutureRateHelper(RateHelper):
    """ Future on a compounded overnight index investment.

    Compatible with SOFR futures and Sonia futures available on
    CME and ICE exchanges.
    """
    def __init__(self, Quote price, Date value_date, Date maturity_date, OvernightIndex overnight_index, Quote convexity_adjustment, RateAveraging averaging_method):
        self._thisptr.reset(
            new _oifrh.OvernightIndexFutureRateHelper(
                price.handle(),
                value_date._thisptr,
                maturity_date._thisptr,
                static_pointer_cast[_ii.OvernightIndex](overnight_index._thisptr),
                convexity_adjustment.handle(),
                averaging_method
            )
        )

cdef class SofrFutureRateHelper(OvernightIndexFutureRateHelper):
    def __init__(self, price, Month reference_month, Year reference_year, Frequency reference_freq, convexity_adjustment=0.0):
        if isinstance(price, float) and isinstance(convexity_adjustment, float):
            self._thisptr.reset(
                new _oifrh.SofrFutureRateHelper(
                    <Real>price,
                    reference_month,
                    reference_year,
                    reference_freq,
                    <Real>convexity_adjustment,
                )
            )
        elif isinstance(price, Quote) and isinstance(convexity_adjustment, Quote):
            self._thisptr.reset(
                new _oifrh.SofrFutureRateHelper(
                    (<Quote>price).handle(),
                    reference_month,
                    reference_year,
                    reference_freq,
                    (<Quote>convexity_adjustment).handle(),
                )
            )
