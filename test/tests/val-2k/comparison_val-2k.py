import os
import tempfile
from glob import glob
import re

os.environ.setdefault("MPLCONFIGDIR", tempfile.mkdtemp(prefix="matplotlib-val-2k-"))

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Changes working directory to script directory for consistent MooseDocs usage.
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)


def get_repo_relative_path(test_path):
    if "/tmap8/doc/" in script_folder.lower():
        return os.path.join("../../../../test/tests/val-2k", test_path)
    return os.path.join(".", test_path)


def get_latest_profile_csv(pattern):
    matches = sorted(glob(pattern))
    if not matches:
        raise FileNotFoundError(f"No profile CSV found matching {pattern}")
    return matches[-1]


def get_numeric_parameter(parameter_name):
    parameters_file = get_repo_relative_path("parameters_val-2k.params")
    with open(parameters_file, encoding="utf-8") as handle:
        for line in handle:
            stripped = line.strip()
            if stripped.startswith(f"{parameter_name} ="):
                value = stripped.split("=", maxsplit=1)[1].strip().strip("'")
                if value.startswith("${units ") and value.endswith("}"):
                    units_expr = value[len("${units ") : -1].strip()
                    match = re.fullmatch(
                        r"([0-9eE.+-]+)\s+([A-Za-z/]+)(?:\s*->\s*([A-Za-z/]+))?",
                        units_expr,
                    )
                    if not match:
                        raise ValueError(f"Unsupported units expression: {value}")
                    numeric_value = float(match.group(1))
                    from_unit = match.group(2)
                    to_unit = match.group(3)
                    if to_unit is None or from_unit == to_unit:
                        return numeric_value
                    supported_time_conversions = {
                        ("h", "s"): 3600.0,
                        ("s", "h"): 1.0 / 3600.0,
                    }
                    factor = supported_time_conversions.get((from_unit, to_unit))
                    if factor is None:
                        raise ValueError(f"Unsupported conversion in units expression: {value}")
                    return numeric_value * factor
                return float(value)
    raise KeyError(f"Could not find parameter {parameter_name} in {parameters_file}")


def load_experimental_curve(filename):
    return pd.read_csv(get_repo_relative_path(f"gold/{filename}"))


simulation_csv = get_repo_relative_path("gold/val-2k_out.csv")
profile_csv = get_latest_profile_csv(
    get_repo_relative_path("gold/val-2k_profile_initial_out_line_profile_*.csv")
)
time_reference = get_numeric_parameter("time_reference")
sample_surface_area_m2 = 10e-3 * 14e-3

simulation_data = pd.read_csv(simulation_csv)
time_s = simulation_data["time"] * time_reference
time_h = time_s / 3600.0
temperature_k = simulation_data["temperature_pps"]
mobile_inventory = simulation_data["mobile_inventory_physical"]
trapped_intrinsic_inventory = simulation_data["trapped_deuterium_intrinsic_physical"]
trapped_1_inventory = simulation_data["trapped_deuterium_1_physical"]
trapped_2_inventory = simulation_data["trapped_deuterium_2_physical"]
trapped_3_inventory = simulation_data["trapped_deuterium_3_physical"]
trapped_4_inventory = simulation_data["trapped_deuterium_4_physical"]
trapped_5_inventory = simulation_data["trapped_deuterium_5_physical"]
release_flux = (
    simulation_data["scaled_flux_surface_left"] + simulation_data["scaled_flux_surface_right"]
)
release_rate = release_flux * sample_surface_area_m2 / 1e13

experimental_fig6_curves = {
    "hd_d2_nat_oxide": load_experimental_curve("experimental_HD_D2_nat_oxide.csv"),
    "hd_d2_5nm": load_experimental_curve("experimental_HD_D2_5nm.csv"),
    "hd_d2_10nm": load_experimental_curve("experimental_HD_D2_10nm.csv"),
    "hd_d2_15nm": load_experimental_curve("experimental_HD_D2_15nm.csv"),
    "hdo_d2o_nat_oxide": load_experimental_curve("experimental_HDO_D2O_nat_oxide.csv"),
    "hdo_d2o_5nm": load_experimental_curve("experimental_HDO_D2O_5nm.csv"),
    "hdo_d2o_10nm": load_experimental_curve("experimental_HDO_D2O_10nm.csv"),
    "hdo_d2o_15nm": load_experimental_curve("experimental_HDO_D2O_15nm.csv"),
}
natural_oxide_experiment = experimental_fig6_curves["hd_d2_nat_oxide"]

fig, ax = plt.subplots(figsize=(6.5, 5.5))
release_handle = ax.plot(
    time_h,
    release_rate,
    linestyle="-",
    color="tab:blue",
    label="TMAP8 six-trap reference",
)[0]

experiment_time = natural_oxide_experiment["time (h)"]
experiment_flux = natural_oxide_experiment["release flux (10^13 D atoms/s)"]
experiment_handle = ax.plot(
    experiment_time,
    experiment_flux,
    linestyle="--",
    color="k",
    label="Experimental HD + D2 (nat. oxide)",
)[0]

ax_temperature = ax.twinx()
temperature_handle = ax_temperature.plot(
    time_h,
    temperature_k,
    linestyle=":",
    color="tab:red",
    linewidth=1.5,
    label="TMAP8 temperature history",
)[0]

simulated_on_experiment_grid = np.interp(experiment_time, time_h, release_rate)
rmse = np.sqrt(np.mean((simulated_on_experiment_grid - experiment_flux) ** 2))
rmspe = rmse * 100.0 / np.mean(experiment_flux)
ax.text(2.6, 0.85 * max(release_rate.max(), experiment_flux.max()), f"RMSPE = {rmspe:.2f} %")

