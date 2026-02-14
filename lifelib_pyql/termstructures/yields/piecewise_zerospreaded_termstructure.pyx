from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from lifelib_pyql.compounding cimport Compounding, Continuous
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.time.frequency cimport Frequency, NoFrequency
from lifelib_pyql.time._date cimport Date as QlDate
from lifelib_pyql.time.date cimport Date
from lifelib_pyql.quote cimport Quote
cimport lifelib_pyql._quote as _qt
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from . cimport _piecewise_zerospreaded_termstructure as _pzt

cdef class PiecewiseZeroSpreadedTermStructure(YieldTermStructure):
    def __init__(self, HandleYieldTermStructure h not None, list spreads, list dates,
                 Compounding comp=Continuous, Frequency freq=NoFrequency,
                 DayCounter dc not None=DayCounter()):
        cdef vector[Handle[_qt.Quote]] spreads_vec
        cdef vector[QlDate] dates_vec
        cdef Quote s
        cdef Date d
        for s in spreads:
            spreads_vec.push_back(s.handle())

        for d in dates:
            dates_vec.push_back((<Date?>d)._thisptr)

        self._thisptr.reset(
            new _pzt.PiecewiseZeroSpreadedTermStructure(
                h.handle,
                spreads_vec,
                dates_vec,
                comp,
                freq,
                deref(dc._thisptr)
            )
        )
