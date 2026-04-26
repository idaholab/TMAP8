import os
import re
import tempfile
from pathlib import Path

os.environ.setdefault("MPLCONFIGDIR", tempfile.mkdtemp(prefix="matplotlib-val-2k-"))

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.patches import Patch

# Stage 1: resolve all file paths from the script directory so MooseDocs and
# local test runs use the same relative paths.
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)


def get_repo_relative_path(test_path):
    if "/tmap8/doc/" in script_folder.lower():
        return os.path.join("../../../../test/tests/val-2k", test_path)
    return os.path.join(".", test_path)


def get_output_path(filename):
    candidates = [
        Path(get_repo_relative_path(f"../../../{filename}")),
        Path(get_repo_relative_path(filename)),
        Path(get_repo_relative_path(f"gold/{filename}")),
    ]
    existing_candidates = [candidate for candidate in candidates if candidate.exists()]
    if existing_candidates:
        return max(existing_candidates, key=lambda path: path.stat().st_mtime)
    return candidates[-1]


def get_numeric_parameter(parameter_name):
    parameters_file = get_repo_relative_path("val-2k_natural_oxide.i")

    def parse_numeric_value(value):
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

    def search_parameter(path, visited):
        if path in visited:
            return None
        visited.add(path)
        with open(path, encoding="utf-8") as handle:
            for line in handle:
                stripped = line.strip()
                if stripped.startswith("!include "):
                    include_name = stripped.split(maxsplit=1)[1]
                    include_path = os.path.join(os.path.dirname(path), include_name)
                    result = search_parameter(include_path, visited)
                    if result is not None:
                        return result
                if stripped.startswith(f"{parameter_name} ="):
                    value = stripped.split("=", maxsplit=1)[1].strip().strip("'")
                    return parse_numeric_value(value)
        return None

    result = search_parameter(parameters_file, set())
    if result is None:
        raise KeyError(
            f"Could not find parameter {parameter_name} in {parameters_file}"
        )
    return result


def load_experimental_curve(filename):
    return pd.read_csv(get_repo_relative_path(f"gold/{filename}"))


def load_simulation_case(csv_name):
    simulation_data = pd.read_csv(get_output_path(csv_name))
    time_s = simulation_data["time"] * time_reference
    release_flux_d2 = (
        simulation_data["scaled_flux_surface_left_d2"]
        + simulation_data["scaled_flux_surface_right_d2"]
    )
    release_flux_d2o = (
        simulation_data["scaled_flux_surface_left_d2o"]
        + simulation_data["scaled_flux_surface_right_d2o"]
    )
    initial_inventory = simulation_data["deuterium_inventory_in_sample_physical"].iloc[
        0
    ]
    oxygen_initial_inventory = None
    if "oxygen_initial_inventory_in_sample_physical" in simulation_data.columns:
        oxygen_initial_inventory = simulation_data[
            "oxygen_initial_inventory_in_sample_physical"
        ].iloc[0]
    elif "oxygen_inventory_in_sample_physical" in simulation_data.columns:
        oxygen_initial_inventory = simulation_data[
            "oxygen_inventory_in_sample_physical"
        ].iloc[0]

    oxygen_inventory_in_sample = simulation_data.get(
        "oxygen_inventory_in_sample_physical"
    )
    oxygen_released = simulation_data.get("oxygen_released_physical")
    oxygen_mass_residual = simulation_data.get("oxygen_mass_conservation_residual")
    return {
        "data": simulation_data,
        "time_s": time_s,
        "time_h": time_s / 3600.0,
        "temperature_k": simulation_data["temperature_pps"],
        "initial_inventory": initial_inventory,
        "inventory_in_sample": simulation_data[
            "deuterium_inventory_in_sample_physical"
        ],
        "released_inventory": simulation_data["deuterium_released_physical"],
        "mass_conservation_residual": simulation_data[
            "deuterium_mass_conservation_residual"
        ],
        "relative_mass_conservation_residual": simulation_data[
            "deuterium_mass_conservation_residual"
        ]
        / initial_inventory,
        "oxygen_initial_inventory": oxygen_initial_inventory,
        "oxygen_inventory_in_sample": oxygen_inventory_in_sample,
        "oxygen_released": oxygen_released,
        "oxygen_mass_conservation_residual": oxygen_mass_residual,
        "relative_oxygen_mass_conservation_residual": (
            oxygen_mass_residual / oxygen_initial_inventory
            if oxygen_mass_residual is not None
            and oxygen_initial_inventory not in (None, 0.0)
            else None
        ),
        "mobile_inventory": simulation_data["mobile_inventory_physical"],
        "trapped_intrinsic_inventory": simulation_data[
            "trapped_deuterium_intrinsic_physical"
        ],
        "trapped_1_inventory": simulation_data["trapped_deuterium_1_physical"],
        "trapped_2_inventory": simulation_data["trapped_deuterium_2_physical"],
        "trapped_3_inventory": simulation_data["trapped_deuterium_3_physical"],
        "trapped_4_inventory": simulation_data["trapped_deuterium_4_physical"],
        "trapped_5_inventory": simulation_data["trapped_deuterium_5_physical"],
        "release_rate_d2": release_flux_d2 * sample_surface_area_m2 / 1e13,
        "release_rate_d2o": release_flux_d2o * sample_surface_area_m2 / 1e13,
        "release_rate_total": (release_flux_d2 + release_flux_d2o)
        * sample_surface_area_m2
        / 1e13,
    }


