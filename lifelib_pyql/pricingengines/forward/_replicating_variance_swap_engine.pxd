include '../../types.pxi'

from libcpp.vector cimport vector
from lifelib_pyql.handle cimport shared_ptr

from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.processes._black_scholes_process cimport GeneralizedBlackScholesProcess

cdef extern from 'ql/pricingengines/forward/replicatingvarianceswapengine.hpp' namespace 'QuantLib':

    cdef cppclass ReplicatingVarianceSwapEngine(PricingEngine):

        ReplicatingVarianceSwapEngine(
             shared_ptr[GeneralizedBlackScholesProcess]& process,
             Real dk, # = 5.0,
             vector[Real]& callStrikes, #= vector[Real](),
             vector[Real]& putStrikes, #= vector[Real]()
             ) except +
