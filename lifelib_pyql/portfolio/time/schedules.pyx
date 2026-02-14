# cython: language_level=3str, embedsignature=True, auto_pickle=False
"""Vectorized Schedule collection for bulk schedule generation."""

import numpy as np
cimport numpy as cnp
cnp.import_array()

from lifelib_pyql.types cimport Integer
cimport lifelib_pyql.time._schedule as _schedule
cimport lifelib_pyql.time._date as _date
cimport lifelib_pyql.time._period as _period
from lifelib_pyql.time._date cimport serial_type
from lifelib_pyql.time._period cimport Months
from lifelib_pyql.time.businessdayconvention cimport (
    BusinessDayConvention, ModifiedFollowing)
from lifelib_pyql.time.dategeneration cimport DateGeneration
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.time.calendars.target cimport TARGET
from lifelib_pyql.time.schedule cimport Schedule
from lifelib_pyql.time.date cimport Date, Period, date_from_qldate

from cython.operator cimport dereference as deref
from libcpp.utility cimport move


cdef cnp.int64_t NAT_INT64 = np.datetime64('NaT', 'D').view('i8')


cdef Date _date_from_np_dt64(cnp.int64_t val):
    """Convert a numpy datetime64[D] int64 value to a pyql Date."""
    cdef Date d = Date.__new__(Date)
    d._thisptr = _date.Date(<serial_type>(val + 25569))
    return d


cdef class Schedules:
    """A collection of payment schedules stored as a 2D datetime64 array.

    Bulk-generates QuantLib Schedule objects from arrays of parameters,
    extracts dates into a 2D numpy array, then discards the C++ objects.
    A single C++ Schedule stack variable is reused for each iteration.

    Parameters
    ----------
    effective_dates : ndarray[datetime64[D]]
        Effective (start) dates, shape (N,).
    termination_dates : ndarray[datetime64[D]]
        Termination (end) dates, shape (N,).
    tenors : ndarray[int]
        Tenor in months for each schedule, shape (N,).
    max_size : int
        Maximum number of dates per schedule (2nd dimension of output).
        Raises ValueError if any schedule exceeds this.
    calendar : Calendar, optional
        Calendar for business day adjustments. Default: TARGET().
    convention : BusinessDayConvention, optional
        Business day convention. Default: ModifiedFollowing.
    termination_date_convention : BusinessDayConvention, optional
        Convention for the termination date. Default: ModifiedFollowing.
    rule : DateGeneration, optional
        Date generation rule. Default: DateGeneration.Backward.
    end_of_month : bool, optional
        Whether to force end-of-month dates. Default: False.
    """

    def __init__(self, effective_dates, termination_dates, tenors,
                 int max_size,
                 Calendar calendar=TARGET(),
                 BusinessDayConvention convention=ModifiedFollowing,
                 BusinessDayConvention termination_date_convention=ModifiedFollowing,
                 DateGeneration rule=DateGeneration.Backward,
                 bint end_of_month=False):

        # Ensure proper dtypes
        cdef cnp.ndarray eff_arr = np.asarray(effective_dates, dtype='datetime64[D]')
        cdef cnp.ndarray term_arr = np.asarray(termination_dates, dtype='datetime64[D]')
        cdef cnp.ndarray tnr_arr = np.asarray(tenors, dtype=np.int64)

        cdef Py_ssize_t n = eff_arr.shape[0]
        if term_arr.shape[0] != n or tnr_arr.shape[0] != n:
            raise ValueError(
                f"All input arrays must have the same length. "
                f"Got effective_dates={n}, termination_dates={term_arr.shape[0]}, "
                f"tenors={tnr_arr.shape[0]}")

        # Pre-allocate output filled with NaT
        cdef cnp.ndarray[cnp.int64_t, ndim=2] out = np.full(
            (n, max_size), NAT_INT64, dtype=np.int64)

        # View datetime64 as int64 for fast access
        cdef cnp.int64_t[:] eff = eff_arr.view('i8')
        cdef cnp.int64_t[:] term = term_arr.view('i8')
        cdef cnp.int64_t[:] tnr = tnr_arr

        cdef _schedule.Schedule sched
        cdef _date.Date eff_dt, term_dt
        cdef _period.Period tenor
        cdef Py_ssize_t i, j
        cdef Py_ssize_t sz

        for i in range(n):
            eff_dt = _date.Date(<serial_type>(eff[i] + 25569))
            term_dt = _date.Date(<serial_type>(term[i] + 25569))
            tenor = _period.Period(<Integer>tnr[i], Months)

            sched = _schedule.Schedule(
                eff_dt, term_dt, tenor,
                calendar._thisptr, convention,
                termination_date_convention,
                rule, end_of_month,
                _date.Date(), _date.Date()
            )

            sz = <Py_ssize_t>sched.size()
            if sz > max_size:
                raise ValueError(
                    f"Schedule {i} has {sz} dates, exceeds max_size={max_size}")

            for j in range(sz):
                out[i, j] = sched.at(j).serialNumber() - 25569

        # Store results
        self._dates = out.view('M8[D]')
        self._effective_dates = eff_arr
        self._termination_dates = term_arr
        self._tenors = tnr_arr
        self._calendar = calendar
        self._convention = <int>convention
        self._termination_date_convention = <int>termination_date_convention
        self._rule = <int>rule
        self._end_of_month = end_of_month

    def __len__(self):
        return self._dates.shape[0]

    @property
    def dates(self):
        """2D datetime64[D] array of shape (N, max_size), NaT-padded."""
        return self._dates

    @property
    def size(self):
        """1D int array: number of non-NaT dates per schedule."""
        return np.sum(~np.isnat(self._dates), axis=1)

    def __getitem__(self, index):
        """Index or slice the collection.

        Parameters
        ----------
        index : int or slice
            int returns a singular Schedule, slice returns a new Schedules.
        """
        cdef cnp.int64_t eff_val, term_val
        cdef Date eff, term
        cdef Period tenor
        cdef Schedules result

        if isinstance(index, int):
            if index < 0:
                index += self._dates.shape[0]
            if index < 0 or index >= self._dates.shape[0]:
                raise IndexError(
                    f"index {index} out of range for Schedules of length "
                    f"{self._dates.shape[0]}")
            # Reconstruct a singular Schedule from stored params
            eff_val = self._effective_dates.view('i8')[index]
            term_val = self._termination_dates.view('i8')[index]
            eff = _date_from_np_dt64(eff_val)
            term = _date_from_np_dt64(term_val)
            tenor = Period.__new__(Period)
            tenor._thisptr.reset(
                new _period.Period(<Integer>self._tenors[index], Months))
            return Schedule.from_rule(
                eff, term, tenor,
                <Calendar>self._calendar,
                <BusinessDayConvention>self._convention,
                <BusinessDayConvention>self._termination_date_convention,
                <DateGeneration>self._rule,
                <bint>self._end_of_month,
            )
        elif isinstance(index, slice):
            result = Schedules.__new__(Schedules)
            result._dates = self._dates[index]
            result._effective_dates = self._effective_dates[index]
            result._termination_dates = self._termination_dates[index]
            result._tenors = self._tenors[index]
            result._calendar = self._calendar
            result._convention = self._convention
            result._termination_date_convention = self._termination_date_convention
            result._rule = self._rule
            result._end_of_month = self._end_of_month
            return result
        else:
            raise TypeError("index must be int or slice")

    def __repr__(self):
        return f"<Schedules with {len(self)} schedules>"
