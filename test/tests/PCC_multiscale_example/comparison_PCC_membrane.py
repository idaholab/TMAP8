#!/usr/bin/env python3
"""Comparison / verification plots for the PCC membrane <-> fuel-cycle MultiApp coupling.

The tritium-separation membrane is modeled as an upstream CONTAINER (gas plenum, initially 0 Pa)
fed by the TES (T_02_TES/residence2). A 1D proton-conducting-ceramic (BCY) membrane sub-app,
co-evolved in lock-step (TransientMultiApp), permeates tritium from the container to the heat
exchanger; the un-permeated retentate (T_11_membrane/residence11) is recycled to the TES. This
script plots the container pressure history (the key verification curve), the physics-based
extraction efficiency (instantaneous and cumulative, vs the lumped 0.85 assumption with RMSPE), the
flow split, and the global tritium conservation.

Run as part of the test suite (RunCommand) or standalone for documentation figures.
"""

import os

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Resolve data/figure paths for both the test tree and the documentation build.
script_folder = os.path.dirname(os.path.abspath(__file__))
if "/TMAP8/doc/" in script_folder:
    path = "../../../../test/tests/PCC_multiscale_example"
else:
    path = script_folder

# Prefer a freshly produced output; fall back to the committed gold.
candidates = [
    os.path.join(path, "fuel_cycle_PCC_membrane_out.csv"),
    os.path.join(path, "gold", "fuel_cycle_PCC_membrane_out.csv"),
]
csv_file = next((c for c in candidates if os.path.isfile(c)), None)
if csv_file is None:
    raise FileNotFoundError("Could not find fuel_cycle_PCC_membrane_out.csv in {}".format(candidates))

data = pd.read_csv(csv_file)

eta_2_lumped = 0.85  # the fixed extraction efficiency used by the lumped fuel_cycle_PCC.i
residence11 = 100.0  # membrane container retentate residence time [s] (fuel cycle)

time = data["time"].to_numpy()
pressure = data["membrane_upstream_pressure"].to_numpy()
holdup = data["T_11_membrane"].to_numpy()
eta_inst = data["eta_2_calculated"].to_numpy()
eta_cum = data["eta_2_cumulative"].to_numpy()
feed = data["feed_rate"].to_numpy()
permeation = data["membrane_permeation_rate"].to_numpy()
retentate = holdup / residence11  # recycled to the TES
total = data["total_tritium"].to_numpy()

# RMSPE of the cumulative (smooth) recovery vs the lumped 0.85, over the filled-system window.
mask = feed > 1.0e-9
if np.any(mask):
    rmspe = 100.0 * np.sqrt(np.mean(((eta_cum[mask] - eta_2_lumped) / eta_2_lumped) ** 2))
else:
    rmspe = float("nan")

fig, axes = plt.subplots(2, 2, figsize=(12, 8))

# (a) Container pressure history -- the key verification curve.
ax = axes[0, 0]
ax.plot(time, pressure, "-o", ms=3, color="tab:purple")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Container T2 pressure (Pa)")
ax.set_title("Membrane upstream container pressure")

# (b) Extraction efficiency: instantaneous and cumulative vs the lumped assumption.
ax = axes[0, 1]
ax.plot(time, eta_inst, "-", color="tab:blue", alpha=0.6, label="instantaneous")
ax.plot(time, eta_cum, "-o", ms=3, color="tab:green", label="cumulative")
ax.axhline(eta_2_lumped, ls="--", color="tab:red", label="lumped eta_2 = 0.85")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Membrane extraction efficiency (-)")
ax.set_title("Tritium recovery efficiency (physics-based)")
ax.set_ylim(0, 1.5)
ax.legend()
ax.text(
    0.04,
    0.06,
    "cumulative RMSPE vs lumped = {:.1f}%".format(rmspe),
    transform=ax.transAxes,
    bbox=dict(boxstyle="round", fc="white", ec="0.7"),
)

# (c) Container flow split: feed in, permeate (-> HX), retentate (-> TES).
ax = axes[1, 0]
ax.plot(time, feed, "-", color="black", label="TES feed in")
ax.plot(time, permeation, "-o", ms=3, color="tab:blue", label="permeate -> HX")
ax.plot(time, retentate, "-s", ms=3, color="tab:orange", label="retentate -> TES")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Tritium flow rate (kg/s)")
ax.set_title("Container flow split")
ax.legend()

# (d) Global tritium conservation.
ax = axes[1, 1]
ax.plot(time, total, "-o", ms=3, color="tab:orange")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Total system tritium (kg)")
ax.set_title("Total tritium inventory (conservation check)")

fig.suptitle("PCC membrane container coupled into the tritium fuel cycle", fontsize=13)
fig.tight_layout(rect=(0, 0, 1, 0.97))

os.makedirs(os.path.join(path, "figures"), exist_ok=True)
out_fig = os.path.join(path, "figures", "comparison_PCC_membrane.png")
fig.savefig(out_fig, dpi=150)
print("Saved figure to {}".format(out_fig))
print("Final container pressure: {:.4g} Pa".format(pressure[-1]))
print("Final cumulative recovery efficiency: {:.4g}".format(eta_cum[-1]))
print("Cumulative recovery vs lumped 0.85: RMSPE = {:.2f}%".format(rmspe))
