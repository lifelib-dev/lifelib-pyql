from lifelib_pyql.handle cimport Handle
cimport lifelib_pyql.termstructures._yield_term_structure as _yts
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.time._period cimport Period

cdef extern from 'ql/indexes/ibor/euribor.hpp' namespace 'QuantLib':

    cdef cppclass Euribor(IborIndex):
        Euribor(  Period& tenor,
                  Handle[_yts.YieldTermStructure]& h) except +

    cdef cppclass Euribor6M(Euribor):
        Euribor6M(Handle[_yts.YieldTermStructure]& yc)

    cdef cppclass Euribor3M(Euribor):
        Euribor3M(Handle[_yts.YieldTermStructure]& yc)
