from libcpp.vector cimport vector
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.types cimport Real
from lifelib_pyql.time._date cimport Date

from .._cashflow cimport CashFlow

cdef extern from 'ql/cashflows/dividend.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Dividend(CashFlow):
        pass

    cdef cppclass FixedDividend(Dividend):
        FixedDividend(
            Real amount,
            const Date& date)


    vector[shared_ptr[Dividend]] DividendVector(vector[Date]& dividendDates,
                                                vector[Real]& dividends)
