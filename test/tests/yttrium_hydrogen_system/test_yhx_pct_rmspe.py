# This python script tests if the RMSPE (between TMAP8
# predictions and analytical expressions) is smaller than 0.1

import os
import unittest

from yhx_pct_metrics import compute_prediction_rmspe

PREDICTION_RMSPE_LIMIT = 0.1

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


class TestYHxPCTRMSPE(unittest.TestCase):
    def test_prediction_rmspe(self):
        rmspe = compute_prediction_rmspe(SCRIPT_DIR)
        self.assertLess(
            rmspe,
            PREDICTION_RMSPE_LIMIT,
            msg=(
                f"YHx PCT prediction RMSPE {rmspe:.6f}% exceeds "
                f"{PREDICTION_RMSPE_LIMIT:.6f}%."
            ),
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
