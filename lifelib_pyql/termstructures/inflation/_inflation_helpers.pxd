from lifelib_pyql._quote cimport Quote
from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._period cimport Period

from lifelib_pyql.indexes._inflation_index cimport (
    YoYInflationIndex, ZeroInflationIndex, CPI)
from lifelib_pyql.termstructures.inflation.inflation_traits cimport (
    ZeroInflationTraits, YoYInflationTraits)

cimport lifelib_pyql.termstructures._inflation_term_structure as _its
cimport lifelib_pyql.termstructures._yield_term_structure as _yts

cdef extern from 'ql/termstructures/inflation/inflationhelpers.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ZeroCouponInflationSwapHelper(ZeroInflationTraits.helper):
        ZeroCouponInflationSwapHelper(
            const Handle[Quote]& quote,
            const Period& swap_obs_lag,  # lag on swap observation of index
            const Date& maturity,
            const Calendar& calendar,  #index may have null calendar as valid on every day
            BusinessDayConvention payment_convention,
            const DayCounter& day_counter,
            const shared_ptr[ZeroInflationIndex]& zii,
            CPI.InterpolationType observationInterpolation,
            const Handle[_yts.YieldTermStructure]& nominal_term_structure) except +

    # Year-on-year inflation-swap bootstrap helper
    cdef cppclass YearOnYearInflationSwapHelper(YoYInflationTraits.helper):
        YearOnYearInflationSwapHelper(
            const Handle[Quote]& quote,
            const Period& swap_obs_lag,
            const Date& maturity,
            const Calendar& calendar,
            BusinessDayConvention payment_convention,
            const DayCounter& day_counter,
            const shared_ptr[YoYInflationIndex]& yii,
            CPI.InterpolationType interpolation,
            const Handle[_yts.YieldTermStructure]& nominal_term_structure) except +
