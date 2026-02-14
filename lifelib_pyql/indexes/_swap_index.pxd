"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'
from libcpp cimport bool
from libcpp.string cimport string

from lifelib_pyql.currency._currency cimport Currency
from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.indexes._interest_rate_index cimport InterestRateIndex
from lifelib_pyql.indexes._ibor_index cimport IborIndex, OvernightIndex
from lifelib_pyql.instruments._vanillaswap cimport VanillaSwap
from lifelib_pyql.instruments._overnightindexedswap cimport OvernightIndexedSwap
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.time._calendar cimport BusinessDayConvention
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.cashflows.rateaveraging cimport RateAveraging

cdef extern from 'ql/indexes/swapindex.hpp' namespace 'QuantLib' nogil:

    cdef cppclass SwapIndex(InterestRateIndex):
        SwapIndex(string& familyName,
                  Period& tenor,
                  Natural settlementDays,
                  Currency currency,
                  Calendar& calendar,
                  Period& fixedLegTenor,
                  BusinessDayConvention fixedLegConvention,
                  DayCounter& fixedLegDayCounter,
                  shared_ptr[IborIndex]& iborIndex)
        SwapIndex(const string& familyName,
                  const Period& tenor,
                  Natural settlementDays,
                  Currency currency,
                  const Calendar& fixingCalendar,
                  const Period& fixedLegTenor,
                  BusinessDayConvention fixedLegConvention,
                  const DayCounter& fixedLegDayCounter,
                  const shared_ptr[IborIndex]& iborIndex,
                  const Handle[YieldTermStructure]& discountingTermStructure)
        shared_ptr[VanillaSwap] underlyingSwap(const Date& fixingDate)
        shared_ptr[IborIndex] iborIndex()
        Handle[YieldTermStructure] forwardingTermStructure() except +
        Handle[YieldTermStructure] discountingTermStructure() except +

    cdef cppclass OvernightIndexedSwapIndex(SwapIndex):
        OvernightIndexedSwapIndex(string& familyName,
                                  Period& tenor,
                                  Natural settlementDays,
                                  Currency currency,
                                  shared_ptr[OvernightIndex]& overnightIndex,
                                  bool telescopic_value_dates, # = False
                                  RateAveraging averaging_method) # = RateAveraing.Compound
        shared_ptr[OvernightIndex] overnight_index()
        shared_ptr[OvernightIndexedSwap] underlying_swap(const Date& fixing_date)
