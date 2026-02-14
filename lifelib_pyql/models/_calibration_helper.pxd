from lifelib_pyql.types cimport Real, Size, Volatility
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.termstructures.volatility.volatilitytype cimport VolatilityType
from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql._quote cimport Quote

cdef extern from 'ql/models/calibrationhelper.hpp' namespace 'QuantLib':
    cdef cppclass CalibrationHelper:
        pass

    cdef cppclass BlackCalibrationHelper(CalibrationHelper):
        enum CalibrationErrorType:
            pass

        BlackCalibrationHelper(const Handle[Quote]& volatility,
                               CalibrationErrorType calibrationErrorType, #= RelativePriceError,
                               const VolatilityType type,# = ShiftedLognormal,
                               const Real shift) # = 0.0)

        Volatility impliedVolatility(
            Real targetValue,
            Real accuracy,
            Size maxEvaluation,
            Volatility minVol,
            Volatility maxVol) except +

        void setPricingEngine(shared_ptr[PricingEngine]& engine) except +

        Real blackPrice(Real volatility) except +

        Real marketValue() except +
        Real modelValue() except +
        Real calibrationError() except +


cdef extern from 'ql/models/calibrationhelper.hpp' namespace 'QuantLib::BlackCalibrationHelper':

    cdef enum CalibrationErrorType:
        RelativePriceError
        PriceError
        ImpliedVolError
