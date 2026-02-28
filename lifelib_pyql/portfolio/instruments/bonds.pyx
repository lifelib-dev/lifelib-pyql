# cython: language_level=3str, embedsignature=True, auto_pickle=False
"""Vectorized FixedRateBond collection for bulk bond construction."""

import numpy as np
cimport numpy as cnp
cnp.import_array()

from lifelib_pyql.types cimport Natural, Real
cimport lifelib_pyql.time._date as _date
from lifelib_pyql.time._date cimport serial_type
from lifelib_pyql.time.businessdayconvention cimport (
    BusinessDayConvention, Following)
from lifelib_pyql.time.date cimport Date
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.time.schedule cimport Schedule
from lifelib_pyql.instruments.bonds.fixedratebond cimport FixedRateBond
from lifelib_pyql.portfolio.time.schedules cimport Schedules


cdef cnp.int64_t NAT_INT64 = np.datetime64('NaT', 'D').view('i8')


cdef Date _date_from_np_dt64(cnp.int64_t val):
    """Convert a numpy datetime64[D] int64 value to a pyql Date."""
    if val == NAT_INT64:
        return Date()
    cdef Date d = Date.__new__(Date)
    d._thisptr = _date.Date(<serial_type>(val + 25569))
    return d


cdef class FixedRateBonds:
    """A collection of fixed-rate bonds stored as parallel arrays.

    Stores parameters for bulk FixedRateBond construction.
    Individual bonds are reconstructed on demand via indexing.

    Parameters
    ----------
    settlement_days : ndarray[int]
        Settlement days per bond, shape (N,).
    face_amounts : ndarray[float]
        Face amounts per bond, shape (N,).
    schedules : Schedules
        Payment schedules for all bonds.
    coupons : ndarray[float]
        Coupon rates. Shape (N,) for a single coupon per bond,
        or (N, M) for up to M coupons per bond (NaN-padded).
    accrual_day_counter : DayCounter
        Day counter for accrual (shared across all bonds).
    payment_convention : BusinessDayConvention, optional
        Payment convention (shared). Default: Following.
    redemptions : float or ndarray[float], optional
        Redemption amounts, scalar or shape (N,). Default: 100.0.
    issue_dates : ndarray[datetime64[D]] or None, optional
        Issue dates per bond, shape (N,). Default: None.
    """

    def __init__(self, settlement_days, face_amounts,
                 Schedules schedules, coupons,
                 DayCounter accrual_day_counter,
                 BusinessDayConvention payment_convention=Following,
                 redemptions=100.0,
                 issue_dates=None):

        cdef Py_ssize_t n = len(schedules)

        cdef cnp.ndarray sd_arr = np.asarray(settlement_days, dtype=np.int64)
        cdef cnp.ndarray fa_arr = np.asarray(face_amounts, dtype=np.float64)
        cdef cnp.ndarray cpn_arr = np.asarray(coupons, dtype=np.float64)

        if sd_arr.shape[0] != n:
            raise ValueError(
                f"settlement_days length {sd_arr.shape[0]} != "
                f"schedules length {n}")
        if fa_arr.shape[0] != n:
            raise ValueError(
                f"face_amounts length {fa_arr.shape[0]} != "
                f"schedules length {n}")
        if cpn_arr.ndim == 1:
            if cpn_arr.shape[0] != n:
                raise ValueError(
                    f"coupons length {cpn_arr.shape[0]} != "
                    f"schedules length {n}")
        elif cpn_arr.ndim == 2:
            if cpn_arr.shape[0] != n:
                raise ValueError(
                    f"coupons rows {cpn_arr.shape[0]} != "
                    f"schedules length {n}")
        else:
            raise ValueError("coupons must be 1D or 2D array")

        # Handle redemptions: scalar broadcast or array
        cdef cnp.ndarray red_arr = np.broadcast_to(
            np.asarray(redemptions, dtype=np.float64), (n,)).copy()

        # Handle issue_dates
        cdef cnp.ndarray id_arr
        if issue_dates is not None:
            id_arr = np.asarray(issue_dates, dtype='datetime64[D]')
            if id_arr.shape[0] != n:
                raise ValueError(
                    f"issue_dates length {id_arr.shape[0]} != "
                    f"schedules length {n}")
        else:
            id_arr = None

        self._settlement_days = sd_arr
        self._face_amounts = fa_arr
        self._schedules = schedules
        self._coupons = cpn_arr
        self._accrual_day_counter = accrual_day_counter
        self._payment_convention = <int>payment_convention
        self._redemptions = red_arr
        self._issue_dates = id_arr

    def __len__(self):
        return len(self._schedules)

    @property
    def settlement_days(self):
        """1D int array of settlement days per bond."""
        return self._settlement_days

    @property
    def face_amounts(self):
        """1D float array of face amounts per bond."""
        return self._face_amounts

    @property
    def schedules(self):
        """Schedules object for all bonds."""
        return self._schedules

    @property
    def coupons(self):
        """Coupon rates: 1D (N,) or 2D (N, M) float array."""
        return self._coupons

    @property
    def redemptions(self):
        """1D float array of redemption amounts per bond."""
        return self._redemptions

    @property
    def issue_dates(self):
        """1D datetime64[D] array of issue dates, or None."""
        return self._issue_dates

    def __getitem__(self, index):
        """Index or slice the collection.

        Parameters
        ----------
        index : int or slice
            int returns a singular FixedRateBond, slice returns a new
            FixedRateBonds.
        """
        cdef Date issue_dt
        cdef FixedRateBonds result

        if isinstance(index, int):
            if index < 0:
                index += len(self)
            if index < 0 or index >= len(self):
                raise IndexError(
                    f"index {index} out of range for FixedRateBonds of "
                    f"length {len(self)}")

            # Reconstruct singular FixedRateBond from stored params
            schedule = self._schedules[index]  # Returns a Schedule

            if self._coupons.ndim == 1:
                cpn_list = [float(self._coupons[index])]
            else:
                row = self._coupons[index]
                cpn_list = [float(v) for v in row if not np.isnan(v)]

            if self._issue_dates is not None:
                issue_dt = _date_from_np_dt64(
                    self._issue_dates.view('i8')[index])
            else:
                issue_dt = Date()

            return FixedRateBond(
                <Natural>self._settlement_days[index],
                <Real>self._face_amounts[index],
                <Schedule>schedule,
                cpn_list,
                <DayCounter>self._accrual_day_counter,
                <BusinessDayConvention>self._payment_convention,
                <Real>self._redemptions[index],
                issue_dt,
            )
        elif isinstance(index, slice):
            result = FixedRateBonds.__new__(FixedRateBonds)
            result._settlement_days = self._settlement_days[index]
            result._face_amounts = self._face_amounts[index]
            result._schedules = self._schedules[index]
            result._coupons = self._coupons[index]
            result._accrual_day_counter = self._accrual_day_counter
            result._payment_convention = self._payment_convention
            result._redemptions = self._redemptions[index]
            result._issue_dates = (self._issue_dates[index]
                                   if self._issue_dates is not None
                                   else None)
            return result
        else:
            raise TypeError("index must be int or slice")

    def __repr__(self):
        return f"<FixedRateBonds with {len(self)} bonds>"
