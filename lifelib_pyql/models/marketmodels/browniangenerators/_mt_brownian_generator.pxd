from lifelib_pyql.types cimport Size
from lifelib_pyql.types cimport Real, Size
from lifelib_pyql.handle cimport shared_ptr
from .._brownian_generator cimport BrownianGenerator, BrownianGeneratorFactory

cdef extern from 'ql/models/marketmodels/browniangenerators/mtbrowniangenerator.hpp' namespace 'QuantLib' nogil:
    cdef cppclass MTBrownianGenerator(BrownianGenerator):
        MTBrownianGenerator(Size factors,
                            Size steps,
                            unsigned long seed) # = 0

    cdef cppclass MTBrownianGeneratorFactory(BrownianGeneratorFactory):
        MTBrownianGeneratorFactory(unsigned long seed) # = 0
        shared_ptr[BrownianGenerator] create(Size factor, Size steps) const
