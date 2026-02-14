from lifelib_pyql.types cimport Real, Natural
from lifelib_pyql.handle cimport static_pointer_cast
from lifelib_pyql.time.date cimport Date
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention, Following
from lifelib_pyql.indexes.ibor_index cimport IborIndex
from lifelib_pyql.indexes cimport _ibor_index as _ib
from . cimport _zerocouponswap as _zcs

cdef class ZeroCouponSwap(Swap):
    def __init__(self, Type type, Real nominal, Date start_date, Date maturity, Real fixed_payment, IborIndex ibor_index, Calendar payment_calendar, BusinessDayConvention payment_convention=Following, Natural payment_delay=0):
        self._thisptr.reset(
            new _zcs.ZeroCouponSwap(
                type,
                nominal,
                start_date._thisptr,
                maturity._thisptr,
                fixed_payment,
                static_pointer_cast[_ib.IborIndex](ibor_index._thisptr),
                payment_calendar._thisptr,
                payment_convention,
                payment_delay
            )
        )
