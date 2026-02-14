from lifelib_pyql.indexes._swap_index cimport SwapIndex
from lifelib_pyql.time._date cimport Period
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/indexes/swap/euriborswap.hpp' namespace 'QuantLib' nogil:
    cdef cppclass EuriborSwapIsdaFixA(SwapIndex):
        EuriborSwapIsdaFixA(const Period& tenor,
                            const Handle[YieldTermStructure]& h)
                            #= Handle[YieldTermStructure]())
        EuriborSwapIsdaFixA(const Period& tenor,
                            const Handle[YieldTermStructure]& forwarding,
                            const Handle[YieldTermStructure]& discounting)

    cdef cppclass EuriborSwapIsdaFixB(SwapIndex):
        EuriborSwapIsdaFixB(const Period& tenor,
                            const Handle[YieldTermStructure]& h)
                            #= Handle[YieldTermStructure]())
        EuriborSwapIsdaFixB(const Period& tenor,
                            const Handle[YieldTermStructure]& forwarding,
                            const Handle[YieldTermStructure]& discounting)
