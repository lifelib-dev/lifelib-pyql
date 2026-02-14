from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.indexes._ibor_index cimport OvernightIndex

cdef extern from 'ql/indexes/ibor/eonia.hpp' namespace 'QuantLib':

    cdef cppclass Eonia(OvernightIndex):
        Eonia(Handle[YieldTermStructure]& h) except +
