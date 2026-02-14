include '../../types.pxi'

from libcpp cimport bool
from libcpp.vector cimport vector

from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.instruments._dividendschedule cimport DividendSchedule
from lifelib_pyql.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from lifelib_pyql.models.shortrate.onefactormodels._hullwhite cimport HullWhite
from lifelib_pyql.processes._hullwhite_process cimport HullWhiteProcess
from lifelib_pyql.models.equity._heston_model cimport HestonModel
from lifelib_pyql.models.equity._bates_model cimport (BatesModel, BatesDetJumpModel, BatesDoubleExpModel, BatesDoubleExpDetJumpModel)

from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from ._analytic_heston_engine cimport AnalyticHestonEngine
from lifelib_pyql.methods.finitedifferences.solvers._fdmbackwardsolver cimport FdmSchemeDesc

cdef extern from 'ql/pricingengines/vanilla/analyticeuropeanengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticEuropeanEngine(PricingEngine):
        AnalyticEuropeanEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process
        )

cdef extern from 'ql/pricingengines/vanilla/baroneadesiwhaleyengine.hpp' namespace 'QuantLib':

    cdef cppclass BaroneAdesiWhaleyApproximationEngine(PricingEngine):
        BaroneAdesiWhaleyApproximationEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process
        )


cdef extern from 'ql/pricingengines/vanilla/analyticbsmhullwhiteengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticBSMHullWhiteEngine(PricingEngine):
        AnalyticBSMHullWhiteEngine(
            Real equity_short_rate_correlation,
            shared_ptr[GeneralizedBlackScholesProcess]& process,
            shared_ptr[HullWhite]& hw_model)

cdef extern from 'ql/pricingengines/vanilla/analytichestonhullwhiteengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticHestonHullWhiteEngine(PricingEngine):
        AnalyticHestonHullWhiteEngine(
            shared_ptr[HestonModel]& heston_model,
            shared_ptr[HullWhite]& hw_model,
            Size integrationOrder
        )

cdef extern from 'ql/pricingengines/vanilla/fdhestonhullwhitevanillaengine.hpp' namespace 'QuantLib':

    cdef cppclass FdHestonHullWhiteVanillaEngine(PricingEngine):
        FdHestonHullWhiteVanillaEngine(
            shared_ptr[HestonModel]& heston_model,
            shared_ptr[HullWhiteProcess]& hw_process,
            Real corrEquityShortRate,
            Size tGrid, Size xGrid,
            Size vGrid, Size rGrid,
            Size dampingSteps,
            bool controlVariate,
            FdmSchemeDesc& schemeDesc
        )

        FdHestonHullWhiteVanillaEngine(
            shared_ptr[HestonModel]& heston_model,
            shared_ptr[HullWhiteProcess]& hw_process,
            DividendSchedule dividends,
            Real corrEquityShortRate,
            Size tGrid, Size xGrid,
            Size vGrid, Size rGrid,
            Size dampingSteps,
            bool controlVariate,
            FdmSchemeDesc& schemeDesc
        )

        void enableMultipleStrikesCaching(vector[double]&)


cdef extern from 'ql/pricingengines/vanilla/batesengine.hpp' namespace 'QuantLib':

    cdef cppclass BatesEngine(AnalyticHestonEngine):
        BatesEngine(
            shared_ptr[BatesModel]& model,
            Size integrationOrder
        )

    cdef cppclass BatesDetJumpEngine(BatesEngine):
        BatesDetJumpEngine(
            shared_ptr[BatesDetJumpModel]& model,
            Size integrationOrder
        )
        BatesDetJumpEngine(
            shared_ptr[BatesDetJumpModel]& model,
            Real relTolerance,
            Size integrationOrder
        )

    cdef cppclass BatesDoubleExpEngine(AnalyticHestonEngine):
        BatesDoubleExpEngine(
            shared_ptr[BatesDoubleExpModel]& model,
            Size integrationOrder
        )
        BatesDoubleExpEngine(
            shared_ptr[BatesDoubleExpModel]& model,
            Real relTolerance,
            Size integrationOrder
        )

    cdef cppclass BatesDoubleExpDetJumpEngine(BatesDoubleExpEngine):
        BatesDoubleExpDetJumpEngine(
            shared_ptr[BatesDoubleExpDetJumpModel]& model,
            Size integrationOrder
        )
        BatesDoubleExpDetJumpEngine(
            shared_ptr[BatesDoubleExpDetJumpModel]& model,
            Real relTolerance,
            Size integrationOrder
        )

cdef extern from 'ql/pricingengines/vanilla/analyticdividendeuropeanengine.hpp' namespace 'QuantLib':

    cdef cppclass AnalyticDividendEuropeanEngine(PricingEngine):
        AnalyticDividendEuropeanEngine(
            shared_ptr[GeneralizedBlackScholesProcess]& process,
            DividendSchedule dividends
        )
        void calculate()
