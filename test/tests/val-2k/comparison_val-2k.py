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


def get_output_candidates(filename):
    return [
        Path(get_repo_relative_path(f"../../../{filename}")),
        Path(get_repo_relative_path(filename)),
        Path(get_repo_relative_path(f"gold/{filename}")),
    ]


def output_exists(filename):
    return any(candidate.exists() for candidate in get_output_candidates(filename))


def get_output_path(filename):
    candidates = get_output_candidates(filename)
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


# Stage 2: load the simulated outputs for the currently available oxygen-field
# cases together with the experimental curves from Fig. 6.
time_reference = get_numeric_parameter("time_reference")
sample_surface_area_m2 = 10e-3 * 14e-3

case_specs = [
    {
        "key": "natural_oxide",
        "display_label": "nat. oxide (1 nm O)",
        "rmspe_label": "Nat. oxide",
        "color": "tab:blue",
        "simulation_csv": "val-2k_out.csv",
        "profile_csv": "val-2k_profile_initial_out_line_profile_0000.csv",
        "experimental_d2_csv": "experimental_HD_D2_nat_oxide.csv",
        "experimental_d2o_csv": "experimental_HDO_D2O_nat_oxide.csv",
    },
    {
        "key": "oxide_5nm",
        "display_label": "5 nm oxide",
        "rmspe_label": "5 nm oxide",
        "color": "tab:green",
        "simulation_csv": "val-2k_5nm_oxide_out.csv",
        "profile_csv": "val-2k_5nm_oxide_profile_initial_out_line_profile_0000.csv",
        "experimental_d2_csv": "experimental_HD_D2_5nm.csv",
        "experimental_d2o_csv": "experimental_HDO_D2O_5nm.csv",
    },
    {
        "key": "oxide_10nm",
        "display_label": "10 nm oxide",
        "rmspe_label": "10 nm oxide",
        "color": "tab:orange",
        "simulation_csv": "val-2k_10nm_oxide_out.csv",
        "profile_csv": "val-2k_10nm_oxide_profile_initial_out_line_profile_0000.csv",
        "experimental_d2_csv": "experimental_HD_D2_10nm.csv",
        "experimental_d2o_csv": "experimental_HDO_D2O_10nm.csv",
    },
    {
        "key": "oxide_15nm",
        "display_label": "15 nm oxide",
        "rmspe_label": "15 nm oxide",
        "color": "tab:red",
        "simulation_csv": "val-2k_15nm_oxide_out.csv",
        "profile_csv": "val-2k_15nm_oxide_profile_initial_out_line_profile_0000.csv",
        "experimental_d2_csv": "experimental_HD_D2_15nm.csv",
        "experimental_d2o_csv": "experimental_HDO_D2O_15nm.csv",
    },
]

available_cases = []
for spec in case_specs:
    spec["experimental_d2"] = load_experimental_curve(spec["experimental_d2_csv"])
    spec["experimental_d2o"] = load_experimental_curve(spec["experimental_d2o_csv"])
    if output_exists(spec["simulation_csv"]):
        spec["simulation"] = load_simulation_case(spec["simulation_csv"])
        available_cases.append(spec)

baseline_case = available_cases[0]["simulation"]
baseline_profile = pd.read_csv(get_output_path(case_specs[0]["profile_csv"]))

# Stage 3: generate the desorption comparison figure for both currently modeled
# cases and include the imposed temperature history on the right axis.
fig, ax = plt.subplots(figsize=(7.2, 8.2))
fig.subplots_adjust(top=0.8, bottom=0.38)

tds_handles = []
tds_labels = []
rmspe_lines = []