ax.set_xlabel("Time (h)")
ax.set_ylabel("Release flux (10$^{13}$ D atoms/s)")
ax.set_xlim(0, 4.2)
ax.set_ylim(bottom=0)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax_temperature.set_ylabel("Temperature (K)")
ax_temperature.set_ylim(280, 1100)
ax.legend(
    [release_handle, experiment_handle, temperature_handle],
    [release_handle.get_label(), experiment_handle.get_label(), temperature_handle.get_label()],
    loc="best",
)
ax.minorticks_on()

plt.savefig("val-2k_natural_oxide_iteration_1_comparison.png", bbox_inches="tight", dpi=300)
plt.close(fig)

positive_inventory_floor = 1e-3

fig, ax = plt.subplots(figsize=(6.5, 5.5))
mobile_handle = ax.plot(
    time_h,
    np.clip(mobile_inventory, positive_inventory_floor, None),
    color="tab:blue",
    linestyle="--",
    label="Mobile D",
)[0]
intrinsic_handle = ax.plot(
    time_h,
    np.clip(trapped_intrinsic_inventory, positive_inventory_floor, None),
    color="tab:purple",
    label="Intrinsic trap D",
)[0]
trap_1_handle = ax.plot(
    time_h,
    np.clip(trapped_1_inventory, positive_inventory_floor, None),
    color="tab:orange",
    label="Trap 1 D",
)[0]
trap_2_handle = ax.plot(
    time_h,
    np.clip(trapped_2_inventory, positive_inventory_floor, None),
    color="tab:green",
    label="Trap 2 D",
)[0]
trap_3_handle = ax.plot(
    time_h,
    np.clip(trapped_3_inventory, positive_inventory_floor, None),
    color="tab:red",
    label="Trap 3 D",
)[0]
trap_4_handle = ax.plot(
    time_h,
    np.clip(trapped_4_inventory, positive_inventory_floor, None),
    color="tab:brown",
    label="Trap 4 D",
)[0]
trap_5_handle = ax.plot(
    time_h,
    np.clip(trapped_5_inventory, positive_inventory_floor, None),
    color="tab:pink",
    label="Trap 5 D",
)[0]

ax_temperature = ax.twinx()
temperature_handle = ax_temperature.plot(
    time_h,
    temperature_k,
    linestyle=":",
    color="tab:gray",
    linewidth=1.5,
    label="TMAP8 temperature history",
)[0]

ax.set_xlabel("Time (h)")
ax.set_ylabel("Deuterium inventory (atoms)")
ax.set_xlim(0, 4.2)
ax.set_yscale("log")
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax_temperature.set_ylabel("Temperature (K)")
ax_temperature.set_ylim(280, 1100)
ax.legend(
    [
        mobile_handle,
        intrinsic_handle,
        trap_1_handle,
        trap_2_handle,
        trap_3_handle,
        trap_4_handle,
        trap_5_handle,
        temperature_handle,
    ],
    [
        mobile_handle.get_label(),
        intrinsic_handle.get_label(),
        trap_1_handle.get_label(),
        trap_2_handle.get_label(),
        trap_3_handle.get_label(),
        trap_4_handle.get_label(),
        trap_5_handle.get_label(),
        temperature_handle.get_label(),
    ],
    loc="best",
)
ax.minorticks_on()

plt.savefig("val-2k_natural_oxide_iteration_1_inventory.png", bbox_inches="tight", dpi=300)
plt.close(fig)

profile_data = pd.read_csv(profile_csv)
distance_to_surface_microns = profile_data["x"]
deuterium_total = profile_data["deuterium_total_physical"]
deuterium_mobile = profile_data["deuterium_mobile_physical"]
deuterium_trapped_intrinsic = profile_data["deuterium_trapped_intrinsic_physical"]
deuterium_trapped_1 = profile_data["deuterium_trapped_1_physical"]
deuterium_trapped_2 = profile_data["deuterium_trapped_2_physical"]
deuterium_trapped_3 = profile_data["deuterium_trapped_3_physical"]
deuterium_trapped_4 = profile_data["deuterium_trapped_4_physical"]
deuterium_trapped_5 = profile_data["deuterium_trapped_5_physical"]

fig, ax = plt.subplots(figsize=(6.5, 5.5))
ax.plot(
    distance_to_surface_microns,
    deuterium_total,
    color="k",
    linewidth=2.0,
    label="Total D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_mobile,
    color="tab:blue",
    linestyle="--",
    label="Mobile D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_trapped_intrinsic,
    color="tab:purple",
    label="Intrinsic trap D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_trapped_1,
    color="tab:orange",
    label="Trap 1 D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_trapped_2,
    color="tab:green",
    label="Trap 2 D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_trapped_3,
    color="tab:red",
    label="Trap 3 D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_trapped_4,
    color="tab:brown",
    label="Trap 4 D",
)
ax.plot(
    distance_to_surface_microns,
    deuterium_trapped_5,
    color="tab:pink",
    label="Trap 5 D",
)

ax.set_xlabel("Distance to tungsten surface (um)")
ax.set_ylabel("Deuterium concentration (atoms/m$^3$)")
ax.set_xlim(left=0)
ax.set_yscale("log")
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.legend(loc="best")
ax.minorticks_on()

plt.savefig("val-2k_natural_oxide_iteration_1_profile.png", bbox_inches="tight", dpi=300)
plt.close(fig)
