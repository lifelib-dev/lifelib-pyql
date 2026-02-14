from lifelib_pyql.time.api import Actual365Fixed, NullCalendar
from lifelib_pyql.termstructures.yields.api import FlatForward

def flat_rate(rate, dc=Actual365Fixed(), reference_date=None):
     if reference_date is None:
          return FlatForward(
               settlement_days=0, calendar=NullCalendar(), forward=rate, daycounter=dc)
     else:
          return FlatForward(reference_date, rate, dc)
