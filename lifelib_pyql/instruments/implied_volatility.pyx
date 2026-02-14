# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

"""Utilities for implied-volatility calculation"""

from lifelib_pyql.types cimport Natural, Real, Volatility
from cython.operator cimport dereference as deref
from lifelib_pyql.handle cimport shared_ptr, static_pointer_cast
from lifelib_pyql.instrument cimport Instrument
from lifelib_pyql.pricingengines.engine cimport PricingEngine
from lifelib_pyql.quotes.simplequote cimport SimpleQuote

cimport lifelib_pyql.instruments._implied_volatility as _iv
from lifelib_pyql.processes.black_scholes_process cimport GeneralizedBlackScholesProcess
cimport lifelib_pyql.processes._black_scholes_process as _bsp
cimport lifelib_pyql._stochastic_process as _sp
cimport lifelib_pyql.quotes._simplequote as _qt

cdef class ImpliedVolatilityHelper:
    def __cinit__(self):
        pass

    def __init__(self):
        raise ValueError('Cannot instantiate an ImpliedVolatilityHelper')


    @classmethod
    def calculate(self, Instrument instrument,
              PricingEngine engine,
              SimpleQuote volatility,
              Real target_value,
              Real accuracy,
              Natural max_evaluations,
              Volatility min_vol,
              Volatility max_vol):

        return _iv.IVH_calculate(
            deref(instrument._thisptr.get()),
            deref(engine._thisptr.get()),
            deref(<_qt.SimpleQuote*>volatility._thisptr.get()),
            target_value,
            accuracy,
            max_evaluations,
            min_vol,
            max_vol)

    # The returned process is equal to the passed one, except
    # for the volatility which is flat and whose value is driven
    # by the passed quote.

    @classmethod
    def clone(self,
          GeneralizedBlackScholesProcess process,
          SimpleQuote quote):

        cdef shared_ptr[_qt.SimpleQuote] quote_ptr = \
                static_pointer_cast[_qt.SimpleQuote](quote._thisptr)

        cdef GeneralizedBlackScholesProcess res = GeneralizedBlackScholesProcess.__new__(GeneralizedBlackScholesProcess)

        res._thisptr = _iv.IVH_clone(
                static_pointer_cast[_bsp.GeneralizedBlackScholesProcess](
                process._thisptr), quote_ptr)
        return res
