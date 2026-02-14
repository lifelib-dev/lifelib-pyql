from lifelib_pyql.types cimport Natural, Real
from cython.operator cimport dereference as deref
from libcpp.pair cimport pair
from libcpp.vector cimport vector

from lifelib_pyql.handle cimport shared_ptr

from . cimport _rate_helpers as _rh
from .. cimport _yield_term_structure as _yts

from .rate_helpers cimport RateHelper
from lifelib_pyql.time.date cimport Date, date_from_qldate
cimport lifelib_pyql.time._date as _date
from lifelib_pyql.time.daycounter cimport DayCounter
from lifelib_pyql.time.calendar cimport Calendar
from lifelib_pyql.math.interpolation cimport Linear, LogLinear, BackwardFlat, Cubic
from .bootstraptraits cimport BootstrapTrait
from itertools import product


class PiecewiseYieldCurve:
    """A piecewise yield curve.

    ``Generics`` class parametered by a couple (trait, interpolator).

    Parameters
    ----------
    trait : BootstrapTrait
        the kind of curve. Must be either 'BootstrapTrait.Discount', 'BootstrapTrait.ZeroYield'
         or 'BootstrapTrait.ForwardRate'
    interpolator : Interpolator
        the kind of interpolator. Must be either 'Linear', 'LogLinear', 'BackwardFlat' or
        'Cubic'


    """
    def __class_getitem__(cls, tuple tup):
        T, I = tup
        return globals()[f"{T.name}{I.__name__}PiecewiseYieldCurve"]



cdef class DiscountLinearPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Linear i=Linear(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.Discount
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, Linear i=Linear(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef DiscountLinearPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.Discount
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Linear].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class DiscountLogLinearPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 LogLinear i=LogLinear(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.Discount
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, LogLinear i=LogLinear(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef DiscountLogLinearPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.Discount
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.LogLinear].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class DiscountBackwardFlatPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 BackwardFlat i=BackwardFlat(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.Discount
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, BackwardFlat i=BackwardFlat(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef DiscountBackwardFlatPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.Discount
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.BackwardFlat].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class DiscountCubicPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Cubic i=Cubic(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.Discount
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, Cubic i=Cubic(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef DiscountCubicPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.Discount
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.Discount, intpl.Cubic].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ZeroYieldLinearPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Linear i=Linear(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ZeroYield
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, Linear i=Linear(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ZeroYieldLinearPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ZeroYield
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Linear].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ZeroYieldLogLinearPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 LogLinear i=LogLinear(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ZeroYield
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, LogLinear i=LogLinear(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ZeroYieldLogLinearPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ZeroYield
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.LogLinear].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ZeroYieldBackwardFlatPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 BackwardFlat i=BackwardFlat(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ZeroYield
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, BackwardFlat i=BackwardFlat(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ZeroYieldBackwardFlatPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ZeroYield
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.BackwardFlat].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ZeroYieldCubicPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Cubic i=Cubic(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ZeroYield
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, Cubic i=Cubic(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ZeroYieldCubicPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ZeroYield
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ZeroYield, intpl.Cubic].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ForwardRateLinearPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Linear i=Linear(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ForwardRate
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, Linear i=Linear(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ForwardRateLinearPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ForwardRate
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Linear].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ForwardRateLogLinearPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 LogLinear i=LogLinear(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ForwardRate
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, LogLinear i=LogLinear(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ForwardRateLogLinearPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ForwardRate
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.LogLinear].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ForwardRateBackwardFlatPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 BackwardFlat i=BackwardFlat(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ForwardRate
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, BackwardFlat i=BackwardFlat(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ForwardRateBackwardFlatPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ForwardRate
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.BackwardFlat].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r


cdef class ForwardRateCubicPiecewiseYieldCurve(YieldTermStructure):
    def __init__(self, Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Cubic i=Cubic(),
                 Real accuracy = 1e-12):
        """ Floating yield curve

        updating evaluation_date in Settings will change the reference_date.

        Parameters
        ----------
        settlement_days : int
            The settlement date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        self.trait = BootstrapTrait.ForwardRate
        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        self._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic](
                settlement_days, calendar._thisptr, instruments,
                deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic].bootstrap_type(accuracy)
            )
        )

    cdef inline _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic]* curve(self) noexcept nogil:
        return <_pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic]*>self._thisptr.get()

    @classmethod
    def from_reference_date(cls, Date reference_date, list helpers,
                            DayCounter daycounter not None, Cubic i=Cubic(),
                            Real accuracy=1e-12):
        """Fixed `reference_date` yield curve

        Parameters
        ----------
        reference_date : quantlib.time.date.Date
            The curve's reference date
        calendar: quantlib.time.calendar.Calendar
            curve's calendar
        helpers : list of quantlib.termstructures.rate_helpers.RateHelper
           a list of rate helpers used to create the curve
        day_counter : quantlib.time.day_counter.DayCounter
            the day counter used by this curve
        accuracy : double (default 1e-12)
            the tolerance

        """

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments
        cdef ForwardRateCubicPiecewiseYieldCurve instance = cls.__new__(cls)

        for helper in helpers:
            instruments.push_back((<RateHelper?> helper)._thisptr)

        instance.trait = BootstrapTrait.ForwardRate
        instance._thisptr.reset(
            new _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic](
                reference_date._thisptr, instruments, deref(daycounter._thisptr),
                i._thisptr,
                _pyc.PiecewiseYieldCurve[_trait.ForwardRate, intpl.Cubic].bootstrap_type(accuracy)
            )
        )
        return instance


    @property
    def data(self):
        """list of curve data"""
        return self.curve().data()

    @property
    def times(self):
        """list of curve times"""
        return self.curve().times()

    @property
    def dates(self):
        """list of curve dates"""
        cdef list r  = []
        cdef _date.Date qldate
        for qldate in self.curve().dates():
            r.append(date_from_qldate(qldate))

        return r

    @property
    def nodes(self):
        cdef:
            list r = []
            pair[_date.Date, double] p
            vector[pair[_date.Date, double]] v = self.curve().nodes()
        for p in v:
            r.append((date_from_qldate(p.first), p.second))
        return r