def compute_rmspe(case_time_h, case_release_rate, experimental_curve):
    experiment_time = experimental_curve["time (h)"]
    experiment_flux = experimental_curve["release flux (10^13 D atoms/s)"]
    simulated_on_experiment_grid = np.interp(
        experiment_time, case_time_h, case_release_rate
    )
    rmse = np.sqrt(np.mean((simulated_on_experiment_grid - experiment_flux) ** 2))
    return rmse * 100.0 / np.mean(experiment_flux)


# Stage 2: load the simulated outputs for the natural-oxide and 5 nm oxygen-
# field cases, together with the experimental curves from Fig. 6.
time_reference = get_numeric_parameter("time_reference")
sample_surface_area_m2 = 10e-3 * 14e-3

baseline_case = load_simulation_case("val-2k_out.csv")
oxide_case = load_simulation_case("val-2k_5nm_oxide_out.csv")
baseline_profile = pd.read_csv(
    get_output_path("val-2k_profile_initial_out_line_profile_0000.csv")
)

natural_oxide_experiment = load_experimental_curve("experimental_HD_D2_nat_oxide.csv")
oxide_5nm_experiment = load_experimental_curve("experimental_HD_D2_5nm.csv")
natural_oxide_d2o_experiment = load_experimental_curve(
    "experimental_HDO_D2O_nat_oxide.csv"
)
oxide_5nm_d2o_experiment = load_experimental_curve("experimental_HDO_D2O_5nm.csv")

# Stage 3: generate the desorption comparison figure for both currently modeled
# cases and include the imposed temperature history on the right axis.
fig, ax = plt.subplots(figsize=(7.2, 6.4))
fig.subplots_adjust(top=0.8, bottom=0.3)

natural_oxide_color = "tab:blue"
oxide_5nm_color = "tab:green"

baseline_handle = ax.plot(
    baseline_case["time_h"],
    baseline_case["release_rate_d2"],
    linestyle="-",
    color=natural_oxide_color,
    label="TMAP8 D2, nat. oxide (1 nm O)",
)[0]
oxide_handle = ax.plot(
    oxide_case["time_h"],
    oxide_case["release_rate_d2"],
    linestyle="-",
    color=oxide_5nm_color,
    label="TMAP8 D2, 5 nm oxide",
)[0]
baseline_d2o_handle = ax.plot(
    baseline_case["time_h"],
    baseline_case["release_rate_d2o"],
    linestyle="--",
    color=natural_oxide_color,
    label="TMAP8 D2O, nat. oxide (1 nm O)",
)[0]
oxide_d2o_handle = ax.plot(
    oxide_case["time_h"],
    oxide_case["release_rate_d2o"],
    linestyle="--",
    color=oxide_5nm_color,
    label="TMAP8 D2O, 5 nm oxide",
)[0]
natural_experiment_handle = ax.plot(
    natural_oxide_experiment["time (h)"],
    natural_oxide_experiment["release flux (10^13 D atoms/s)"],
    linestyle="-.",
    color=natural_oxide_color,
    label="Experimental HD + D2 (nat. oxide)",
)[0]
oxide_experiment_handle = ax.plot(
    oxide_5nm_experiment["time (h)"],
    oxide_5nm_experiment["release flux (10^13 D atoms/s)"],
    linestyle="-.",
    color=oxide_5nm_color,
    label="Experimental HD + D2 (5 nm oxide)",
)[0]
natural_d2o_experiment_handle = ax.plot(
    natural_oxide_d2o_experiment["time (h)"],
    natural_oxide_d2o_experiment["release flux (10^13 D atoms/s)"],
    linestyle=":",
    color=natural_oxide_color,
    label="Experimental HDO + D2O (nat. oxide)",
)[0]
oxide_d2o_experiment_handle = ax.plot(
    oxide_5nm_d2o_experiment["time (h)"],
    oxide_5nm_d2o_experiment["release flux (10^13 D atoms/s)"],
    linestyle=":",
    color=oxide_5nm_color,
    label="Experimental HDO + D2O (5 nm oxide)",
)[0]

