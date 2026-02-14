from libcpp cimport bool
from libcpp.vector cimport vector
from lifelib_pyql.types cimport DiscountFactor, Real, Size, Time

from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.option cimport OptionType
from lifelib_pyql._numericalmethod cimport Lattice
from lifelib_pyql._time_grid cimport TimeGrid
from lifelib_pyql.math._optimization cimport Constraint, EndCriteria, OptimizationMethod
from lifelib_pyql.math._array cimport Array
from ._calibration_helper cimport CalibrationHelper

cdef extern from 'ql/models/model.hpp' namespace 'QuantLib' nogil:

    cdef cppclass CalibratedModel:
        void calibrate(
                const vector[shared_ptr[CalibrationHelper]]&,
                OptimizationMethod& method,
                const EndCriteria& endCriteria,
                const Constraint& constraint,# = Constraint(),
                const vector[Real]& weights, # = std::vector<Real>(),
                const vector[bool]& fixParameters # = std::vector<bool>());
            )
        Array& params()
        void setParams(Array& params)

    cdef cppclass TermStructureConsistentModel:
        TermStructureConsistentModel(Handle[YieldTermStructure] termstructure)
        const Handle[YieldTermStructure] termStructure() const

    cdef cppclass AffineModel:
        DiscountFactor discount(Time t)
        Real discountBond(Time now, Time maturity, Array factors)
        Real discountBondOption(OptionType type, Real strike, Time maturity, Time bondMaturity)
        #Real discountBondOption(OptionType type, Real strike, Time maturity, Time bondStart, Time bondMaturity)

    cdef cppclass ShortRateModel(CalibratedModel):
        ShortRateModel(Size nArguments)
        shared_ptr[Lattice] tree(const TimeGrid&)