for spec in available_cases:
    case = spec["simulation"]
    color = spec["color"]
    experimental_d2 = spec["experimental_d2"]
    experimental_d2o = spec["experimental_d2o"]

    simulated_d2_handle = ax.plot(
        case["time_h"],
        case["release_rate_d2"],
        linestyle="-",
        color=color,
        label=f"TMAP8 D2, {spec['display_label']}",
    )[0]
    simulated_d2o_handle = ax.plot(
        case["time_h"],
        case["release_rate_d2o"],
        linestyle="--",
        color=color,
        label=f"TMAP8 D2O, {spec['display_label']}",
    )[0]
    experimental_d2_handle = ax.plot(
        experimental_d2["time (h)"],
        experimental_d2["release flux (10^13 D atoms/s)"],
        linestyle="-.",
        color=color,
        label=f"Experimental HD + D2 ({spec['display_label']})",
    )[0]
    experimental_d2o_handle = ax.plot(
        experimental_d2o["time (h)"],
        experimental_d2o["release flux (10^13 D atoms/s)"],
        linestyle=":",
        color=color,
        label=f"Experimental HDO + D2O ({spec['display_label']})",
    )[0]

    tds_handles.extend(
        [
            simulated_d2_handle,
            simulated_d2o_handle,
            experimental_d2_handle,
            experimental_d2o_handle,
        ]
    )
    tds_labels.extend(handle.get_label() for handle in tds_handles[-4:])

    rmspe_d2 = compute_rmspe(case["time_h"], case["release_rate_d2"], experimental_d2)
    rmspe_d2o = compute_rmspe(
        case["time_h"], case["release_rate_d2o"], experimental_d2o
    )
    rmspe_lines.append(
        f"{spec['rmspe_label']} RMSPEs: D2={rmspe_d2:.2f} %, D2O={rmspe_d2o:.2f} %"
    )

ax_temperature = ax.twinx()
temperature_handle = ax_temperature.plot(
    baseline_case["time_h"],
    baseline_case["temperature_k"],
    linestyle="-",
    color="k",
    linewidth=1.5,
    label="TMAP8 temperature history",
)[0]
fig.text(
    0.5,
    0.88,
    "\n".join(rmspe_lines),
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
    tds_handles + [temperature_handle],
    tds_labels + [temperature_handle.get_label()],
    loc="lower center",
    bbox_to_anchor=(0.5, 0.085),
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

# Stage 5: compare the relative deuterium mass-balance residual for all
# currently available modeled cases using the postprocessors written by the
# transient solves.
fig, ax = plt.subplots(figsize=(6.5, 4.8))

mass_handles = []
for spec in available_cases:
    mass_handles.append(
        ax.plot(
            spec["simulation"]["time_h"],
            spec["simulation"]["relative_mass_conservation_residual"],
            color=spec["color"],
            linewidth=1.8,
            label=spec["display_label"],
        )[0]
    )

ax.axhline(0.0, color="0.35", linewidth=1.0, linestyle="--")
ax.set_xlabel("Time (h)")
ax.set_ylabel("Deuterium mass-balance residual / initial inventory (-)")
ax.set_xlim(0, 4.2)
ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.legend(handles=mass_handles, loc="best")
ax.minorticks_on()

plt.savefig(
    "val-2k_natural_oxide_iteration_1_mass_conservation.png",
    bbox_inches="tight",
    dpi=300,
)
plt.close(fig)

# Stage 6: plot the oxygen conservation residual for every oxygen-field case
# that has the required bookkeeping columns.
oxygen_cases = [
    spec
    for spec in available_cases
    if spec["simulation"]["relative_oxygen_mass_conservation_residual"] is not None
]
if oxygen_cases:
    fig, ax = plt.subplots(figsize=(6.5, 4.8))

    oxygen_handles = []
    for spec in oxygen_cases:
        oxygen_handles.append(
            ax.plot(
                spec["simulation"]["time_h"],
                spec["simulation"]["relative_oxygen_mass_conservation_residual"],
                color=spec["color"],
                linewidth=1.8,
                label=spec["display_label"],
            )[0]
        )

    ax.axhline(0.0, color="0.35", linewidth=1.0, linestyle="--")
    ax.set_xlabel("Time (h)")
    ax.set_ylabel("Oxygen conservation residual / initial inventory (-)")
    ax.set_xlim(0, 4.2)
    ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
    ax.legend(handles=oxygen_handles, loc="best")
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
