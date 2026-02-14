include '../types.pxi'
from lifelib_pyql.handle cimport Handle
from lifelib_pyql._quote cimport Quote
from ._coupon_pricer cimport CmsCouponPricer
from lifelib_pyql.termstructures.volatility.swaption._swaption_vol_structure \
    cimport SwaptionVolatilityStructure
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/cashflows/lineartsrpricer.hpp' namespace 'QuantLib':
    cdef cppclass LinearTsrPricer(CmsCouponPricer):
        cppclass Settings:
            Settings()
            Settings &withRateBound(const Real lowerRateBound,# = defaultLowerBound,
                                    const Real upperRateBound)# = defaultUpperBound

            Settings &withVegaRatio(const Real vegaRatio) # = 0.01

            Settings &withVegaRatio(const Real vegaRatio,
                                    const Real lowerRateBound,
                                    const Real upperRateBound)

            Settings &withPriceThreshold(const Real priceThreshold) # = 1.0E-8

            Settings &withPriceThreshold(const Real priceThreshold,
                                         const Real lowerRateBound,
                                         const Real upperRateBound)

            Settings &withBSStdDevs(const Real stdDevs) # = 3.0

            Settings &withBSStdDevs(const Real stdDevs,
                                    const Real lowerRateBound,
                                    const Real upperRateBound)

            enum Strategy:
                RateBound
                VegaRatio
                PriceThreshold
                BSStdDevs
        LinearTsrPricer(const Handle[SwaptionVolatilityStructure] &swaptionVol,
                        const Handle[Quote] &meanReversion,
                        const Handle[YieldTermStructure] &couponDiscountCurve,
                        # = Handle[YieldTermStructure](),
                        const Settings &settings) #= Settings(),
                        #const shared_ptr[Integrator] &integrator)
                        # = boost::shared_ptr<Integrator>());
