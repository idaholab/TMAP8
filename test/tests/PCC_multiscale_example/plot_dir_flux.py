"""Tritium flux recovered to storage by each PCC DIR membrane (VP, FCU) vs time.

``flux_to_storage_VP`` / ``flux_to_storage_FCU`` (from ``dir_pcc_fuel_cycle_out.csv``) are
the steady permeation rates [kg/s] the VP and FCU membrane sub-apps return to the storage
inventory each fuel-cycle step -- i.e. the tritium each DIR loop diverts directly back to
storage. Plotted log-log vs time (days), matching the figure style of the companion scripts.
"""

import os

import matplotlib.pyplot as plt
import pandas as pd

plt.rcParams.update({"font.size": 18})

script_folder = os.path.dirname(os.path.abspath(__file__))
if "/TMAP8/doc/" in script_folder:  # documentation build
    test_dir = "../../../../test/tests/PCC_multiscale_example"
else:  # test folder
    test_dir = script_folder
csv_candidates = [
    os.path.join(test_dir, "dir_pcc_fuel_cycle_out.csv"),
    os.path.join(test_dir, "dir_pcc_fuel_cycle_2rt_10Pa_out.csv"),
    os.path.join(test_dir, "gold", "dir_pcc_fuel_cycle_2rt_10Pa_out_reference.csv"),
]
dir_csv = next((candidate for candidate in csv_candidates if os.path.isfile(candidate)), None)
if dir_csv is None:
    raise FileNotFoundError("Could not find a PCC DIR flux CSV in {}".format(csv_candidates))
figures_dir = os.path.join(test_dir, "figures")
os.makedirs(figures_dir, exist_ok=True)

time_unit = 3600 * 24  # seconds per day
pcc = pd.read_csv(dir_csv)
t = pcc["time"].values / time_unit

fig, ax = plt.subplots(figsize=[6.5, 5.5])
ax.plot(
    t, pcc["flux_to_storage_VP"].values, "-", color="C0", label="VP DIR flux to storage"
)
ax.plot(
    t,
    pcc["flux_to_storage_FCU"].values,
    "-",
    color="C1",
    label="FCU DIR flux to storage",
)

ax.set_xlabel("Time (days)")
ax.set_ylabel("Flux to storage (kg/s)")
ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlim(left=0.1)
ax.set_ylim(bottom=1e-9)
ax.legend(loc="lower right", fontsize=16)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

fig_path = os.path.join(figures_dir, "dir_pcc_dir_flux.png")
plt.savefig(fig_path, bbox_inches="tight", dpi=300)
plt.close(fig)
print(f"Saved {fig_path}")
