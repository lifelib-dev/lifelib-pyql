include '../../types.pxi'
from lifelib_pyql.pricingengines._pricing_engine cimport PricingEngine
from lifelib_pyql.handle cimport Handle
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from lifelib_pyql.termstructures.volatility.swaption._swaption_vol_structure \
    cimport SwaptionVolatilityStructure
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql._quote cimport Quote

cdef extern from 'ql/pricingengines/swaption/blackswaptionengine.hpp' namespace 'QuantLib::detail':
    cdef cppclass BlackStyleSwaptionEngine[T](PricingEngine):
        BlackStyleSwaptionEngine()
        enum CashAnnuityModel:
            SwapRate
            DiscountCurve
    cdef struct Black76Spec:
        pass

    cdef struct BachelierSpec:
        pass

#ctypedef BlackSwaptionEngine.CashAnnuityModel CashAnnuityModel

cdef extern from 'ql/pricingengines/swaption/blackswaptionengine.hpp' namespace 'QuantLib':
    cdef cppclass BlackSwaptionEngine(BlackStyleSwaptionEngine[Black76Spec]):
        BlackSwaptionEngine(const Handle[YieldTermStructure]& discountCurve,
                            Volatility vol,
                            const DayCounter& dc, #=Actual365Fixed(),
                            Real displacement, #= 0.0,
                            BlackSwaptionEngine.CashAnnuityModel model)# = DiscountCurve);
        BlackSwaptionEngine(const Handle[YieldTermStructure]& discountCurve,
                            const Handle[Quote]& vol,
                            const DayCounter& dc,# = Actual365Fixed(),
                            Real displacement, #= 0.0,
                            BlackSwaptionEngine.CashAnnuityModel model)# = DiscountCurve);
        BlackSwaptionEngine(const Handle[YieldTermStructure]& discountCurve,
                            const Handle[SwaptionVolatilityStructure]& vol,
                            BlackSwaptionEngine.CashAnnuityModel model) except +# = DiscountCurve)

    cdef cppclass BachelierSwaptionEngine(BlackStyleSwaptionEngine[BachelierSpec]):
        BachelierSwaptionEngine(const Handle[YieldTermStructure]& discountCurve,
                                Volatility vol,
                                const DayCounter& dc,# = Actual365Fixed(),
                                BachelierSwaptionEngine.CashAnnuityModel model)# = DiscountCurve);
        BachelierSwaptionEngine(const Handle[YieldTermStructure]& discountCurve,
                                const Handle[Quote]& vol,
                                const DayCounter& dc,# = Actual365Fixed(),
                                BachelierSwaptionEngine.CashAnnuityModel model)# = DiscountCurve);
        BachelierSwaptionEngine(const Handle[YieldTermStructure]& discountCurve,
                                const Handle[SwaptionVolatilityStructure]& vol,
                                BachelierSwaptionEngine.CashAnnuityModel model) except +# = DiscountCurve)
