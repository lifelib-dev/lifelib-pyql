include '../types.pxi'

from lifelib_pyql.time._date cimport Date
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector
from lifelib_pyql._time_series cimport TimeSeries

cdef extern from "ql/indexes/indexmanager.hpp" namespace "QuantLib":
    cdef cppclass IndexManager:
        bool hasHistory(const string& name)
        TimeSeries[Real] getHistory(string& name) const
        void setHistory(string& name, TimeSeries[Real]&)
        vector[string] histories()
        void clearHistory(const string name)
        void clearHistories()
        @staticmethod
        IndexManager& instance()
