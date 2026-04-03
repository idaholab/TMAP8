import os
import tempfile
from glob import glob

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
                return float(stripped.split("=", maxsplit=1)[1].strip().strip("'"))
    raise KeyError(f"Could not find parameter {parameter_name} in {parameters_file}")


def load_experimental_curve(filename):
    return pd.read_csv(get_repo_relative_path(f"gold/{filename}"))


simulation_csv = get_repo_relative_path("gold/val-2k_out.csv")
profile_csv = get_latest_profile_csv(
    get_repo_relative_path("gold/val-2k_profile_initial_out_line_profile_*.csv")
)
trap_per_free_intrinsic = get_numeric_parameter("trap_per_free_intrinsic")
trap_per_free_1 = get_numeric_parameter("trap_per_free_1")
trap_per_free_2 = get_numeric_parameter("trap_per_free_2")
trap_per_free_3 = get_numeric_parameter("trap_per_free_3")
trap_per_free_4 = get_numeric_parameter("trap_per_free_4")
trap_per_free_5 = get_numeric_parameter("trap_per_free_5")
atoms_per_cubic_micron_to_atoms_per_cubic_meter = 1e18
sample_surface_area_m2 = 10e-3 * 14e-3

simulation_data = pd.read_csv(simulation_csv)
time_s = simulation_data["time"]
time_h = time_s / 3600.0
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
ax.plot(
    time_h,
    release_rate,
    linestyle="-",
    color="tab:blue",
    label="TMAP8 six-trap reference",
)

experiment_time = natural_oxide_experiment["time (h)"]
experiment_flux = natural_oxide_experiment["release flux (10^13 D atoms/s)"]
ax.plot(
    experiment_time,
    experiment_flux,
    linestyle="--",
    color="k",
    label="Experimental HD + D2 (nat. oxide)",
)

simulated_on_experiment_grid = np.interp(experiment_time, time_h, release_rate)
rmse = np.sqrt(np.mean((simulated_on_experiment_grid - experiment_flux) ** 2))
rmspe = rmse * 100.0 / np.mean(experiment_flux)
ax.text(2.6, 0.85 * max(release_rate.max(), experiment_flux.max()), f"RMSPE = {rmspe:.2f} %")

ax.set_xlabel("Time (h)")
ax.set_ylabel("Release flux (10$^{13}$ D atoms/s)")
ax.set_xlim(0, 4.2)
ax.set_ylim(bottom=0)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.legend(loc="best")
ax.minorticks_on()

plt.savefig("val-2k_natural_oxide_iteration_1_comparison.png", bbox_inches="tight", dpi=300)
plt.close(fig)

profile_data = pd.read_csv(profile_csv)
distance_to_surface_microns = profile_data["x"]
deuterium_mobile = profile_data["deuterium_mobile"] * atoms_per_cubic_micron_to_atoms_per_cubic_meter
deuterium_trapped_intrinsic = (
    profile_data["deuterium_trapped_intrinsic"]
    * trap_per_free_intrinsic
    * atoms_per_cubic_micron_to_atoms_per_cubic_meter
)
deuterium_trapped_1 = (
    profile_data["deuterium_trapped_1"]
    * trap_per_free_1
    * atoms_per_cubic_micron_to_atoms_per_cubic_meter
)
deuterium_trapped_2 = (
    profile_data["deuterium_trapped_2"]
    * trap_per_free_2
    * atoms_per_cubic_micron_to_atoms_per_cubic_meter
)
deuterium_trapped_3 = (
    profile_data["deuterium_trapped_3"]
    * trap_per_free_3
    * atoms_per_cubic_micron_to_atoms_per_cubic_meter
)
deuterium_trapped_4 = (
    profile_data["deuterium_trapped_4"]
    * trap_per_free_4
    * atoms_per_cubic_micron_to_atoms_per_cubic_meter
)
deuterium_trapped_5 = (
    profile_data["deuterium_trapped_5"]
    * trap_per_free_5
    * atoms_per_cubic_micron_to_atoms_per_cubic_meter
)
deuterium_total = (
    deuterium_mobile
    + deuterium_trapped_intrinsic
    + deuterium_trapped_1
    + deuterium_trapped_2
    + deuterium_trapped_3
    + deuterium_trapped_4
    + deuterium_trapped_5
)

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
