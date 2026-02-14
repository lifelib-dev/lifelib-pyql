from cython.operator cimport dereference as deref
from lifelib_pyql.utilities.null cimport Null
from lifelib_pyql.instruments.swap cimport Swap
from lifelib_pyql.handle cimport static_pointer_cast, shared_ptr
from lifelib_pyql.indexes.swap_index cimport SwapIndex
from lifelib_pyql.time.date cimport Period, Date
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._period cimport Days
cimport lifelib_pyql.indexes._swap_index as _si
cimport lifelib_pyql._instrument as _in
from lifelib_pyql.pricingengines.engine cimport PricingEngine
from lifelib_pyql.instruments._swaption cimport Swaption as _Swaption, Type, Method
from lifelib_pyql.instruments.swaption cimport Swaption
from lifelib_pyql.instruments._vanillaswap cimport VanillaSwap
from lifelib_pyql.instruments.swap cimport Type as SwapType

cdef class MakeSwaption:
    def __init__(self, SwapIndex swap_index,
                 option_tenor,
                 Rate strike=Null[Real]()):
        if isinstance(option_tenor, Date):
            self._thisptr = new _make_swaption.MakeSwaption(
                static_pointer_cast[_si.SwapIndex](swap_index._thisptr),
                (<Date>option_tenor)._thisptr,
                strike)
        elif isinstance(option_tenor, Period):
            self._thisptr = new _make_swaption.MakeSwaption(
                static_pointer_cast[_si.SwapIndex](swap_index._thisptr),
                deref((<Period>option_tenor)._thisptr),
                strike)
        else:
            raise TypeError("'option_tenor' type needs to be either Date or Period")

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __call__(self):
        cdef Swaption instance = Swaption.__new__(Swaption)
        cdef shared_ptr[_Swaption] temp = _make_swaption.get(deref(self._thisptr))
        instance._thisptr = static_pointer_cast[_in.Instrument](temp)
        return instance

    def with_settlement_type(self, Type delivery):
        self._thisptr.withSettlementType(delivery)
        return self

    def with_settlement_method(self, Method method):
        self._thisptr.withSettlementMethod(method)
        return self

    def with_option_convention(self, BusinessDayConvention bdc):
        self._thisptr.withOptionConvention(bdc)
        return self

    def with_exercise_date(self, Date exercise_date not None):
        self._thisptr.withExerciseDate(exercise_date._thisptr)
        return self

    def with_underlying_type(self, SwapType swap_type):
        self._thisptr.withUnderlyingType(swap_type)
        return self

    def with_nominal(self, Real nominal):
        self._thisptr.withNominal(nominal)
        return self

    def with_pricing_engine(self, PricingEngine engine not None):
        self._thisptr.withPricingEngine(engine._thisptr)
        return self
