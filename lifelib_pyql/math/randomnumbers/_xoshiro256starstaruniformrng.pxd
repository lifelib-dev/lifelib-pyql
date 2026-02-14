from libc.stdint cimport uint64_t
from lifelib_pyql.types cimport Real
from lifelib_pyql.methods.montecarlo._sample cimport Sample

cdef extern from 'ql/math/randomnumbers/xoshiro256starstaruniformrng.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Xoshiro256StarStarUniformRng:
        ctypedef Sample[Real] sample_type
        Xoshiro256StarStarUniformRng(uint64_t seed) #=0
        sample_type next() const
        Real nextReal() const
        uint64_t nextInt64()
