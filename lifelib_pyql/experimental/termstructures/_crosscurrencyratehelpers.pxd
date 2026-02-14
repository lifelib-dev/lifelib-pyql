from lifelib_pyql.types cimport Natural
from libcpp cimport bool
from lifelib_pyql.handle cimport Handle, shared_ptr
from lifelib_pyql._quote cimport Quote
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.time._calendar cimport Calendar
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.indexes._ibor_index cimport IborIndex
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.termstructures.yields._rate_helpers cimport RelativeDateRateHelper

cdef extern from 'ql/experimental/termstructures/crosscurrencyratehelpers.hpp' namespace 'QuantLib' nogil:
    cdef cppclass ConstNotionalCrossCurrencyBasisSwapRateHelper(RelativeDateRateHelper):
        ConstNotionalCrossCurrencyBasisSwapRateHelper(
            const Handle[Quote]& basis,
            const Period& tenor,
            Natural fixingDays,
            const Calendar& calendar,
            BusinessDayConvention convention,
            bool endOfMonth,
            const shared_ptr[IborIndex]& baseCurrencyIndex,
            const shared_ptr[IborIndex]& quoteCurrencyIndex,
            const Handle[YieldTermStructure]& collateralCurve,
            bool isFxBaseCurrencyCollateralCurrency,
            bool isBasisOnFxBaseCurrencyLeg)


    cdef cppclass MtMCrossCurrencyBasisSwapRateHelper(RelativeDateRateHelper):
        MtMCrossCurrencyBasisSwapRateHelper(const Handle[Quote]& basis,
                                            const Period& tenor,
                                            Natural fixingDays,
                                            const Calendar& calendar,
                                            BusinessDayConvention convention,
                                            bool endOfMonth,
                                            const shared_ptr[IborIndex]& baseCurrencyIndex,
                                            const shared_ptr[IborIndex]& quoteCurrencyIndex,
                                            const Handle[YieldTermStructure]& collateralCurve,
                                            bool isFxBaseCurrencyCollateralCurrency,
                                            bool isBasisOnFxBaseCurrencyLeg,
                                            bool isFxBaseCurrencyLegResettable)
