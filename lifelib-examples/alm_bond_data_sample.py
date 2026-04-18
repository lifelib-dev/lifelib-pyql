"""Build vectorized portfolio Schedules and FixedRateBonds from alm_bond_data.xlsx.

End-to-end pattern: xlsx -> numpy arrays -> Schedules -> FixedRateBonds.
"""

from pathlib import Path

import numpy as np
import pandas as pd

from lifelib_pyql.portfolio.api import Schedules, FixedRateBonds
from lifelib_pyql.time.calendars.target import TARGET
from lifelib_pyql.time.businessdayconvention import ModifiedFollowing, Following
from lifelib_pyql.time.dategeneration import DateGeneration
from lifelib_pyql.time.daycounters.actual_actual import ActualActual


def tenor_to_months(s: str) -> int:
    s = s.strip().upper()
    n = int(s[:-1])
    unit = s[-1]
    if unit == "Y":
        return n * 12
    if unit == "M":
        return n
    raise ValueError(f"Unsupported tenor: {s!r}")


DATA = Path(__file__).parent / "alm_bond_data.xlsx"
df = pd.read_excel(DATA, sheet_name="inforce_bonds")

effective_dates   = df["issue_date"].to_numpy(dtype="datetime64[D]")
termination_dates = df["maturity_date"].to_numpy(dtype="datetime64[D]")
tenors            = np.array([tenor_to_months(t) for t in df["tenor"]], dtype=np.int64)
settlement_days   = df["settlement_days"].to_numpy(dtype=np.int64)
face_amounts      = df["face_value"].to_numpy(dtype=np.float64)
coupons           = df["coupon_rate"].to_numpy(dtype=np.float64)

max_size = int(df["bond_term"].max() * (12 // tenors.min()) + 2)

schedules = Schedules(
    effective_dates, termination_dates, tenors,
    max_size=max_size,
    calendar=TARGET(),
    convention=ModifiedFollowing,
    termination_date_convention=ModifiedFollowing,
    rule=DateGeneration.Backward,
    end_of_month=False,
)

bonds = FixedRateBonds(
    settlement_days=0,
    face_amounts=face_amounts,
    schedules=schedules,
    coupons=coupons,
    accrual_day_counter=ActualActual(ActualActual.ISMA),
    payment_convention=Following,
    redemptions=face_amounts,
    issue_dates=effective_dates,
)

print(f"Loaded {len(bonds)} bonds from {DATA.name}")
print(f"Schedules grid shape: {schedules.dates.shape}")
print(f"First bond maturity: {bonds[0].maturity_date!s}")
print(f"Subset (first 3 bonds): {bonds[0:3]!r}")
