from lifelib_pyql.types cimport Integer, Natural, Spread

from libcpp cimport bool

from lifelib_pyql._quote cimport Quote
from lifelib_pyql.cashflows.rateaveraging cimport RateAveraging
from lifelib_pyql.cashflows._coupon_pricer cimport FloatingRateCouponPricer
from lifelib_pyql.handle cimport shared_ptr, Handle, optional
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period, Frequency
from lifelib_pyql.termstructures.helpers cimport Pillar
from lifelib_pyql.termstructures.yields._rate_helpers cimport RateHelper, RelativeDateRateHelper
from lifelib_pyql.indexes._ibor_index cimport OvernightIndex
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention

from .._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/termstructures/yield/oisratehelper.hpp' namespace 'QuantLib':
    cdef cppclass OISRateHelper(RelativeDateRateHelper):
        OISRateHelper(Natural settlementDays,
                      Period& tenor, # swap maturity
                      Handle[Quote]& fixedRate,
                      shared_ptr[OvernightIndex]& overnightIndex,
                      # exogenous discounting curve
                      Handle[YieldTermStructure]& discountingCurve, # = Handle<YieldTermStructure>()
                      bool telescopicValueDates, # False)
                      Integer paymentLag, # = 0
                      BusinessDayConvention paymentConvention, # = Following
                      Frequency paymentFrequency, #  = Annual
                      Calendar& paymentCalendar, # = Calendar()
                      Period& forwardStart, # = 0 * Days
                      Spread overnightSpread,
                      Pillar pillar, # = Pillar::LastRelevantDate,
                      Date customPillarDate, # = Date(),
                      RateAveraging averagingMethod,# = RateAveraging::Compound,
                      optional[bool] endOfMonth, # = boost::none
                      optional[Frequency] fixedPaymentFrequency, # = ext::nullopt,
                      Calendar fixedCalendar, # = Calendar(),
                      Natural lookbackDays, # = Null<Natural>(),
                      Natural lockoutDays, # = 0,
                      bool applyObservationShift,# = false,
                      #shared_ptr[FloatingRateCouponPricer] pricer
        ) except + # = 0.0
cdef extern from 'ql/termstructures/yield/oisratehelper.hpp' namespace 'QuantLib':
        OISRateHelper* OISRateHelper_ "new QuantLib::OISRateHelper" (
            Date startDate,
            Date endDate,
            Handle[Quote]& fixedRate,
            shared_ptr[OvernightIndex]& overnightIndex,
            # exogenous discounting curve
            Handle[YieldTermStructure]& discountingCurve, # = Handle<YieldTermStructure>()
            bool telescopicValueDates, # False)
            Integer paymentLag, # = 0
            BusinessDayConvention paymentConvention, # = Following
            Frequency paymentFrequency, #  = Annual
            Calendar& paymentCalendar, # = Calendar()
            Spread overnightSpread,
            Pillar pillar, # = Pillar::LastRelevantDate,
            Date customPillarDate, # = Date(),
            RateAveraging averagingMethod,# = RateAveraging::Compound,
            optional[bool] endOfMonth, # = boost::none
            optional[Frequency] fixedPaymentFrequency, # = ext::nullopt,
            Calendar fixedCalendar, # = Calendar(),
            Natural lookbackDays, # = Null<Natural>(),
            Natural lockoutDays, # = 0,
            bool applyObservationShift,# = false,
            #shared_ptr[FloatingRateCouponPricer] pricer
        ) except + # = 0.0

    # cdef cppclass DatedOISRateHelper(RateHelper):
    #     DatedOISRateHelper(
    #         Date& startDate,
    #         Date& endDate,
    #         Handle[Quote]& fixedRate,
    #         shared_ptr[OvernightIndex]& overnightIndex,
    #         # exogenous discounting curve
    #         Handle[YieldTermStructure] discountingCurve,# = Handle<YieldTermStructure>(),
    #         bool telescopicValueDates, #= false,
    #         RateAveraging averagingMethod #= RateAveraging::Compound)
    #     ) except +
