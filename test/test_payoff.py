import unittest

from lifelib_pyql.payoffs import PlainVanillaPayoff
from lifelib_pyql.option import OptionType

class PayoffTestCase(unittest.TestCase):

    def test_plain_vaniila_payoff(self):

        payoff = PlainVanillaPayoff(OptionType.Call, 10.0)

        self.assertEqual(payoff.option_type, OptionType.Call)
        self.assertEqual(payoff.strike, 10.0)
        self.assertEqual(payoff(30.), 20.)
        payoff = PlainVanillaPayoff(OptionType['Call'], 10.0)
        self.assertEqual(payoff.option_type, OptionType.Call)
        self.assertEqual(payoff.strike, 10.0)
