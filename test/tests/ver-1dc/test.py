import unittest
from mooseutils import fuzzyEqual, fuzzyAbsoluteEqual
import spatial_mms

class TestMMS(unittest.TestCase):
    def test(self):
        fig = spatial_mms.run()
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .1))

if __name__ == '__main__':
    unittest.main(__name__, verbosity=2)
