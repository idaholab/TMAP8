"""Compare PCC-enhanced two-DIR fuel-cycle inventories with the Meschini baseline.

Reads the multiscale result (``dir_pcc_fuel_cycle_out.csv``) and the baseline Meschini
fuel cycle and overlays the critical
component inventories (TES, VP, FCU, ISS, membrane, storage) on a log-log plot, matching
the style of ``fuel_cycle_2023/fuel_cycle_PCC_plot.py``.

Baseline is drawn solid and PCC dashed with sparse open markers so near-overlapping
curves stay distinguishable, plus an inset that zooms into the late-time storage
divergence. The storage curve is shifted so its minimum sits at the required reserve
(minimum allowed) inventory:
    storage_plot = T_10_storage - min(T_10_storage) + reserve_inventory
(the same transform used in ``fuel_cycle_PCC_plot.py``).
"""

import io
import os
import time

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib import gridspec

plt.rcParams.update({"font.size": 18})

# Resolve paths relative to this script (scripts/ lives one level below the test dir)
script_folder = os.path.dirname(os.path.abspath(__file__))
if "/TMAP8/doc/" in script_folder:  # documentation build
    test_dir = "../../../../test/tests/PCC_multiscale_example"
else:  # test folder
    test_dir = script_folder
pcc_candidates = [
    os.path.join(test_dir, "dir_pcc_fuel_cycle_2rt_10Pa_out.csv"),
    os.path.join(test_dir, "gold", "dir_pcc_fuel_cycle_2rt_10Pa_out_reference.csv"),
]
base_candidates = [
    os.path.join(test_dir, "gold", "fuel_cycle_base_out_reference.csv"),
    os.path.join(test_dir, "..", "fuel_cycle_2023", "fuel_cycle_base_out.csv"),
]
dir_csv = next((candidate for candidate in pcc_candidates if os.path.isfile(candidate)), None)
base_csv = next((candidate for candidate in base_candidates if os.path.isfile(candidate)), None)
if dir_csv is None:
    raise FileNotFoundError(
        "Could not find a PCC-enhanced fuel-cycle CSV in {}".format(pcc_candidates)
    )
if base_csv is None:
    raise FileNotFoundError(
        "Could not find a baseline fuel-cycle CSV in {}".format(base_candidates)
    )
figures_dir = os.path.join(test_dir, "figures")
os.makedirs(figures_dir, exist_ok=True)

time_unit = 3600 * 24  # seconds per day
two_year = 3600 * 24 * 365 * 2  # s


def interpolation_on_expected_input(data_x, data_y, expected_input):
    """Linearly interpolate ``data_y`` at ``expected_input`` along ``data_x``."""
    left_limit = np.argwhere(np.diff(data_x < expected_input))[0][0]
    right_limit = left_limit + 1
    return (expected_input - data_x[left_limit]) / (
        data_x[right_limit] - data_x[left_limit]
    ) * (data_y[right_limit] - data_y[left_limit]) + data_y[left_limit]


def read_csv_live(path, retries=5, delay=0.5):
    """Read a CSV that may be concurrently written by a running MOOSE simulation.

    MOOSE appends rows and flushes/closes the file each output step, so the only
    inconsistency a reader can catch is an incomplete trailing line. Read a snapshot,
    drop a trailing line that is truncated (file does not end in a newline) or has the
    wrong column count, and retry briefly if the file is missing or has no complete
    data row yet.
    """
    last_err = None
    for _ in range(retries):
        if os.path.isfile(path):
            with open(path, "r") as f:
                text = f.read()
            lines = text.splitlines()
            if len(lines) >= 2:
                ncol = len(lines[0].split(","))
                if not text.endswith("\n") or len(lines[-1].split(",")) != ncol:
                    lines = lines[:-1]  # drop incomplete trailing row
                if len(lines) >= 2:  # header + >=1 complete data row
                    try:
                        return pd.read_csv(io.StringIO("\n".join(lines) + "\n"))
                    except Exception as e:  # rare parse race
                        last_err = e
        time.sleep(delay)
    raise RuntimeError(
        f"Could not read a complete data row from {path} after {retries} attempts: {last_err}"
    )


