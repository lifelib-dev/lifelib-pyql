"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from lifelib_pyql.types cimport Rate, Real, Spread

from lifelib_pyql.handle cimport shared_ptr, optional
from lifelib_pyql.time._calendar cimport BusinessDayConvention, Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._schedule cimport Schedule
from ._fixedvsfloatingswap cimport FixedVsFloatingSwap
from .swap cimport Type
from lifelib_pyql.indexes._ibor_index cimport IborIndex

cdef extern from 'ql/instruments/vanillaswap.hpp' namespace 'QuantLib':
    cdef cppclass VanillaSwap(FixedVsFloatingSwap):
        VanillaSwap(Type type,
                    Real nominal,
                    Schedule& fixedSchedule,
                    Rate fixedRate,
                    DayCounter& fixedDayCount,
                    Schedule& floatSchedule,
                    shared_ptr[IborIndex] iborIndex,
                    Spread spread,
                    DayCounter& floatingDayCount,
                    optional[BusinessDayConvention] paymentConvention)
