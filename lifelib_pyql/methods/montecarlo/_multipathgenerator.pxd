from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr

from lifelib_pyql._time_grid cimport TimeGrid
from libcpp.vector cimport vector
from ._multipath cimport MultiPath
from ._sample cimport Sample
from lifelib_pyql._stochastic_process cimport StochasticProcess

cdef extern from 'ql/methods/montecarlo/multipathgenerator.hpp' namespace 'QuantLib' nogil:
    cdef cppclass MultiPathGenerator[GSG]:
        ctypedef Sample[MultiPath] sample_type
        MultiPathGenerator(const shared_ptr[StochasticProcess]&,
                           const TimeGrid&,
                           GSG generator,
                           bool brownianBridge) # = false)
        const sample_type& next()
        const sample_type& antithetic()
