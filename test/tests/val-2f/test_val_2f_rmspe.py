import os
import unittest

import numpy as np
import pandas as pd

K_MAX = 1000
K_MIN = 300
HEATING_RATE = 3 / 60
CHARGE_TIME = 72 * 3600
COOLDOWN_TIME = 12 * 3600
START_TIME = CHARGE_TIME + COOLDOWN_TIME

INVENTORY_RMSPE_LIMIT = 0.02
DEFAULT_FLUX_RMSPE_LIMIT = 25.0
INF_RECOMBINATION_FLUX_RMSPE_LIMIT = 13.0

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
EXPERIMENT_CSV = os.path.join(SCRIPT_DIR, "gold", "0.1_dpa.csv")
DEFAULT_CSV = os.path.join(SCRIPT_DIR, "val-2f_out.csv")
INF_RECOMBINATION_CSV = os.path.join(SCRIPT_DIR, "val-2f_out_inf_recombination.csv")


def extract_desorption_data(dataframe):
    time = dataframe["time"].to_numpy()
    temperature = dataframe["temperature"].to_numpy()

    if (
        "scaled_flux_surface_left_sieverts" in dataframe.columns
        and "scaled_flux_surface_right_sieverts" in dataframe.columns
    ):
        flux_left = np.abs(dataframe["scaled_flux_surface_left_sieverts"].to_numpy())
        flux_right = np.abs(dataframe["scaled_flux_surface_right_sieverts"].to_numpy())
    else:
        flux_left = dataframe["scaled_flux_surface_left"].to_numpy()
        flux_right = dataframe["scaled_flux_surface_right"].to_numpy()

    total_flux = flux_left + flux_right
    mobile = dataframe["scaled_mobile_deuterium"].to_numpy()
    trapped = sum(
        dataframe[column].to_numpy()
        for column in (
            "scaled_trapped_deuterium_1",
            "scaled_trapped_deuterium_2",
            "scaled_trapped_deuterium_3",
            "scaled_trapped_deuterium_4",
            "scaled_trapped_deuterium_5",
            "scaled_trapped_deuterium_intrinsic",
        )
    )

    mask = time >= START_TIME
    return time[mask], temperature[mask], total_flux[mask], trapped[mask], mobile[mask]


def compute_inventory_rmspe(csv_path):
    dataframe = pd.read_csv(csv_path)
    time, _, total_flux, trapped, mobile = extract_desorption_data(dataframe)

    time = time - time[0]
    escaping = np.zeros_like(total_flux)
    for index, delta_t in enumerate(np.diff(time), start=1):
        escaping[index] = (
            escaping[index - 1]
            + 0.5 * (total_flux[index] + total_flux[index - 1]) * delta_t
        )

    combined_inventory = mobile + escaping + trapped
    initial_inventory = mobile[0] + trapped[0]
    rmse = np.sqrt(np.mean((combined_inventory - initial_inventory) ** 2))
    return rmse * 100.0 / initial_inventory


def compute_flux_rmspe(csv_path):
    experiment = pd.read_csv(EXPERIMENT_CSV)
    dataframe = pd.read_csv(csv_path)

    _, temperature, total_flux, _, _ = extract_desorption_data(dataframe)
    experiment_temperature = experiment["Temperature (K)"].to_numpy()
    experiment_flux = experiment["Deuterium Loss Rate (at/s)"].to_numpy() / (
        12e-3 * 15e-3
    )

    interpolated_flux = np.interp(experiment_temperature, temperature, total_flux)
    rmse = np.sqrt(np.mean((interpolated_flux - experiment_flux) ** 2))
    return rmse * 100.0 / np.mean(experiment_flux)


class TestVal2fRMSPE(unittest.TestCase):
    def test_inventory_rmspe(self):
        rmspe = compute_inventory_rmspe(DEFAULT_CSV)
        self.assertLess(
            rmspe,
            INVENTORY_RMSPE_LIMIT,
            msg=(
                f"Total deuterium inventory RMSPE {rmspe:.6f}% exceeds "
                f"{INVENTORY_RMSPE_LIMIT:.6f}%."
            ),
        )

    def test_inventory_rmspe_inf_recombination(self):
        rmspe = compute_inventory_rmspe(INF_RECOMBINATION_CSV)
        self.assertLess(
            rmspe,
            INVENTORY_RMSPE_LIMIT,
            msg=(
                f"Infinite recombination total deuterium inventory RMSPE {rmspe:.6f}% "
                f"exceeds {INVENTORY_RMSPE_LIMIT:.6f}%."
            ),
        )

    def test_default_flux_rmspe(self):
        rmspe = compute_flux_rmspe(DEFAULT_CSV)
        self.assertLess(
            rmspe,
            DEFAULT_FLUX_RMSPE_LIMIT,
            msg=(
                f"Default recombination deuterium flux RMSPE {rmspe:.6f}% exceeds "
                f"{DEFAULT_FLUX_RMSPE_LIMIT:.6f}%."
            ),
        )

    def test_inf_recombination_flux_rmspe(self):
        rmspe = compute_flux_rmspe(INF_RECOMBINATION_CSV)
        self.assertLess(
            rmspe,
            INF_RECOMBINATION_FLUX_RMSPE_LIMIT,
            msg=(
                f"Infinite recombination deuterium flux RMSPE {rmspe:.6f}% exceeds "
                f"{INF_RECOMBINATION_FLUX_RMSPE_LIMIT:.6f}%."
            ),
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
