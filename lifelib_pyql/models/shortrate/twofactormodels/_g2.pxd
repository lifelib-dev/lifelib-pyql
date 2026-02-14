from lifelib_pyql.types cimport Rate, Real, Time
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from .._twofactor_model cimport TwoFactorModel
from ..._model cimport TermStructureConsistentModel, AffineModel

cdef extern from 'ql/models/shortrate/twofactormodels/g2.hpp' namespace 'QuantLib' nogil:
    cdef cppclass G2(TwoFactorModel, AffineModel, TermStructureConsistentModel):
        G2(
            Handle[YieldTermStructure]& termStructure,
            Real a, #0.1
            Real sigma, # = 0.01
            Real b, # = 0.1
            Real eta, # = 0.01
            Real rho, # = -0.75
        ) except +
