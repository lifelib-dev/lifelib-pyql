from cython.operator cimport dereference as deref
from . cimport _optionlet_volatility_structure as _ov

from lifelib_pyql.time._calendar cimport BusinessDayConvention
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.time.date cimport Date
from lifelib_pyql.time.daycounter cimport DayCounter


cdef class OptionletVolatilityStructure:
    pass


cdef class ConstantOptionletVolatility(OptionletVolatilityStructure):

    def __init__(self,
        int settlement_days,
        Calendar calendar,
        BusinessDayConvention bdc,
        double volatility,
        DayCounter daycounter
    ):

        self._thisptr = shared_ptr[_ov.OptionletVolatilityStructure](
            new _ov.ConstantOptionletVolatility(
                settlement_days,
                calendar._thisptr,
                bdc,
                volatility,
                deref(daycounter._thisptr)
            )
        )
