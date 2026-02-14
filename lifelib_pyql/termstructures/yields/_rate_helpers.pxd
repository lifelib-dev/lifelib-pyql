"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp cimport bool

from lifelib_pyql.handle cimport shared_ptr, Handle, RelinkableHandle
from lifelib_pyql._quote cimport Quote
from lifelib_pyql.time._calendar cimport BusinessDayConvention, Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._period cimport Period, Frequency
from ._flat_forward cimport YieldTermStructure
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.indexes._swap_index cimport SwapIndex
from lifelib_pyql.instruments._vanillaswap cimport VanillaSwap

from lifelib_pyql.termstructures._helpers cimport BootstrapHelper, \
                                              RelativeDateBootstrapHelper
from lifelib_pyql.instruments.futures cimport FuturesType

from ..helpers cimport Pillar

cdef extern from 'ql/termstructures/yield/ratehelpers.hpp' namespace 'QuantLib' nogil:
    ctypedef BootstrapHelper[YieldTermStructure] RateHelper
    ctypedef RelativeDateBootstrapHelper[YieldTermStructure] RelativeDateRateHelper

    cdef cppclass DepositRateHelper(RateHelper):
        DepositRateHelper(Handle[Quote]& rate,
                          Period& tenor,
                          Natural fixingDays,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter) except +
        DepositRateHelper(Rate rate,
                          Period& tenor,
                          Natural fixingDays,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter) except +

        DepositRateHelper(Handle[Quote]& rate,
                          shared_ptr[IborIndex]& iborIndex) except +
        DepositRateHelper(Rate rate,
                          shared_ptr[IborIndex]& iborIndex) except +

    cdef cppclass FraRateHelper(RelativeDateRateHelper):
        FraRateHelper(Handle[Quote]& rate,
                      Natural monthsToStart,
                      Natural monthsToEnd,
                      Natural fixingDays,
                      Calendar& calendar,
                      BusinessDayConvention convention,
                      bool endOfMonth,
                      DayCounter& dayCounter,
                      Pillar pillar, # = Pillar::LastRelevantDate,
                      Date customPillarDate, # = Date(),
                      bool useIndexedCoupon) except + # = true)
        FraRateHelper(Rate rate,
                      Natural monthsToStart,
                      Natural monthsToEnd,
                      Natural fixingDays,
                      Calendar& calendar,
                      BusinessDayConvention convention,
                      bool endOfMonth,
                      DayCounter& dayCounter,
                      Pillar pillar, #= Pillar::LastRelevantDate,
                      Date customPillarDate, # = Date(),
                      bool useIndexedCoupon) except + # = true
        FraRateHelper(const Handle[Quote]& rate,
                      Natural monthsToStart,
                      const shared_ptr[IborIndex]& iborIndex,
                      Pillar pillar, #= Pillar::LastRelevantDate,
                      Date customPillarDate, # = Date(),
                      bool useIndexedCoupon) except + # = true
        FraRateHelper(Rate rate,
                      Natural monthsToStart,
                      const shared_ptr[IborIndex]& iborIndex,
                      Pillar pillar, #= Pillar::LastRelevantDate,
                      Date customPillarDate, # = Date(),
                      bool useIndexedCoupon) except + # = true

    cdef cppclass SwapRateHelper(RelativeDateRateHelper):
        SwapRateHelper(Handle[Quote]& rate,
                       Period& tenor,
                       Calendar& calendar,
                       Frequency& fixedFrequency,
                       BusinessDayConvention fixedConvention,
                       DayCounter& fixedDayCount,
                       shared_ptr[IborIndex]& iborIndex,
                       Handle[Quote]& spread,
                       Period& fwdStart,
                       Handle[YieldTermStructure] discountingCurve, #= Handle<YieldTermStructure>(),
                       Natural settlementDays,# = Null<Natural>(),
                       Pillar pillar, #= Pillar::LastRelevantDate,
                       Date customPillarDate, # = Date(),
                       bool endOfMonth # = false);
        ) except +
        SwapRateHelper(Rate rate,
                       Period& tenor,
                       Calendar& calendar,
                       Frequency& fixedFrequency,
                       BusinessDayConvention fixedConvention,
                       DayCounter& fixedDayCount,
                       shared_ptr[IborIndex]& iborIndex,
                       Handle[Quote]& spread,
                       Period& fwdStart,
                       Handle[YieldTermStructure] discountingCurve, #= Handle<YieldTermStructure>(),
                       Natural settlementDays,# = Null<Natural>(),
                       Pillar pillar, #= Pillar::LastRelevantDate,
                       Date customPillarDate, # = Date(),
                       bool endOfMonth # = false);
        ) except +
        SwapRateHelper(Handle[Quote]& rate,
                       shared_ptr[SwapIndex]& swapIndex,
                       Handle[Quote]& spread, # = Handle<Quote>(),
                       Period& fwdStart, # = 0*Days,
                       # exogenous discounting curve
                       Handle[YieldTermStructure] discountingCurve, #= Handle<YieldTermStructure>()
                       Pillar pillar, # = Pillar::LastRelevantDate,
                       Date customPillarDate, #= Date(),
                       bool endOfMonth #= false
        ) except +
        SwapRateHelper(Rate rate,
                       shared_ptr[SwapIndex]& swapIndex,
                       Handle[Quote]& spread, # = Handle<Quote>(),
                       Period& fwdStart, # = 0*Days,
                       # exogenous discounting curve
                       Handle[YieldTermStructure] discountingCurve, #= Handle<YieldTermStructure>()
                       Pillar pillar, # = Pillar::LastRelevantDate,
                       Date customPillarDate, #= Date(),
                       bool endOfMonth #= false
        ) except +
        Spread spread()
        shared_ptr[VanillaSwap] swap()
        Period& forwardStart()

    cdef cppclass FuturesRateHelper(RateHelper):
        FuturesRateHelper(Handle[Quote]& price,
                          Date& immDate,
                          Natural lengthInMonths,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter,
                          Handle[Quote]& convexity_adjustment,
                          FuturesType type # = Futures::IMM);
        ) except +
        FuturesRateHelper(Real price,
                          Date& immDate,
                          Natural lengthInMonths,
                          Calendar& calendar,
                          BusinessDayConvention convention,
                          bool endOfMonth,
                          DayCounter& dayCounter,
                          Rate convexity_adjustment,
                          FuturesType type # = Futures::IMM);
        ) except +
        FuturesRateHelper(const Handle[Quote]& price,
                          const Date& iborStartDate,
                          const shared_ptr[IborIndex]& iborIndex,
                          const Handle[Quote]& convexityAdjustment,# = Handle<Quote>(),
                          FuturesType type # = Futures::IMM);
        ) except +
        FuturesRateHelper(Real price,
                          const Date& iborStartDate,
                          const shared_ptr[IborIndex]& iborIndex,
                          Rate convexityAdjustment, # = 0.0,
                          FuturesType type# = Futures::IMM)
        ) except +
        Real convexityAdjustment() const


    cdef cppclass FxSwapRateHelper(RelativeDateRateHelper):
        FxSwapRateHelper(const Handle[Quote]& fwdPoint,
                         Handle[Quote] spotFx,
                         const Period& tenor,
                         Natural fixingDays,
                         Calendar calendar,
                         BusinessDayConvention convention,
                         bool endOfMonth,
                         bool isFxBaseCurrencyCollateralCurrency,
                         Handle[YieldTermStructure] collateralCurve,
                         Calendar tradingCalendar)# = Calendar());

        Real spot()
        Period tenor()
        Natural fixingDays()
        Calendar calendar()
        BusinessDayConvention businessDayConvention()
        bool endOfMonth()
        bool isFxBaseCurrencyCollateralCurrency()
        Calendar tradingCalendar()
        Calendar adjustmentCalendar()
