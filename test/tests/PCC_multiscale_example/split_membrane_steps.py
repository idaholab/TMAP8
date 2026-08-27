#!/usr/bin/env python3
"""Split the accumulated membrane sub-app CSV into one CSV per fuel-cycle timestep.

The steady coupling runs the 1D membrane sub-app once per fuel-cycle timestep with
``keep_full_output_history = true``, so every step's membrane solve is appended into a single file
``membrane_steps/pcc_membrane_step.csv``. MOOSE cannot natively write a separate CSV per parent
timestep, so this post-processing script divides that accumulated file into per-step files.

Each FullSolveMultiApp invocation restarts the sub-app from its internal time ~0, so a *decrease* in
the sub-app ``time`` column marks the boundary between fuel-cycle steps. Each segment (one
invocation) is written to its own file, named by step index and the fuel-cycle time taken from the
parent output ``steady_fuel_cycle_PCC_membrane_out.csv``.
"""

import glob
import os

import numpy as np
import pandas as pd

# Resolve paths for both the test tree and the documentation build.
script_folder = os.path.dirname(os.path.abspath(__file__))
if "/TMAP8/doc/" in script_folder:
    path = "../../../../test/tests/PCC_multiscale_example"
else:
    path = script_folder

membrane_dir = os.path.join(path, "membrane_steps")
accumulated_csv = os.path.join(membrane_dir, "pcc_membrane_step.csv")
parent_csv = os.path.join(path, "steady_fuel_cycle_PCC_membrane_out.csv")

if not os.path.isfile(accumulated_csv):
    raise FileNotFoundError(
        "Accumulated membrane CSV not found: {}. Run the coupled simulation first.".format(
            accumulated_csv
        )
    )

membrane = pd.read_csv(accumulated_csv)

# Segment the accumulated file at each sub-app time reset (start of a new fuel-cycle step).
time = membrane["time"].to_numpy()
boundaries = [0] + list(np.where(np.diff(time) < 0.0)[0] + 1) + [len(membrane)]
segments = [membrane.iloc[boundaries[i]:boundaries[i + 1]] for i in range(len(boundaries) - 1)]
n_steps = len(segments)

# Fuel-cycle time for each step, from the parent output (one solve per step; single-pass coupling).
fuel_cycle_times = None
if os.path.isfile(parent_csv):
    parent = pd.read_csv(parent_csv)
    ptimes = parent["time"].to_numpy()
    if len(ptimes) == n_steps + 1:  # parent has an extra t=0 (initial) row
        fuel_cycle_times = ptimes[1:]
    elif len(ptimes) >= n_steps:
        fuel_cycle_times = ptimes[-n_steps:]  # align the trailing N, warn below
        if len(ptimes) != n_steps:
            print(
                "Note: parent has {} rows for {} membrane steps; aligned the trailing {}.".format(
                    len(ptimes), n_steps, n_steps
                )
            )
if fuel_cycle_times is None:
    print("Note: parent output not found/aligned; naming per-step files by index only.")
    fuel_cycle_times = [np.nan] * n_steps

# Remove any previous per-step files so reruns start clean.
for old in glob.glob(os.path.join(membrane_dir, "step_*.csv")):
    os.remove(old)

for k, segment in enumerate(segments):
    t_fc = fuel_cycle_times[k]
    if np.isfinite(t_fc):
        fname = "step_{:04d}_t{:.4g}.csv".format(k + 1, t_fc)
    else:
        fname = "step_{:04d}.csv".format(k + 1)
    segment.to_csv(os.path.join(membrane_dir, fname), index=False)

print(
    "Split {} into {} per-step files in {}/ (e.g. {}).".format(
        os.path.basename(accumulated_csv),
        n_steps,
        membrane_dir,
        "step_0001_t{:.4g}.csv".format(fuel_cycle_times[0])
        if n_steps and np.isfinite(fuel_cycle_times[0])
        else "step_0001.csv",
    )
)
