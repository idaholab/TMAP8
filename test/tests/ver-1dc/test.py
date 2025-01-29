import mms
import unittest
from mooseutils import fuzzyEqual, fuzzyAbsoluteEqual

class TestMMS(unittest.TestCase):
    def test(self):
        df1 = mms.run_spatial('mms.i', 4, y_pp=['L2u'])
        fig = mms.ConvergencePlot(xlabel=r'$\Delta$t', ylabel='$L_2$ Error')
        fig.plot(df1, label=['L2u'], marker='o', markersize=8, num_fitted_points=3, slope_precision=1)
        fig.save('mms_spatial.png')
        for key,value in fig.label_to_slope.items():
            print("%s, %f" % (key, value))
            self.assertTrue(fuzzyAbsoluteEqual(value, 2., .1))

if __name__ == '__main__':
    unittest.main(__name__, verbosity=2)