ax_temperature = ax.twinx()
temperature_handle = ax_temperature.plot(
    baseline_case["time_h"],
    baseline_case["temperature_k"],
    linestyle=":",
    color="tab:red",
    linewidth=1.5,
    label="TMAP8 temperature history",
)[0]

baseline_rmspe = compute_rmspe(
    baseline_case["time_h"], baseline_case["release_rate_d2"], natural_oxide_experiment
)
oxide_rmspe = compute_rmspe(
    oxide_case["time_h"], oxide_case["release_rate_d2"], oxide_5nm_experiment
)
baseline_d2o_rmspe = compute_rmspe(
    baseline_case["time_h"],
    baseline_case["release_rate_d2o"],
    natural_oxide_d2o_experiment,
)
oxide_d2o_rmspe = compute_rmspe(
    oxide_case["time_h"], oxide_case["release_rate_d2o"], oxide_5nm_d2o_experiment
)
fig.text(
    0.5,
    0.96,
    "Nat. oxide RMSPEs: "
    f"D2={baseline_rmspe:.2f} %, D2O={baseline_d2o_rmspe:.2f} %\n"
    "5 nm oxide RMSPEs: "
    f"D2={oxide_rmspe:.2f} %, D2O={oxide_d2o_rmspe:.2f} %",
    ha="center",
    va="top",
)

ax.set_xlabel("Time (h)")
ax.set_ylabel("Release rate (10$^{13}$ D atoms/s)")
ax.set_xlim(0, 4.2)
ax.set_ylim(bottom=0)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax_temperature.set_ylabel("Temperature (K)")
ax_temperature.set_ylim(280, 1100)
fig.legend(
    [
        baseline_handle,
        oxide_handle,
        baseline_d2o_handle,
        oxide_d2o_handle,
        natural_experiment_handle,
        oxide_experiment_handle,
        natural_d2o_experiment_handle,
        oxide_d2o_experiment_handle,
        temperature_handle,
    ],
    [
        baseline_handle.get_label(),
        oxide_handle.get_label(),
        baseline_d2o_handle.get_label(),
        oxide_d2o_handle.get_label(),
        natural_experiment_handle.get_label(),
        oxide_experiment_handle.get_label(),
        natural_d2o_experiment_handle.get_label(),
        oxide_d2o_experiment_handle.get_label(),
        temperature_handle.get_label(),
    ],
    loc="lower center",
    bbox_to_anchor=(0.5, 0.02),
    ncol=2,
    frameon=True,
)
ax.minorticks_on()

plt.savefig(
    "val-2k_natural_oxide_iteration_1_comparison.png", bbox_inches="tight", dpi=300
)
plt.close(fig)

# Stage 4: generate the baseline inventory history figure showing the cumulative
# deuterium inventory and the contribution of each trap family.
fig, ax = plt.subplots(figsize=(6.5, 5.5))
cmap = plt.get_cmap("viridis")
inventory_colors = cmap(np.linspace(0, 1, 7))
inventory_series = [
    ("Trap 5 D", baseline_case["trapped_5_inventory"], inventory_colors[0]),
    ("Trap 4 D", baseline_case["trapped_4_inventory"], inventory_colors[1]),
    ("Trap 3 D", baseline_case["trapped_3_inventory"], inventory_colors[2]),
    ("Trap 2 D", baseline_case["trapped_2_inventory"], inventory_colors[3]),
    (
        "Intrinsic trap D",
        baseline_case["trapped_intrinsic_inventory"],
        inventory_colors[4],
    ),
    ("Trap 1 D", baseline_case["trapped_1_inventory"], inventory_colors[5]),
    ("Mobile D", baseline_case["mobile_inventory"], inventory_colors[6]),
]
inventory_bottom = np.zeros_like(baseline_case["mobile_inventory"])
legend_patches = []

for label, values, color in inventory_series:
    ax.fill_between(
        baseline_case["time_h"],
        inventory_bottom,
        inventory_bottom + values,
        color=color,
        alpha=0.3,
    )
    ax.plot(
        baseline_case["time_h"], inventory_bottom + values, color=color, linewidth=1.0
    )
    inventory_bottom += values
    legend_patches.append(Patch(color=color, alpha=0.5, label=label))

total_inventory = inventory_bottom.copy()
total_handle = ax.plot(
    baseline_case["time_h"],
    total_inventory,
    color="tab:green",
    linewidth=1.5,
    label="Total D inventory",
)[0]

ax_temperature = ax.twinx()
temperature_handle = ax_temperature.plot(
    baseline_case["time_h"],
    baseline_case["temperature_k"],
    linestyle=":",
    color="tab:orange",
    linewidth=1.5,
    label="TMAP8 temperature history",
)[0]

