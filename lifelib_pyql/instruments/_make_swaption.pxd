include '../types.pxi'

from lifelib_pyql.handle cimport shared_ptr
from lifelib_pyql.time._date cimport Date
from lifelib_pyql.time._period cimport Period
from lifelib_pyql.time.businessdayconvention cimport BusinessDayConvention
from lifelib_pyql.indexes._swap_index cimport SwapIndex
from lifelib_pyql.instruments._swaption cimport Swaption, Type, Method
from lifelib_pyql.instruments._vanillaswap cimport VanillaSwap
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine

cdef extern from 'ql/instruments/makeswaption.hpp' namespace 'QuantLib':
    cdef cppclass MakeSwaption:
        MakeSwaption(const shared_ptr[SwapIndex]& swapIndex,
                     const Period& optionTenor,
                     Rate strike)# = Null<Rate>())

        MakeSwaption(const shared_ptr[SwapIndex]& swapIndex,
                     const Date& fixingDate,
                     Rate strike)# = Null<Rate>())

        Swaption operator()

        MakeSwaption& withSettlementType(Type delivery)
        MakeSwaption& withSettlementMethod(Method method)
        MakeSwaption& withOptionConvention(BusinessDayConvention bdc)
        MakeSwaption& withExerciseDate(const Date&)
        MakeSwaption& withUnderlyingType(const VanillaSwap.Type type)
        MakeSwaption& withNominal(Real n)

        MakeSwaption& withPricingEngine(
            const shared_ptr[PricingEngine]& engine)

    shared_ptr[Swaption] get "(QuantLib::ext::shared_ptr<QuantLib::Swaption>)" (MakeSwaption) except +
