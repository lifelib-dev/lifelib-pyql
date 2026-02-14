include '../types.pxi'
from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp cimport bool

from lifelib_pyql.handle cimport shared_ptr, Handle
from lifelib_pyql.time.date cimport Period
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.currency.currency cimport Currency
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.time.businessdayconvention cimport ModifiedFollowing, BusinessDayConvention
from lifelib_pyql.termstructures.yield_term_structure cimport HandleYieldTermStructure
cimport lifelib_pyql.termstructures._yield_term_structure as _yts

cimport lifelib_pyql._index as _in
cimport lifelib_pyql.indexes._ibor_index as _ib

from lifelib_pyql.time.api import calendar_from_name
from lifelib_pyql.market.conventions.swap import params as swap_params


from lifelib_pyql.indexes.interest_rate_index cimport InterestRateIndex

cdef class IborIndex(InterestRateIndex):

    def __init__(self, str family_name, Period tenor not None, Natural settlement_days,
                 Currency currency, Calendar fixing_calendar, int convention,
                 bool end_of_month, DayCounter day_counter not None,
                 HandleYieldTermStructure yts=HandleYieldTermStructure()):
        self._thisptr = shared_ptr[_in.Index](
            new _ib.IborIndex(family_name.encode('utf-8'),
                              deref(tenor._thisptr),
                              settlement_days,
                              deref(currency._thisptr),
                              fixing_calendar._thisptr,
                              <BusinessDayConvention> convention,
                              end_of_month,
                              deref(day_counter._thisptr),
                              yts.handle)
            )

    property business_day_convention:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.businessDayConvention()

    property end_of_month:
        def __get__(self):
            cdef _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            return ref.endOfMonth()

    @property
    def forwarding_term_structure(self):
        cdef:
            _ib.IborIndex* ref = <_ib.IborIndex*>self._thisptr.get()
            HandleYieldTermStructure yts = HandleYieldTermStructure.__new__(HandleYieldTermStructure)
            Handle[_yts.YieldTermStructure] _yts = ref.forwardingTermStructure()
        if not _yts.empty():
            yts.handle.linkTo(_yts.currentLink())
        return yts

    @staticmethod
    def from_name(market, term_structure=HandleYieldTermStructure(), **kwargs):
        """
        Create default IBOR for the market, modify attributes if provided
        """

        row = swap_params(market)
        row = row._replace(**kwargs)

        if row.currency == 'EUR':
            from lifelib_pyql.indexes.ibor.euribor import Euribor
            ibor_index = Euribor(Period(row.floating_leg_period), term_structure)
        else:
            label = row.currency + ' ' + row.floating_leg_reference
            from lifelib_pyql.indexes.ibor.libor import Libor
            ibor_index = Libor(label,
                               Period(row.floating_leg_period),
                               row.settlement_days,
                               Currency.from_name(row.currency),
                               calendar_from_name(row.calendar),
                               DayCounter.from_name(row.floating_leg_daycount),
                               term_structure)

        return ibor_index


cdef class OvernightIndex(IborIndex):
    def __init__(self, str family_name, Natural settlement_days,
                 Currency currency, Calendar fixing_calendar,
                 DayCounter day_counter not None,
                 HandleYieldTermStructure yts=HandleYieldTermStructure()):
        self._thisptr = shared_ptr[_in.Index](
            new _ib.OvernightIndex(family_name.encode('utf-8'),
                              settlement_days,
                              deref(currency._thisptr),
                              fixing_calendar._thisptr,
                              deref(day_counter._thisptr),
                                   yts.handle)
            )
