from libcpp cimport bool
from lifelib_pyql.types cimport Real, Time, Volatility
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.time._date cimport Date
from lifelib_pyql._quote cimport Quote
from ._local_vol_term_structure cimport LocalVolTermStructure
from ._black_vol_term_structure cimport BlackVolTermStructure

cdef extern from 'ql/termstructures/volatility/equityfx/localvolsurface.hpp' namespace 'QuantLib' nogil:

    cdef cppclass LocalVolSurface(LocalVolTermStructure):
        # Local volatility surface derived from a Black vol surface
        # For details about this implementation refer to
        # "Stochastic Volatility and Local Volatility," in
        # "Case Studies and Financial Modelling Course Notes," by
        # Jim Gatheral, Fall Term, 2003
        # see www.math.nyu.edu/fellows_fin_math/gatheral/Lecture1_Fall02.pdf
        # bug this class is untested, probably unreliable.
        LocalVolSurface(const Handle[BlackVolTermStructure]& blackTS,
                        Handle[YieldTermStructure] riskFreeTS,
                        Handle[YieldTermStructure] dividendTS,
                        Handle[Quote] underlying)
        LocalVolSurface(const Handle[BlackVolTermStructure]& blackTS,
                        Handle[YieldTermStructure] riskFreeTS,
                        Handle[YieldTermStructure] dividendTS,
                        Real underlying)
