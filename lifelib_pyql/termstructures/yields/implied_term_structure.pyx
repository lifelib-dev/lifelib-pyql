cimport lifelib_pyql.termstructures.yields._implied_term_structure as _its
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.time.date cimport Date

cdef class ImpliedTermStructure(YieldTermStructure):
    def __init__(self, HandleYieldTermStructure h not None,
                 Date reference_date not None):

        self._thisptr.reset(
            new _its.ImpliedTermStructure(h.handle, reference_date._thisptr)
        )
