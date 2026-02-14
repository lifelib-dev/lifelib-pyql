include '../types.pxi'

from libcpp cimport bool
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.indexes._swap_index cimport SwapIndex
from ._floating_rate_coupon cimport FloatingRateCoupon

cdef extern from 'ql/cashflows/cmscoupon.hpp' namespace 'QuantLib':
    cdef cppclass CmsCoupon(FloatingRateCoupon):
        CmsCoupon(const Date& paymentDate,
                  Real nominal,
                  const Date& startDate,
                  const Date& endDate,
                  Natural fixingDays,
                  const shared_ptr[SwapIndex]& index,
                  Real gearing, # = 1.0,
                  Spread spread, # = 0.0,
                  const Date& refPeriodStart, # = Date(),
                  const Date& refPeriodEnd, # = Date(),
                  const DayCounter& dayCounter, #= DayCounter(),
                  bool isInArrears)
        shared_ptr[SwapIndex]& swapIndex()
