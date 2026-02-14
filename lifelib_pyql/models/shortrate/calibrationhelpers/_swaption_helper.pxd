"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from lifelib_pyql.types cimport Real
from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.termstructures.volatility.volatilitytype cimport VolatilityType
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.models._calibration_helper cimport BlackCalibrationHelper, CalibrationErrorType
from lifelib_pyql.instruments._swaption cimport Swaption
from lifelib_pyql.instruments._fixedvsfloatingswap cimport FixedVsFloatingSwap
cimport lifelib_pyql._quote as _qt

cdef extern from 'ql/models/shortrate/calibrationhelpers/swaptionhelper.hpp' namespace 'QuantLib':

    cdef cppclass SwaptionHelper(BlackCalibrationHelper):

        SwaptionHelper(Period& maturity,
                       Period& length,
                       Handle[_qt.Quote]& volatility,
                       shared_ptr[IborIndex]& index,
                       Period& fixedLegTenor,
                       DayCounter& fixedLegDayCounter,
                       DayCounter& floatingLegDayCounter,
                       Handle[YieldTermStructure]& termStructure,
                       CalibrationErrorType errorType,
                       Real strike,
                       Real nominal,
                       VolatilityType type, # = ShiftedLognormal,
                       Real shift # = 0.0
                       ) except +
        shared_ptr[FixedVsFloatingSwap] underlying()
        shared_ptr[Swaption] swaption()

    # this should really be a constructor but cython can't disambiguate the
    # constructors otherwise
    SwaptionHelper* SwaptionHelper_ "new QuantLib::SwaptionHelper"(
        Date& maturity,
        Period& length,
        Handle[_qt.Quote]& volatility,
        shared_ptr[IborIndex]& index,
        Period& fixedLegTenor,
        DayCounter& fixedLegDayCounter,
        DayCounter& floatingLegDayCounter,
        Handle[YieldTermStructure]& termStructure,
        CalibrationErrorType errorType,
        Real strike,
        Real nominal,
        VolatilityType type, # = ShiftedLognormal,
        Real shift # = 0.0
    ) except +
    SwaptionHelper* SwaptionHelper2_ "new QuantLib::SwaptionHelper"(
        Date& maturity,
        Date& length,
        Handle[_qt.Quote]& volatility,
        shared_ptr[IborIndex]& index,
        Period& fixedLegTenor,
        DayCounter& fixedLegDayCounter,
        DayCounter& floatingLegDayCounter,
        Handle[YieldTermStructure]& termStructure,
        CalibrationErrorType errorType,
        Real strike,
        Real nominal,
        VolatilityType type, # = ShiftedLognormal,
        Real shift # = 0.0
    ) except +
