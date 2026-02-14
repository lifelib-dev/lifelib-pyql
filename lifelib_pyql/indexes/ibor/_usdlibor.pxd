from lifelib_pyql.handle cimport Handle
cimport lifelib_pyql.termstructures._yield_term_structure as _yts
from lifelib_pyql.indexes.ibor._libor cimport Libor
from lifelib_pyql.time._period cimport Period


cdef extern from 'ql/indexes/ibor/usdlibor.hpp' namespace 'QuantLib':

    cdef cppclass USDLibor(Libor):
        USDLibor(Period& tenor,
                Handle[_yts.YieldTermStructure]& h) except +

