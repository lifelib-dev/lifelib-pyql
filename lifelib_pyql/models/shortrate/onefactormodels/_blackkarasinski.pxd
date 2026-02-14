from lifelib_pyql.types cimport Real
from lifelib_pyql.models.shortrate._onefactor_model cimport OneFactorModel
from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/models/shortrate/onefactormodels/blackkarasinski.hpp' namespace 'QuantLib':

    cdef cppclass BlackKarasinski(OneFactorModel):

        BlackKarasinski(Handle[YieldTermStructure] termStructure, Real a, Real sigma) except +
