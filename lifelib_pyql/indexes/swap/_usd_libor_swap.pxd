from lifelib_pyql.indexes._swap_index cimport SwapIndex
from lifelib_pyql.time._date cimport Period
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure

cdef extern from 'ql/indexes/swap/usdliborswap.hpp' namespace 'QuantLib' nogil:
    cdef cppclass UsdLiborSwapIsdaFixAm(SwapIndex):
        UsdLiborSwapIsdaFixAm(const Period& tenor,
                              const Handle[YieldTermStructure]& h)
                              #= Handle[YieldTermStructure]())
        UsdLiborSwapIsdaFixAm(const Period& tenor,
                              const Handle[YieldTermStructure]& forwarding,
                              const Handle[YieldTermStructure]& discounting)

    cdef cppclass UsdLiborSwapIsdaFixPm(SwapIndex):
        UsdLiborSwapIsdaFixPm(const Period& tenor,
                              const Handle[YieldTermStructure]& h)
                              #= Handle[YieldTermStructure]())
        UsdLiborSwapIsdaFixPm(const Period& tenor,
                              const Handle[YieldTermStructure]& forwarding,
                              const Handle[YieldTermStructure]& discounting)
