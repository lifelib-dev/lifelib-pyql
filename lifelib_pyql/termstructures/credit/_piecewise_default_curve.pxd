"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from libcpp.vector cimport vector

from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.termstructures.credit._credit_helpers cimport DefaultProbabilityHelper
from lifelib_pyql.termstructures._default_term_structure cimport DefaultProbabilityTermStructure
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._calendar cimport Calendar

cdef extern from 'ql/termstructures/credit/probabilitytraits.hpp' namespace 'QuantLib':

    cdef cppclass HazardRate:
        pass

    cdef cppclass SurvivalProbability:
        pass

    cdef cppclass DefaultDensity:
        pass

cdef extern from 'ql/math/interpolations/all.hpp' namespace 'QuantLib':
    cdef cppclass Linear:
        pass

    cdef cppclass LogLinear:
        pass

    cdef cppclass BackwardFlat:
        pass



cdef extern from 'ql/termstructures/credit/piecewisedefaultcurve.hpp' namespace 'QuantLib':
    cdef cppclass PiecewiseDefaultCurve[T, I](DefaultProbabilityTermStructure):
        PiecewiseDefaultCurve(Date& referenceDate,
                              vector[shared_ptr[DefaultProbabilityHelper]]& instruments,
                              DayCounter& dayCounter,
                              Real accuracy) except +
        PiecewiseDefaultCurve(Natural settlementDays,
                              Calendar& calendar,
                              vector[shared_ptr[DefaultProbabilityHelper]]& instruments,
                              DayCounter& dayCounter,
                              Real accuracy) except +
        vector[Time]& times() except +
        vector[Date]& dates() except +
        vector[Real]& data() except +
