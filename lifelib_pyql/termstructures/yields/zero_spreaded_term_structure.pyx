from cython.operator cimport dereference as deref
from lifelib_pyql.compounding cimport Compounding, Continuous
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.time.frequency cimport Frequency, NoFrequency
from lifelib_pyql.quote cimport Quote
from . cimport _zero_spreaded_term_structure as _zsts

cdef class ZeroSpreadedTermStructure(YieldTermStructure):
    def __init__(self, HandleYieldTermStructure h not None, Quote spread,
                 Compounding comp=Continuous, Frequency freq=NoFrequency,
                 DayCounter dc not None=DayCounter()):

        self._thisptr.reset(
            new _zsts.ZeroSpreadedTermStructure(
                h.handle,
                spread.handle(),
                comp,
                freq,
                deref(dc._thisptr)
            )
        )
