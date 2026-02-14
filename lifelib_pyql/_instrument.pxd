from lifelib_pyql.types cimport Real

from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.time._date cimport Date
from libcpp.string cimport string
from libcpp cimport bool

cdef extern from 'ql/instrument.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Instrument:
        Instrument()
        bool isExpired()
        Real NPV() except +
        Real errorEstimate() except +
        Date& valuationDate() except +
        void setPricingEngine(shared_ptr[PricingEngine]&)
        T result[T](const string& tag)
