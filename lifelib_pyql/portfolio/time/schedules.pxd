cimport numpy as cnp

cdef class Schedules:
    cdef cnp.ndarray _dates               # 2D int64 viewed as datetime64[D], (N, max_size)
    cdef cnp.ndarray _effective_dates      # 1D datetime64[D], (N,)
    cdef cnp.ndarray _termination_dates    # 1D datetime64[D], (N,)
    cdef cnp.ndarray _tenors              # 1D int, (N,) — months
    cdef object _calendar                  # Calendar
    cdef int _convention
    cdef int _termination_date_convention
    cdef int _rule
    cdef bint _end_of_month
