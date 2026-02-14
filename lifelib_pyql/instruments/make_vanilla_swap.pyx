from cython.operator cimport dereference as deref
from libcpp cimport bool
from lifelib_pyql.utilities.null cimport Null
from lifelib_pyql.instruments.swap cimport Swap
from lifelib_pyql.handle cimport static_pointer_cast, shared_ptr
from lifelib_pyql.indexes.ibor_index cimport IborIndex
from lifelib_pyql.time.date cimport Period, Date
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.time._period cimport Days
from lifelib_pyql.time.dategeneration cimport DateGeneration
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
from lifelib_pyql.pricingengines.engine cimport PricingEngine
cimport lifelib_pyql.indexes._ibor_index as _ii
cimport lifelib_pyql._instrument as _in
from lifelib_pyql.instruments.vanillaswap cimport VanillaSwap
from lifelib_pyql.instruments._vanillaswap cimport VanillaSwap as _VanillaSwap
from .swap cimport Type

cdef class MakeVanillaSwap:
    def __init__(self, Period swap_tenor not None,
                 IborIndex ibor_index not None,
                 Rate fixed_rate=Null[Real](),
                 Period forward_start not None=Period(0, Days)):
        self._thisptr = new _make_vanilla_swap.MakeVanillaSwap(
            deref(swap_tenor._thisptr),
            static_pointer_cast[_ii.IborIndex](ibor_index._thisptr),
            fixed_rate,
            deref(forward_start._thisptr))

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __call__(self):
        cdef VanillaSwap instance = VanillaSwap.__new__(VanillaSwap)
        cdef shared_ptr[_VanillaSwap] temp = <shared_ptr[_VanillaSwap]>deref(self._thisptr)
        instance._thisptr = static_pointer_cast[_in.Instrument](temp)
        return instance

    def receive_fixed(self, bool flag=True):
        self._thisptr.receiveFixed(flag)
        return self

    def with_type(self, Type type):
        self._thiptr.withType(type)
        return self

    def with_nominal(self, Real n):
        self._thisptr.withNominal(n)
        return self

    def with_settlement_days(self, Natural settlement_days):
        self._thisptr.withSettlementDays(settlement_days)
        return self

    def with_effective_date(self, Date effective_date not None):
        self._thisptr.withEffectiveDate(effective_date._thisptr)
        return self

    def with_termination_date(self, Date termination_date not None):
        self._thisptr.withTerminationDate(termination_date._thisptr)
        return self

    def with_rule(self, DateGeneration rule):
        self._thisptr.withRule(rule)
        return self

    def with_fixed_leg_tenor(self, Period t not None):
        self._thisptr.withFixedLegTenor(deref(t._thisptr))
        return self

    def with_fixed_leg_day_count(self, DayCounter dc not None):
        self._thisptr.withFixedLegDayCount(deref(dc._thisptr))
        return self

    def with_floating_leg_tenor(self, Period t not None):
        self._thisptr.withFloatingLegTenor(deref(t._thisptr))
        return self

    def with_floating_leg_day_count(self, DayCounter dc not None):
        self._thisptr.withFloatingLegDayCount(deref(dc._thisptr))
        return self

    def with_floating_leg_spread(self, Spread sp):
        self._thisptr.withFloatingLegSpread(sp)
        return self

    def with_discounting_term_structure(self, HandleYieldTermStructure yts not None):
        self._thisptr.withDiscountingTermStructure(yts.handle)
        return self

    def with_pricing_engine(self, PricingEngine engine not None):
        self._thisptr.withPricingEngine(engine._thisptr)
        return self
