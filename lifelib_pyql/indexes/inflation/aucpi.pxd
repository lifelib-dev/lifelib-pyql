from lifelib_pyql.indexes.inflation_index cimport ZeroInflationIndex, YoYInflationIndex

cdef class AUCPI(ZeroInflationIndex):
    pass

cdef class YYAUCPI(YoYInflationIndex):
    pass