ax.set_xlabel("Time (h)")
ax.set_ylabel("Deuterium inventory (atoms)")
ax.set_xlim(0, 4.2)
ax.set_ylim(bottom=0)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax_temperature.set_ylabel("Temperature (K)")
ax_temperature.set_ylim(280, 1100)
ax.legend(
    [
        total_handle,
        temperature_handle,
        legend_patches[-1],
        legend_patches[-2],
        legend_patches[-3],
        legend_patches[-4],
        legend_patches[-5],
        legend_patches[-6],
        legend_patches[-7],
    ],
    [
        total_handle.get_label(),
        temperature_handle.get_label(),
        legend_patches[-1].get_label(),
        legend_patches[-2].get_label(),
        legend_patches[-3].get_label(),
        legend_patches[-4].get_label(),
        legend_patches[-5].get_label(),
        legend_patches[-6].get_label(),
        legend_patches[-7].get_label(),
    ],
    loc="best",
)
ax.minorticks_on()

plt.savefig(
    "val-2k_natural_oxide_iteration_1_inventory.png", bbox_inches="tight", dpi=300
)
plt.close(fig)

# Stage 5: compare the relative deuterium mass-balance residual for both
# currently modeled cases using the postprocessors written by the transient
# solves.
fig, ax = plt.subplots(figsize=(6.5, 4.8))

baseline_mass_handle = ax.plot(
    baseline_case["time_h"],
    baseline_case["relative_mass_conservation_residual"],
    color="tab:blue",
    linewidth=1.8,
    label="No oxide layer",
)[0]
oxide_mass_handle = ax.plot(
    oxide_case["time_h"],
    oxide_case["relative_mass_conservation_residual"],
    color="tab:green",
    linewidth=1.8,
    label="5 nm oxide",
)[0]

ax.axhline(0.0, color="0.35", linewidth=1.0, linestyle="--")
ax.set_xlabel("Time (h)")
ax.set_ylabel("Deuterium mass-balance residual / initial inventory (-)")
ax.set_xlim(0, 4.2)
ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.legend(handles=[baseline_mass_handle, oxide_mass_handle], loc="best")
ax.minorticks_on()

plt.savefig(
    "val-2k_natural_oxide_iteration_1_mass_conservation.png",
    bbox_inches="tight",
    dpi=300,
)
plt.close(fig)

# Stage 6: plot the oxygen conservation residual for both oxygen-field cases in
# a dedicated figure when the oxygen bookkeeping columns are present.
if (
    baseline_case["relative_oxygen_mass_conservation_residual"] is not None
    and oxide_case["relative_oxygen_mass_conservation_residual"] is not None
):
    fig, ax = plt.subplots(figsize=(6.5, 4.8))

    baseline_oxygen_mass_handle = ax.plot(
        baseline_case["time_h"],
        baseline_case["relative_oxygen_mass_conservation_residual"],
        color="tab:blue",
        linewidth=1.8,
        label="Nat. oxide (1 nm O)",
    )[0]
    oxide_oxygen_mass_handle = ax.plot(
        oxide_case["time_h"],
        oxide_case["relative_oxygen_mass_conservation_residual"],
        color="tab:orange",
        linewidth=1.8,
        label="5 nm oxide",
    )[0]

    ax.axhline(0.0, color="0.35", linewidth=1.0, linestyle="--")
    ax.set_xlabel("Time (h)")
    ax.set_ylabel("Oxygen conservation residual / initial inventory (-)")
    ax.set_xlim(0, 4.2)
    ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
    ax.legend(
        handles=[baseline_oxygen_mass_handle, oxide_oxygen_mass_handle], loc="best"
    )
    ax.minorticks_on()

    plt.savefig(
        "val-2k_natural_oxide_iteration_1_oxygen_conservation.png",
        bbox_inches="tight",
        dpi=300,
    )
    plt.close(fig)

# Stage 7: generate the baseline initial concentration profile used to start the
# desorption calculation.
distance_to_surface_microns = baseline_profile["x"]
deuterium_total = baseline_profile["deuterium_total_physical"]
deuterium_mobile = baseline_profile["deuterium_mobile_physical"]
deuterium_trapped_intrinsic = baseline_profile["deuterium_trapped_intrinsic_physical"]
deuterium_trapped_1 = baseline_profile["deuterium_trapped_1_physical"]
deuterium_trapped_2 = baseline_profile["deuterium_trapped_2_physical"]
deuterium_trapped_3 = baseline_profile["deuterium_trapped_3_physical"]
deuterium_trapped_4 = baseline_profile["deuterium_trapped_4_physical"]
deuterium_trapped_5 = baseline_profile["deuterium_trapped_5_physical"]

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
ax.set_ylim(0, 9.5e26)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.legend(loc="best")
ax.minorticks_on()

plt.savefig(
    "val-2k_natural_oxide_iteration_1_profile.png", bbox_inches="tight", dpi=300
)
plt.close(fig)
