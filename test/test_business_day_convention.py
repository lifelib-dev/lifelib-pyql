import unittest

from lifelib_pyql.time.businessdayconvention import (
    Following, Preceding)

from lifelib_pyql.time.businessdayconvention import BusinessDayConvention


class TestBusinessDayConvention(unittest.TestCase):

    def test_creation(self):

        b = BusinessDayConvention['Following']

        self.assertEqual(b.name, 'Following')
        self.assertEqual(b, Following)

        c = BusinessDayConvention(Preceding)
        self.assertEqual(c, Preceding)


if __name__ == '__main__':
    unittest.main()
