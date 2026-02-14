from lifelib_pyql.types cimport Real, Size
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.models.shortrate.onefactormodels._hullwhite cimport HullWhite
from lifelib_pyql.methods.finitedifferences.solvers._fdmbackwardsolver cimport FdmSchemeDesc

cdef extern from 'ql/pricingengines/swaption/fdhullwhiteswaptionengine.hpp' namespace 'QuantLib' nogil:

    cdef cppclass FdHullWhiteSwaptionEngine(PricingEngine):
        FdHullWhiteSwaptionEngine(
            shared_ptr[HullWhite]& model,
            Size tGrid, # = 100
            Size xGrid, # = 100
            Size dampingSteps, # = 0
            Real invEps, # = 1e-5
            const FdmSchemeDesc& schemeDesc) # =FdmSchemeDesc::Douglas()
