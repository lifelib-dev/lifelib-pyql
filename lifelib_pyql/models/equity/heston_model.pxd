# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from . cimport _heston_model as _hm

from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.models.calibration_helper cimport BlackCalibrationHelper


cdef class HestonModelHelper(BlackCalibrationHelper):
    pass

cdef class HestonModel:
    cdef shared_ptr[_hm.HestonModel] _thisptr
