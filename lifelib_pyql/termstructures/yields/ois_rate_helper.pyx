from lifelib_pyql.types cimport Integer, Natural, Spread

from libcpp cimport bool

from cython.operator cimport dereference as deref
from lifelib_pyql.cashflows.rateaveraging cimport RateAveraging
from lifelib_pyql.cashflows.coupon_pricer cimport FloatingRateCouponPricer
from lifelib_pyql.termstructures.helpers cimport Pillar
from lifelib_pyql.handle cimport shared_ptr, static_pointer_cast, Handle, optional
from lifelib_pyql.quote cimport Quote
from lifelib_pyql.time.date cimport Date, Period
from lifelib_pyql.termstructures.yields.rate_helpers cimport RelativeDateRateHelper, RateHelper
from lifelib_pyql.indexes.ibor_index cimport OvernightIndex
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.utilities.null cimport Null

from . cimport _ois_rate_helper as _orh
from . cimport _rate_helpers as _rh
cimport lifelib_pyql._quote as _qt
cimport lifelib_pyql.indexes._ibor_index as _ib
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention, Following
from lifelib_pyql.time._period cimport Frequency, Days

cdef class OISRateHelper(RelativeDateRateHelper):

    def __init__(self,
                 Natural settlement_days,
                 Period tenor not None, # swap maturity
                 Quote fixed_rate not None,
                 OvernightIndex overnight_index not None,
                 # exogenous discounting curve
                 HandleYieldTermStructure discounting_curve not None=HandleYieldTermStructure(),
                 bool telescopic_value_dates = False,
                 Integer payment_lag=0,
                 BusinessDayConvention payment_convention = Following,
                 Frequency payment_frequency = Frequency.Annual,
                 Calendar payment_calendar = Calendar(),
                 Period forward_start = Period(0, Days),
                 Spread overnight_spread = 0.0,
                 Pillar pillar=Pillar.LastRelevantDate,
                 Date custom_pillar_date=Date(),
                 RateAveraging averaging_method=RateAveraging.Compound,
                 end_of_month=None,
                 fixed_payment_frequency=None,
                 Calendar fixed_calendar=Calendar(),
                 Natural lookback_days=Null[Natural](),
                 Natural lockout_days=0,
                 bool apply_observation_shift=False,
                 #FloatingRateCouponPricer pricer=FloatingRateCouponPricer()
                 ):
        cdef:
            optional[bool] end_of_month_opt
            optional[Frequency] fixed_payment_frequency_opt
        if end_of_month is not None:
            end_of_month_opt = <bool>end_of_month
        if fixed_payment_frequency is not None:
            fixed_payment_frequency_opt = <Frequency>fixed_payment_frequency

        self._thisptr.reset(
            new _orh.OISRateHelper(
                settlement_days,
                deref(tenor._thisptr),
                fixed_rate.handle(),
                static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
                discounting_curve.handle,
                telescopic_value_dates,
                payment_lag,
                <_rh.BusinessDayConvention> payment_convention,
                <Frequency> payment_frequency,
                payment_calendar._thisptr,
                deref(forward_start._thisptr),
                overnight_spread,
                pillar,
                custom_pillar_date._thisptr,
                averaging_method,
                end_of_month_opt,
                fixed_payment_frequency_opt,
                fixed_calendar._thisptr,
                lookback_days,
                lockout_days,
                apply_observation_shift,
                #pricer._thisptr
            )
        )
    @classmethod
    def from_dates(cls, Date start_date not None,
                 Date end_date not None,
                 Quote fixed_rate not None,
                 OvernightIndex overnight_index not None,
                 # exogenous discounting curve
                 HandleYieldTermStructure discounting_curve not None=HandleYieldTermStructure(),
                 bool telescopic_value_dates = False,
                 Integer payment_lag=0,
                 BusinessDayConvention payment_convention = Following,
                 Frequency payment_frequency = Frequency.Annual,
                 Calendar payment_calendar = Calendar(),
                 Spread overnight_spread = 0.0,
                 Pillar pillar=Pillar.LastRelevantDate,
                 Date custom_pillar_date=Date(),
                 RateAveraging averaging_method=RateAveraging.Compound,
                 end_of_month=None,
                 fixed_payment_frequency=None,
                 Calendar fixed_calendar=Calendar(),
                 Natural lookback_days=Null[Natural](),
                 Natural lockout_days=0,
                 bool apply_observation_shift=False):
        cdef OISRateHelper instance = OISRateHelper.__new__(OISRateHelper)
        cdef:
            optional[bool] end_of_month_opt
            optional[Frequency] fixed_payment_frequency_opt
        if end_of_month is not None:
            end_of_month_opt = <bool>end_of_month
        if fixed_payment_frequency is not None:
            fixed_payment_frequency_opt = <Frequency>fixed_payment_frequency
        instance._thisptr.reset(
            _orh.OISRateHelper_(
                start_date._thisptr,
                end_date._thisptr,
                fixed_rate.handle(),
                static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
                discounting_curve.handle,
                telescopic_value_dates,
                payment_lag,
                <_rh.BusinessDayConvention> payment_convention,
                <Frequency> payment_frequency,
                payment_calendar._thisptr,
                overnight_spread,
                pillar,
                custom_pillar_date._thisptr,
                averaging_method,
                end_of_month_opt,
                fixed_payment_frequency_opt,
                fixed_calendar._thisptr,
                lookback_days,
                lockout_days,
                apply_observation_shift,
                #pricer._thisptr
            )
        )
        return instance

# cdef class DatedOISRateHelper(RateHelper):

#     def __init__(self,
#                  Date start_date not None,
#                  Date end_date not None,
#                  Quote fixed_rate not None,
#                  OvernightIndex overnight_index not None,
#                  # exogenous discounting curve
#                  HandleYieldTermStructure discounting_curve not None=HandleYieldTermStructure(),
#                  bool telescopic_value_dates = False,
#                  RateAveraging averaging_method=RateAveraging.Compound,
#                  ):
#         self._thisptr = shared_ptr[_rh.RateHelper](
#             new _orh.DatedOISRateHelper(
#                 start_date._thisptr,
#                 end_date._thisptr,
#                 fixed_rate.handle(),
#                 static_pointer_cast[_ib.OvernightIndex](overnight_index._thisptr),
#                 discounting_curve.handle,
#                 telescopic_value_dates,
#                 averaging_method
#             )
#         )
