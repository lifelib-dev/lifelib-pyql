from lifelib_pyql.types cimport Real Size
from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.models.shortrate.twofactormodels._g2 cimport G2
from lifelib_pyql.pricingengines._pricingengine cimport PricingEngine
from lifelib_pyql.mdethods.finitedifferences.solvers._fdmbackwardsolver cimport FdmSchemeDesc

cdef extern from 'ql/pricingengines/swaption/fdg2swaptionengine.hpp' namespace 'QuantLib' nogil:

    cdef cppclass FdG2SwaptionEngine(PricingEngine):
        FdG2SwaptionEngine(
            shared_ptr[G2]& model,
            Size tGrid, # = 100
            Size xGrid, # = 50,
            Size yGrid, # = 50,
            SIze dampingSteps, # = 0
            Real invEps, # = 1e-5
            const FdmSchemeDesc& schemeDesc) # =FdmSchemeDesc::Hundsdorfer()

            Size intervals)