# Required reserve (minimum allowed) storage inventory, kg
tritium_burn_rate = 8.99e-7  # kg/s
TBE = 0.02
q = 0.25
t_res = 24 * 3600  # s
AF = 0.7
reserve_inventory = tritium_burn_rate / TBE * q * t_res * AF
print(f"Required reserve inventory = {round(reserve_inventory, 3)} kg")

base = pd.read_csv(base_csv)
pcc = read_csv_live(dir_csv)

# initial inventories differ between the two models
init_base = base["T_10_storage"].values[0]
init_pcc = pcc["T_10_storage"].values[0]


def storage_refined(df):
    """Shift the storage so its minimum sits at the reserve (minimum allowed)."""
    s = df["T_10_storage"].values
    return s - np.min(s) + reserve_inventory


# Diagnostics on the RAW storage inventory (the plotted storage is the shifted curve)
for name, df, init in [("Baseline", base, init_base), ("PCC", pcc, init_pcc)]:
    t_days = df["time"].values / time_unit
    s = df["T_10_storage"].values
    imin = int(np.argmin(s))
    print(
        f"{name}: storage min = {round(s[imin], 3)} kg at {round(t_days[imin], 3)} days"
    )
    try:
        end_inv = interpolation_on_expected_input(t_days, s, two_year / time_unit)
        print(
            f"{name}: end (2 yr) inventory = {round(end_inv, 3)} kg "
            f"({round(end_inv / init, 2)} I_startup)"
        )
    except IndexError:
        print(f"{name}: end (2 yr) inventory = not reached within the simulation")
    try:
        doubling = interpolation_on_expected_input(s, t_days, init * 2)
        print(f"{name}: doubling time = {round(doubling, 3)} days")
    except IndexError:
        print(f"{name}: doubling time = not reached within the simulation")

# Critical components: (column, label, color)
components = [
    ("T_10_storage", "Storage", "C5"),
    ("T_09_ISS", "ISS", "C3"),
    ("T_02_TES", "TES", "C0"),
    ("T_07_vacuum", "VP", "C1"),
    ("T_08_FCU", "FCU", "C2"),
    ("T_11_membrane", "Membrane", "C4"),
]

t_base = base["time"].values / time_unit
t_pcc = pcc["time"].values / time_unit

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Style legend (baseline = transparent line, PCC = solid line)
(hand_base,) = ax.plot([], [], '--', color="k", lw=2, alpha=0.35, label="baseline")
(hand_pcc,) = ax.plot([], [], color="k", lw=2, label="PCC")

component_handles = []
for col, label, color in components:
    y_base = storage_refined(base) if col == "T_10_storage" else base[col].values
    y_pcc = storage_refined(pcc) if col == "T_10_storage" else pcc[col].values
    # Baseline drawn as a transparent line; PCC drawn as a solid opaque line on top, so the
    # PCC result stands out against the faded baseline without dashes or markers.
    ax.plot(t_base, y_base, "--", color=color, lw=1.5, alpha=0.35)
    (curve,) = ax.plot(t_pcc, y_pcc, "-", color=color, lw=1.8, label=label)
    component_handles.append(curve)

ax.set_xlabel("Time (days)")
ax.set_ylabel("Tritium Inventory (kg)")
legend1 = ax.legend(handles=[hand_base, hand_pcc], loc="upper left", fontsize=16)
ax.add_artist(legend1)
ax.legend(handles=component_handles, loc="lower right", ncols=2, fontsize=16)
ax.set_xlim(left=0.1, right=650)
ax.set_ylim(1e-8, 1e2)
plt.xscale("log")
plt.yscale("log")
plt.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

fig_path = os.path.join(figures_dir, "dir_pcc_inventory_comparison.png")
plt.savefig(fig_path, bbox_inches="tight", dpi=300)
plt.close(fig)
print(f"Saved {fig_path}")
