#!/usr/bin/env python3
"""Fit the PCC membrane transient permeation to a first-order residence-time response.

The PCC-enhanced tritium-permeation membrane (TPM) is represented in the fuel cycle by a single
residence time. We obtain it from a standalone membrane permeation run at a fixed upstream tritium
partial pressure (5 Pa), saved as ``membrane_5_Pa_flux.csv``. The downstream permeation flux
``J_back = recombination_flux_OT_dry_right`` rises from ~0 toward a plateau ``J_inf`` with a
characteristic time ``tau``:

    J_back(t) = J_inf * (1 - exp(-t / tau))

``tau`` (the fitted membrane response time) is used as the TPM residence time ``resident_time_11`` in
the fuel cycle. This script fits ``J_inf`` and ``tau`` and plots the tritium-release data against the
fitted curve.
"""

import os

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# Resolve data/figure paths for both the test tree and the documentation build.
script_folder = os.path.dirname(os.path.abspath(__file__))
if "/TMAP8/doc/" in script_folder:
    test_dir = "../../../../test/tests/PCC_multiscale_example"
else:
    test_dir = script_folder
path = os.path.join(test_dir, "gold")

csv_file = os.path.join(path, "membrane_5_Pa_flux.csv")
if not os.path.isfile(csv_file):
    raise FileNotFoundError("Membrane permeation data not found: {}".format(csv_file))

data = pd.read_csv(csv_file)
t = data["time"].to_numpy()
j_back = data["recombination_flux_OT_dry_right"].to_numpy()


def residence_response(time, j_inf, tau0, tau1):
    """Delayed first-order response.

    J_back = 0                                   for t <= tau0   (transport delay)
           = J_inf * (1 - exp(-(t-tau0)/tau1))   for t >  tau0   (rise toward the plateau)

    The system has a delay tau0 before tritium appears downstream, then the flux rises with time
    constant tau1. Implemented with max(t - tau0, 0) so it is 0 for t <= tau0.
    """
    return j_inf * (1.0 - np.exp(-np.maximum(time - tau0, 0.0) / tau1))


# Initial guess: plateau from the last value; small delay tau0; rise tau1 ~ tens of seconds.
# Bounds keep the delay and rise time non-negative.
p0 = [j_back[-1], 1.0, 30.0]
popt, _ = curve_fit(
    residence_response,
    t,
    j_back,
    p0=p0,
    bounds=([-np.inf, 0.0, 1e-6], [np.inf, np.inf, np.inf]),
    maxfev=20000,
)
j_inf, tau0, tau1 = popt

fit = residence_response(t, *popt)
ss_res = np.sum((j_back - fit) ** 2)
ss_tot = np.sum((j_back - j_back.mean()) ** 2)
r2 = 1.0 - ss_res / ss_tot

print("Fitted J_back = J_inf*(1 - exp(-(t-tau0)/tau1)) for t > tau0, else 0:")
print("  J_inf = {:.6g}  (at/nm^2/s)".format(j_inf))
print("  tau0  = {:.6g}  s   (transport delay -- shifts timing only)".format(tau0))
print("  tau1  = {:.6g}  s   <-- use as resident_time_11 (only tau1 sets the steady-state inventory)".format(tau1))
print("  R^2   = {:.5f}".format(r2))

# Plot the tritium-release data and the fitted curve: absolute flux, linear time axis, at/m^2/s.
unit = 1e18  # at/nm^2/s -> at/m^2/s
t_fit = np.concatenate([np.linspace(0.0, 500.0, 300), np.linspace(500.0, t.max(), 400)])
plt.rcParams.update({"font.size": 1.5 * plt.rcParamsDefault["font.size"]})  # scale all fonts 1.5x
fig, ax = plt.subplots(figsize=[6.5, 5.5])
ax.plot(t, np.abs(j_back) * unit, "-", ms=4, color="C0", label="membrane simulation (5 Pa)")
ax.plot(t_fit, np.abs(residence_response(t_fit, *popt)) * unit, "-", color="C1",
        label=r"fitting")
ax.set_xlabel("Time (s)")
ax.set_ylabel(r"Tritium release (at/m$^2$/s)")
ax.set_xlim([0,100])
ax.set_ylim(bottom=0)
ax.legend(loc="lower right")
ax.text(
    0.40,
    0.65,
    r"$\tau_0$ = {:.2f} s".format(tau0) + "\n" + r"$\tau_1$ = {:.2f} s".format(tau1)
    + "\n"
    + r"$R^2$ = {:.4f}".format(r2),
    transform=ax.transAxes,
)

os.makedirs(os.path.join(path, "../figures"), exist_ok=True)
out_fig = os.path.join(path, "../figures", "fit_residence_time.png")
fig.savefig(out_fig, dpi=150, bbox_inches="tight")
print("Saved figure to {}".format(out_fig))
