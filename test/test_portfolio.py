import unittest
import numpy as np

from lifelib_pyql.time.date import Date, Period, Jan, Jul, Months
from lifelib_pyql.time.businessdayconvention import (
    ModifiedFollowing, Unadjusted, Following)
from lifelib_pyql.time.calendars.target import TARGET
from lifelib_pyql.time.schedule import Schedule
from lifelib_pyql.time.dategeneration import DateGeneration
from lifelib_pyql.time.frequency import Semiannual, Annual


class SchedulesTestCase(unittest.TestCase):
    """Tests for the vectorized Schedules class."""

    def setUp(self):
        from lifelib_pyql.portfolio.time.schedules import Schedules
        self.Schedules = Schedules
        self.calendar = TARGET()

        # Three schedules with different tenors
        self.effective_dates = np.array(
            ['2020-01-15', '2020-07-01', '2021-01-01'], dtype='datetime64[D]')
        self.termination_dates = np.array(
            ['2030-01-15', '2030-07-01', '2031-01-01'], dtype='datetime64[D]')
        self.tenors = np.array([6, 12, 6])  # months

    def test_construction_and_len(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar,
            convention=ModifiedFollowing,
            termination_date_convention=ModifiedFollowing,
            rule=DateGeneration.Backward, end_of_month=False)
        self.assertEqual(len(scheds), 3)

    def test_dates_shape(self):
        max_size = 30
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=max_size, calendar=self.calendar)
        dates = scheds.dates
        self.assertEqual(dates.shape, (3, max_size))
        self.assertEqual(dates.dtype, np.dtype('datetime64[D]'))

    def test_nat_padding(self):
        max_size = 30
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=max_size, calendar=self.calendar)
        dates = scheds.dates
        sizes = scheds.size
        # Check that dates beyond size are NaT
        for i in range(3):
            sz = sizes[i]
            # Non-NaT dates up to size
            self.assertTrue(np.all(~np.isnat(dates[i, :sz])))
            # NaT dates after size
            if sz < max_size:
                self.assertTrue(np.all(np.isnat(dates[i, sz:])))

    def test_consistency_with_singular_schedule(self):
        """Verify that Schedules dates match individually constructed Schedule dates."""
        max_size = 25
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=max_size, calendar=self.calendar,
            convention=ModifiedFollowing,
            termination_date_convention=ModifiedFollowing,
            rule=DateGeneration.Backward, end_of_month=False)

        # Compare each schedule against individually constructed Schedule
        for i in range(3):
            eff_py = self.effective_dates[i].astype('datetime64[D]').item()
            term_py = self.termination_dates[i].astype('datetime64[D]').item()
            eff_d = Date(eff_py.day, eff_py.month, eff_py.year)
            term_d = Date(term_py.day, term_py.month, term_py.year)
            tenor = Period(int(self.tenors[i]), Months)

            singular = Schedule.from_rule(
                eff_d, term_d, tenor, self.calendar,
                ModifiedFollowing, ModifiedFollowing,
                DateGeneration.Backward, False)

            singular_npdates = singular.to_npdates()
            bulk_dates_row = scheds.dates[i]
            sz = scheds.size[i]

            self.assertEqual(sz, len(singular_npdates),
                             f"Schedule {i}: size mismatch")

            np.testing.assert_array_equal(
                bulk_dates_row[:sz], singular_npdates,
                err_msg=f"Schedule {i}: dates mismatch")

    def test_size_property(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar)
        sizes = scheds.size
        self.assertEqual(len(sizes), 3)
        # All sizes should be positive
        self.assertTrue(np.all(sizes > 0))
        # 10yr semiannual has ~21 dates, annual has ~11 dates
        # Just check they're reasonable
        for s in sizes:
            self.assertGreater(s, 2)
            self.assertLessEqual(s, 25)

    def test_max_size_overflow(self):
        """max_size too small should raise ValueError."""
        with self.assertRaises(ValueError):
            self.Schedules(
                self.effective_dates, self.termination_dates, self.tenors,
                max_size=3, calendar=self.calendar)

    def test_indexing_int(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar)
        sched = scheds[0]
        self.assertIsInstance(sched, Schedule)
        # Verify the Schedule has the right number of dates
        self.assertEqual(sched.size(), scheds.size[0])

    def test_indexing_negative(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar)
        sched = scheds[-1]
        self.assertIsInstance(sched, Schedule)
        self.assertEqual(sched.size(), scheds.size[2])

    def test_indexing_slice(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar)
        sub = scheds[0:2]
        self.assertIsInstance(sub, self.Schedules)
        self.assertEqual(len(sub), 2)

    def test_indexing_out_of_range(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar)
        with self.assertRaises(IndexError):
            scheds[10]

    def test_mismatched_lengths(self):
        with self.assertRaises(ValueError):
            self.Schedules(
                self.effective_dates[:2], self.termination_dates, self.tenors,
                max_size=25, calendar=self.calendar)

    def test_empty_collection(self):
        empty_dates = np.array([], dtype='datetime64[D]')
        empty_tenors = np.array([], dtype=np.int64)
        scheds = self.Schedules(
            empty_dates, empty_dates, empty_tenors,
            max_size=25, calendar=self.calendar)
        self.assertEqual(len(scheds), 0)
        self.assertEqual(scheds.dates.shape, (0, 25))

    def test_repr(self):
        scheds = self.Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=25, calendar=self.calendar)
        self.assertEqual(repr(scheds), "<Schedules with 3 schedules>")


if __name__ == '__main__':
    unittest.main()
