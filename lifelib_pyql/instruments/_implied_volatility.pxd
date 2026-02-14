"""
 Copyright (C) 2015, Enthought Inc
 Copyright (C) 2015, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from lifelib_pyql.types cimport Natural, Real, Volatility
from lifelib_pyql.handle cimport Handle, shared_ptr
cimport lifelib_pyql.termstructures._yield_term_structure as _yts
cimport lifelib_pyql.time._daycounter as _dc
from lifelib_pyql.quotes._simplequote cimport SimpleQuote
cimport lifelib_pyql._instrument as _ins
cimport lifelib_pyql.pricingengines._pricing_engine as _pe


cimport lifelib_pyql.processes._black_scholes_process as _bs

cdef extern from 'ql/instruments/impliedvolatility.hpp' namespace 'QuantLib::detail':

    cdef cppclass ImpliedVolatilityHelper:
        pass

    # The returned process is equal to the passed one, except
    # for the volatility which is flat and whose value is driven
    # by the passed quote.

    cdef shared_ptr[_bs.GeneralizedBlackScholesProcess] IVH_clone \
         'QuantLib::detail::ImpliedVolatilityHelper::clone'(
                     shared_ptr[_bs.GeneralizedBlackScholesProcess]& process,
                     shared_ptr[SimpleQuote]& quote) except +

    # QuantLib::ImpliedVolatilityHelper static methods
    cdef Volatility IVH_calculate \
         'QuantLib::detail::ImpliedVolatilityHelper::calculate'(_ins.Instrument& instrument,
                             _pe.PricingEngine& engine,
                             SimpleQuote& volQuote,
                             Real targetValue,
                             Real accuracy,
                             Natural maxEvaluations,
                             Volatility minVol,
                             Volatility maxVol) except +
