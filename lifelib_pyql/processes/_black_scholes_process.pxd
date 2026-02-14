"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../types.pxi'

from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.termstructures.yields._flat_forward cimport YieldTermStructure
cimport lifelib_pyql._quote as _qt
from lifelib_pyql._stochastic_process cimport StochasticProcess1D
from lifelib_pyql.termstructures.volatility.equityfx._black_vol_term_structure cimport BlackVolTermStructure

cdef extern from 'ql/processes/blackscholesprocess.hpp' namespace 'QuantLib':

    cdef cppclass GeneralizedBlackScholesProcess(StochasticProcess1D):
        GeneralizedBlackScholesProcess()
        GeneralizedBlackScholesProcess(
            Handle[_qt.Quote]& x0,
            Handle[YieldTermStructure]& dividendTS,
            Handle[YieldTermStructure]& riskFreeTS,
            Handle[BlackVolTermStructure]& blackVolTS,
        )

    cdef cppclass BlackScholesProcess(GeneralizedBlackScholesProcess):
        BlackScholesProcess(
            Handle[_qt.Quote]& x0,
            Handle[YieldTermStructure]& riskFreeTS,
            Handle[BlackVolTermStructure]& blackVolTS,
        )


    cdef cppclass BlackScholesMertonProcess(GeneralizedBlackScholesProcess):
        BlackScholesMertonProcess(
            Handle[_qt.Quote]& x0,
            Handle[YieldTermStructure]& dividendTS,
            Handle[YieldTermStructure]& riskFreeTS,
            Handle[BlackVolTermStructure]& blackVolTS,
        )




