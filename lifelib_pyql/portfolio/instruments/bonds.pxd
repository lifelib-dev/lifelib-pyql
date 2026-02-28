cimport numpy as cnp

cdef class FixedRateBonds:
    cdef cnp.ndarray _settlement_days       # 1D int64, (N,)
    cdef cnp.ndarray _face_amounts          # 1D float64, (N,)
    cdef object _schedules                  # Schedules
    cdef cnp.ndarray _coupons              # 1D or 2D float64
    cdef object _accrual_day_counter       # DayCounter
    cdef int _payment_convention
    cdef cnp.ndarray _redemptions          # 1D float64, (N,)
    cdef cnp.ndarray _issue_dates          # 1D datetime64[D], (N,) or None
