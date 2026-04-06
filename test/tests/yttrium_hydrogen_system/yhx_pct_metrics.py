# The python script compares the TMAP8 predictions against the
# analytical expression of the PCT curve

import os

import numpy as np
import pandas as pd

PREDICTION_FILES = (
    "YHx_PCT_T1273_P3e3_out.csv",
    "YHx_PCT_T1173_P1e3_out.csv",
    "YHx_PCT_T1173_P1e4_out.csv",
    "YHx_PCT_T1173_P5e4_out.csv",
)


def p0_lim_func(temperature):
    return np.exp(
        -26.1
        + 3.88 * 10 ** (-2) * np.array(temperature)
        - 9.7 * 10 ** (-6) * np.square(temperature)
    )


def atom_ratio_eq_upper_func(temperature, pressure):
    return 2 - (
        1
        + np.exp(
            21.6
            - 0.0225 * temperature
            + (-0.0445 + 7.18 * 10 ** (-4) * temperature)
            * np.log(pressure - p0_lim_func(temperature))
        )
    ) ** (-1)


def load_prediction_points(csv_folder):
    points = []
    for filename in PREDICTION_FILES:
        dataframe = pd.read_csv(os.path.join(csv_folder, filename))
        temperature = dataframe["temperature"].iat[-1]
        pressure = dataframe["pressure_H2_enclosure_1_at_interface"].iat[-1]
        prediction = dataframe["atomic_fraction_H_enclosure_2_at_interface"].iat[-1]
        reference = atom_ratio_eq_upper_func(temperature, pressure)
        points.append(
            {
                "filename": filename,
                "temperature": temperature,
                "pressure": pressure,
                "prediction": prediction,
                "reference": reference,
            }
        )

    return points


def compute_prediction_rmspe(csv_folder):
    points = load_prediction_points(csv_folder)
    predictions = np.array([point["prediction"] for point in points])
    references = np.array([point["reference"] for point in points])
    rmse = np.sqrt(np.mean((predictions - references) ** 2))
    return rmse * 100.0 / np.mean(references)
