from libcpp.vector cimport vector
from lifelib_pyql.types cimport Real, Size
from lifelib_pyql.handle cimport shared_ptr

cdef extern from 'ql/models/marketmodels/browniangenerator.hpp' namespace 'QuantLib' nogil:
    cdef cppclass BrownianGenerator:
        Real nextStep(vector[Real]&) except +
        Real nextPath()

        Size numberOfFactors() const
        Size numberOfSteps() const

    cdef cppclass BrownianGeneratorFactory:
        shared_ptr[BrownianGenerator] create(Size factor, Size steps) const
