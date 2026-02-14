""" Simple example pricing a European option
using a Black&Scholes Merton process."""
from __future__ import print_function

from lifelib_pyql.instruments.api import (EuropeanExercise, PlainVanillaPayoff, OptionType,
                                      VanillaOption)
from lifelib_pyql.pricingengines.api import AnalyticEuropeanEngine
from lifelib_pyql.processes.black_scholes_process import BlackScholesMertonProcess
from lifelib_pyql.quotes import SimpleQuote
from lifelib_pyql.settings import Settings
from lifelib_pyql.time.api import TARGET, Actual365Fixed, today
from lifelib_pyql.termstructures.yields.api import FlatForward, HandleYieldTermStructure
from lifelib_pyql.termstructures.volatility.api import BlackConstantVol


settings = Settings.instance()
calendar = TARGET()

offset = 366

todays_date = today() - offset
settlement_date = todays_date + 2

settings.evaluation_date = todays_date

# options parameters
option_type = OptionType.Put
underlying = 36
strike = 40
dividend_yield = 0.00
risk_free_rate = 0.06
volatility = 0.20
maturity = settlement_date + 363
daycounter = Actual365Fixed()

underlyingH = SimpleQuote(underlying)

# bootstrap the yield/dividend/vol curves
flat_term_structure = HandleYieldTermStructure()
flat_dividend_ts = HandleYieldTermStructure()

flat_term_structure.link_to(
    FlatForward(
        reference_date=settlement_date,
        forward=risk_free_rate,
        daycounter=daycounter
    )
)

flat_dividend_ts.link_to(
    FlatForward(
        reference_date=settlement_date,
        forward=dividend_yield,
        daycounter=daycounter
    )
)

flat_vol_ts = BlackConstantVol(
    settlement_date, calendar, volatility, daycounter
)

black_scholes_merton_process = BlackScholesMertonProcess(
    underlyingH, flat_dividend_ts, flat_term_structure, flat_vol_ts
)

payoff = PlainVanillaPayoff(option_type, strike)

european_exercise = EuropeanExercise(maturity)

european_option = VanillaOption(payoff, european_exercise)


method = 'Black-Scholes'
analytic_european_engine = AnalyticEuropeanEngine(black_scholes_merton_process)

european_option.set_pricing_engine(analytic_european_engine)

print(
    'today: %s settlement: %s maturity: %s' % (
        todays_date, settlement_date, maturity
    )
)
print('NPV: %f\n' % european_option.net_present_value)


### EOF #######################################################################
