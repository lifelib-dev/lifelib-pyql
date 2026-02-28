import unittest
import numpy as np

from lifelib_pyql.time.date import Date, Period, Jul, Months
from lifelib_pyql.time.businessdayconvention import (
    ModifiedFollowing, Following)
from lifelib_pyql.time.calendars.target import TARGET
from lifelib_pyql.time.schedule import Schedule
from lifelib_pyql.time.dategeneration import DateGeneration
from lifelib_pyql.time.frequency import Annual
from lifelib_pyql.time.daycounters.actual_actual import ActualActual
from lifelib_pyql.instruments.bonds import FixedRateBond


class FixedRateBondsTestCase(unittest.TestCase):
    """Tests for the vectorized FixedRateBonds class."""

    def setUp(self):
        from lifelib_pyql.portfolio.time.schedules import Schedules
        from lifelib_pyql.portfolio.instruments.bonds import FixedRateBonds
        self.FixedRateBonds = FixedRateBonds
        self.calendar = TARGET()

        # Three 10-year annual bonds with different start dates and coupons
        self.effective_dates = np.array(
            ['2006-07-10', '2007-01-15', '2008-03-01'], dtype='datetime64[D]')
        self.termination_dates = np.array(
            ['2016-07-10', '2017-01-15', '2018-03-01'], dtype='datetime64[D]')
        self.tenors = np.array([12, 12, 12])  # annual

        self.schedules = Schedules(
            self.effective_dates, self.termination_dates, self.tenors,
            max_size=15, calendar=self.calendar,
            convention=ModifiedFollowing,
            termination_date_convention=ModifiedFollowing,
            rule=DateGeneration.Backward, end_of_month=False)

        self.settlement_days = np.array([3, 3, 3])
        self.face_amounts = np.array([100.0, 100.0, 100.0])
        self.coupons = np.array([0.05, 0.04, 0.06])
        self.day_counter = ActualActual(ActualActual.ISMA)
        self.issue_dates = self.effective_dates.copy()

    def _make_bonds(self, **overrides):
        """Helper to construct FixedRateBonds with optional overrides."""
        kwargs = dict(
            settlement_days=self.settlement_days,
            face_amounts=self.face_amounts,
            schedules=self.schedules,
            coupons=self.coupons,
            accrual_day_counter=self.day_counter,
            payment_convention=Following,
            redemptions=100.0,
            issue_dates=self.issue_dates,
        )
        kwargs.update(overrides)
        return self.FixedRateBonds(**kwargs)

    def test_construction_and_len(self):
        bonds = self._make_bonds()
        self.assertEqual(len(bonds), 3)

    def test_repr(self):
        bonds = self._make_bonds()
        self.assertEqual(repr(bonds), "<FixedRateBonds with 3 bonds>")

    def test_properties(self):
        bonds = self._make_bonds()
        np.testing.assert_array_equal(bonds.settlement_days, self.settlement_days)
        np.testing.assert_array_equal(bonds.face_amounts, self.face_amounts)
        np.testing.assert_array_equal(bonds.coupons, self.coupons)
        np.testing.assert_array_equal(bonds.redemptions, np.array([100.0, 100.0, 100.0]))
        np.testing.assert_array_equal(bonds.issue_dates, self.issue_dates)
        self.assertIs(bonds.schedules, self.schedules)

    def test_indexing_int(self):
        bonds = self._make_bonds()
        bond = bonds[0]
        self.assertIsInstance(bond, FixedRateBond)

    def test_indexing_negative(self):
        bonds = self._make_bonds()
        bond = bonds[-1]
        self.assertIsInstance(bond, FixedRateBond)

    def test_indexing_slice(self):
        bonds = self._make_bonds()
        sub = bonds[0:2]
        self.assertIsInstance(sub, self.FixedRateBonds)
        self.assertEqual(len(sub), 2)

    def test_indexing_out_of_range(self):
        bonds = self._make_bonds()
        with self.assertRaises(IndexError):
            bonds[10]

    def test_indexing_invalid_type(self):
        bonds = self._make_bonds()
        with self.assertRaises(TypeError):
            bonds["foo"]

    def test_consistency_with_singular(self):
        """Verify that indexed bonds match individually constructed FixedRateBond."""
        bonds = self._make_bonds()

        for i in range(3):
            bond = bonds[i]
            schedule = self.schedules[i]

            singular = FixedRateBond(
                int(self.settlement_days[i]),
                float(self.face_amounts[i]),
                schedule,
                [float(self.coupons[i])],
                self.day_counter,
                Following,
                100.0,
                Date(
                    self.issue_dates[i].astype('datetime64[D]').item().day,
                    self.issue_dates[i].astype('datetime64[D]').item().month,
                    self.issue_dates[i].astype('datetime64[D]').item().year,
                ),
            )

            self.assertEqual(bond.settlement_days, singular.settlement_days,
                             f"Bond {i}: settlement_days mismatch")
            self.assertEqual(bond.start_date, singular.start_date,
                             f"Bond {i}: start_date mismatch")
            self.assertEqual(bond.maturity_date, singular.maturity_date,
                             f"Bond {i}: maturity_date mismatch")
            self.assertEqual(bond.issue_date, singular.issue_date,
                             f"Bond {i}: issue_date mismatch")

    def test_slice_then_index(self):
        """Slicing then indexing should produce a valid bond."""
        bonds = self._make_bonds()
        sub = bonds[1:3]
        self.assertEqual(len(sub), 2)
        bond = sub[0]
        self.assertIsInstance(bond, FixedRateBond)
        # The bond from sub[0] should match bonds[1]
        original = bonds[1]
        self.assertEqual(bond.start_date, original.start_date)
        self.assertEqual(bond.maturity_date, original.maturity_date)

    def test_scalar_redemptions(self):
        """Scalar redemption should broadcast to all bonds."""
        bonds = self._make_bonds(redemptions=105.0)
        np.testing.assert_array_equal(
            bonds.redemptions, np.array([105.0, 105.0, 105.0]))

    def test_array_redemptions(self):
        """Array redemptions should be stored per bond."""
        reds = np.array([100.0, 105.0, 110.0])
        bonds = self._make_bonds(redemptions=reds)
        np.testing.assert_array_equal(bonds.redemptions, reds)

    def test_no_issue_dates(self):
        """issue_dates=None should be supported."""
        bonds = self._make_bonds(issue_dates=None)
        self.assertIsNone(bonds.issue_dates)
        # Indexing should still work, returning a bond with null issue date
        bond = bonds[0]
        self.assertIsInstance(bond, FixedRateBond)

    def test_2d_coupons(self):
        """2D coupon array should work (multiple coupons per bond, NaN-padded)."""
        cpn_2d = np.array([
            [0.05, 0.04],
            [0.03, np.nan],
            [0.06, 0.05],
        ])
        bonds = self._make_bonds(coupons=cpn_2d)
        self.assertEqual(bonds.coupons.ndim, 2)
        self.assertEqual(bonds.coupons.shape, (3, 2))
        # Bond 1 should have only one coupon (NaN filtered out)
        bond = bonds[1]
        self.assertIsInstance(bond, FixedRateBond)

    def test_mismatched_settlement_days_length(self):
        with self.assertRaises(ValueError):
            self._make_bonds(settlement_days=np.array([3, 3]))

    def test_mismatched_face_amounts_length(self):
        with self.assertRaises(ValueError):
            self._make_bonds(face_amounts=np.array([100.0]))

    def test_mismatched_coupons_length(self):
        with self.assertRaises(ValueError):
            self._make_bonds(coupons=np.array([0.05, 0.04]))

    def test_mismatched_issue_dates_length(self):
        with self.assertRaises(ValueError):
            self._make_bonds(
                issue_dates=np.array(['2006-07-10'], dtype='datetime64[D]'))

    def test_invalid_coupons_ndim(self):
        with self.assertRaises(ValueError):
            self._make_bonds(coupons=np.ones((3, 2, 1)))

    def test_slice_preserves_properties(self):
        """Sliced FixedRateBonds should carry the right subset of data."""
        bonds = self._make_bonds()
        sub = bonds[1:3]
        np.testing.assert_array_equal(sub.settlement_days, self.settlement_days[1:3])
        np.testing.assert_array_equal(sub.face_amounts, self.face_amounts[1:3])
        np.testing.assert_array_equal(sub.coupons, self.coupons[1:3])
        np.testing.assert_array_equal(sub.redemptions, np.array([100.0, 100.0]))
        np.testing.assert_array_equal(sub.issue_dates, self.issue_dates[1:3])

    def test_negative_index_bounds(self):
        bonds = self._make_bonds()
        with self.assertRaises(IndexError):
            bonds[-4]


if __name__ == '__main__':
    unittest.main()
