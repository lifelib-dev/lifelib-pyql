from lifelib_pyql.indexes.inflation_index cimport ZeroInflationIndex, YoYInflationIndex

cdef class EUHICP(ZeroInflationIndex):
    pass

cdef class EUHICPXT(ZeroInflationIndex):
    pass

cdef class YYEUHICP(YoYInflationIndex):
    pass

cdef class YYEUHICPXT(YoYInflationIndex):
    pass
