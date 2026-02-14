from . cimport _vasicek as _va
from lifelib_pyql.handle cimport Handle, shared_ptr

from lifelib_pyql.models.shortrate.onefactor_model cimport OneFactorAffineModel

cdef class Vasicek(OneFactorAffineModel):
    pass
