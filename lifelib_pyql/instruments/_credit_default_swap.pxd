from lifelib_pyql.types cimport Natural, Rate, Real

from libcpp cimport bool
from lifelib_pyql.handle cimport optional, Handle, shared_ptr
from lifelib_pyql.termstructures._yield_term_structure cimport YieldTermStructure
from .._instrument cimport Instrument
from lifelib_pyql._cashflow cimport CashFlow, Leg
from lifelib_pyql.time._calendar cimport BusinessDayConvention
from lifelib_pyql.time._date cimport Date, Period
from lifelib_pyql.time._daycounter cimport DayCounter
from lifelib_pyql.time._schedule cimport Schedule, DateGeneration
from lifelib_pyql.default cimport Protection

cdef extern from 'ql/instruments/claim.hpp' namespace 'QuantLib':

    cdef cppclass Claim:
        Claim()

cdef extern from 'ql/instruments/creditdefaultswap.hpp' namespace 'QuantLib':

    cdef cppclass CreditDefaultSwap(Instrument):
        enum PricingModel:
            pass
        CreditDefaultSwap(Protection side,
                          Real notional,
                          Rate spread,
                          Schedule& schedule,
                          BusinessDayConvention paymentConvention,
                          DayCounter& dayCounter,
                          bool settlesAccrual, # = true,
                          bool paysAtDefaultTime, # = true,
                          Date& protectionStart, #= Date(),
                          shared_ptr[Claim]&, # = boost::shared_ptr<Claim>(),
                          DayCounter& last_period_day_counter, # = DayCounter()
                          bool rebates_accrual, # = true
                          Date tradeDate, # = Date(),
                          Natural cashSettlementDays, # = 3
        )
        CreditDefaultSwap(Protection side,
                          Real notional,
                          Rate upfront,
                          Rate spread,
                          Schedule& schedule,
                          BusinessDayConvention paymentConvention,
                          DayCounter& dayCounter,
                          bool settlesAccrual, # = true,
                          bool paysAtDefaultTime, # = true,
                          Date& protectionStart, #= Date(),
                          Date& upfrontDate, #=Date(),
                          shared_ptr[Claim]&, # = boost::shared_ptr<Claim>(),
                          DayCounter& last_period_day_counter, # = DayCounter()
                          bool rebates_accrual, # = true
                          Date tradeDate, # = Date(),
                          Natural cashSettlementDays, # = 3
                          ) except +
        Protection side()
        Real notional()
        Rate runningSpread()
        optional[Rate] upfront()
        bool settlesAccrual()
        bool paysAtDefaultTime()
        const Leg& coupons()
        const Date& protectionStartDate()
        const Date& protectionEndDate()
        bool rebatesAccrual()
        const shared_ptr[CashFlow]& accrualRebate()
        const Date& tradeDate()
        Natural cashSettlementDays()

        Rate fairUpfront() except +
        Rate fairSpread() except +
        Real couponLegBPS() except +
        Real upfrontBPS() except +
        Real couponLegNPV() except +
        Real defaultLegNPV() except +
        Real upfrontNPV() except +
        Real accrualRebateNPV() except +

        Rate conventionalSpread(Real conventionalRecovery,
                                Handle[YieldTermStructure]& discountCurve,
                                const DayCounter dayCounter,
                                CreditDefaultSwap.PricingModel model # = Midpoint
        ) except +
        Rate impliedHazardRate(Real targetNPV,
                               const Handle[YieldTermStructure]& discountCurve,
                               const DayCounter dayCounter,
                               Real recoveryRate, # = 0.4,
                               Real accuracy, # = 1.0e-8
                               CreditDefaultSwap.PricingModel model # = Midpoint
        ) except +
    Date cdsMaturity(const Date& tradeDate, const Period& tenor, DateGeneration rule) except +ValueError
