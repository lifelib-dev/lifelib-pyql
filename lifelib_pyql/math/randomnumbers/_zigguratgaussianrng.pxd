from lifelib_pyql.types cimport Real
from lifelib_pyql.methods.montecarlo._sample cimport Sample

cdef extern from 'ql/math/randomnumbers/zigguratgaussianrng.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ZigguratGaussianRng[RNG]:
        ctypedef Sample[Real] sample_type
        ZigguratGaussianRng(const RNG& uint64Generator)
        sample_type next() const
        Real nextReal() const
