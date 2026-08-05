# This script generates comparison, verification, and comparison plots for the SRNL mini-canister
# example case. It reads simulation output from two TMAP8 models — a steel-only
# diffusion model and a coupled gas-steel diffusion model — along with SRNL experimental data

import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
from matplotlib import gridspec

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ================================= Functions ================================ #


def read_csv_from_TMAP8(file_name, parameter_names):
    """Read simulation output columns from a gold CSV file into a numpy array

    Args:
        file_name (str): name of the CSV file in the gold directory
        parameter_names (list of str): column names to extract, in desired order

    Returns:
        ndarray: 2D array of shape (len(parameter_names), n_timesteps)
    """
    if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
        csv_folder = f"../../../../test/tests/mini_canister/gold/{file_name}"

    else:  # if in test folder
        csv_folder = f"./gold/{file_name}"
    simulation_data = pd.read_csv(csv_folder)
    return np.array([simulation_data[name] for name in parameter_names])


def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output):
    """Get new numerical solution based on the experimental input data points

    Args:
        experiment_input (float, ndarray): experimental input data points
        tmap_input (float, ndarray): numerical input data points
        tmap_output (float, ndarray): numerical output data points

    Returns:
        float, ndarray: updated tmap_output based on the data points in experiment_input
    """
    new_tmap_output = np.zeros(len(experiment_input))
    for i in range(len(experiment_input)):
        left_limit = np.argwhere((np.diff(tmap_input < experiment_input[i])))[0][0]
        right_limit = left_limit + 1
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (
            tmap_input[right_limit] - tmap_input[left_limit]
        ) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[
            left_limit
        ]
    return new_tmap_output


def compute_rmspe(simulated, reference):
    """Compute the Root Mean Square Percentage Error between two arrays

    Args:
        simulated (float, ndarray): simulated values
        reference (float, ndarray): reference values used as the denominator

    Returns:
        float: RMSPE in percent
    """
    RMSE = np.sqrt(np.mean((simulated - reference) ** 2))
    return RMSE * 100 / np.mean(reference)


def annotate_rmspe(simulated, reference, x_pos, y_pos):
    """Compute RMSPE and annotate it as bold text on the current matplotlib axes

    Args:
        simulated (float, ndarray): simulated values
        reference (float, ndarray): reference values used as the denominator
        x_pos (float): x-coordinate of the annotation
        y_pos (float): y-coordinate of the annotation
    """
    RMSPE = compute_rmspe(simulated, reference)
    plt.text(x_pos, y_pos, "RMSPE = %.2f %%" % RMSPE, fontweight="bold")


def plot_conservation_of_mass(t, flux, mass, filename):
    """Plot the absolute percent difference between accumulated boundary flux
    and total mass as a single curve, verifying mass conservation. Before the
    accumulated mass exceeds 1% of the total final hydrogen yield, absolute
    error is calculated to avoid noise from early-time near-zero denominators.

    Args:
        t (float, ndarray): time array in days
        flux (float, ndarray): accumulated boundary flux in µmol H
        mass (float, ndarray): total H mass in domain in µmol H
        filename (str): output PNG filename
    """
    t = np.asarray(t)
    flux = np.asarray(flux, dtype=float)
    mass = np.asarray(mass, dtype=float)

    abs_err = np.abs(flux - mass)
    rel_err = np.abs(
        np.divide(flux, mass, out=np.full_like(mass, np.nan), where=mass > 0) - 1.0
    ) * 100.00

    threshold = 0.01 * mass[-1] # Switch to relative metric at the time 1% of total Hydrogen yield is achieved
    if not np.any(mass > threshold):
        raise ValueError("Hydrogen yield threshold is never achieved")
    t_switch = t[mass > threshold][0]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=[6.5, 8.0])

    early = (mass <= threshold) & (t > 0)
    late = mass > threshold

    ax1.plot(t[early], abs_err[early], c="tab:orange")
    ax2.plot(t[late], rel_err[late], c="tab:gray")

    ax1.set_ylabel("Abs. error (µmol H)")
    ax2.set_ylabel("Percent difference (%)")
    ax2.set_xlabel("Time (days)")

    ax1.set_xlim(left=t[0], right=t_switch)
    ax2.set_xlim(left=t_switch, right=t[-1])
    fig.canvas.draw()

    # Explicitly label the first point of ax2.
    ticks = ax2.get_xticks()
    ticks = ticks[(ticks > t_switch) & (ticks <= t[-1])]
    ax2.set_xticks(np.insert(ticks, 0, t_switch))

    for ax in (ax1, ax2):
        ax.set_ylim(bottom=0)
        ax.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
    fig.tight_layout()
    plt.savefig(filename, bbox_inches="tight", dpi=300)
    plt.close(fig)


def plot_comparison(t_sim, sim_data, t_exp, exp_data, ylabel, filename):
    """Plot simulation results against SRNL experimental data with RMSPE annotation

    Args:
        t_sim (float, ndarray): simulation time array in days
        sim_data (float, ndarray): simulation output values
        t_exp (float, ndarray): experimental time array in days
        exp_data (float, ndarray): experimental measurement values
        ylabel (str): y-axis label
        filename (str): output PNG filename
    """
    fig = plt.figure(figsize=[6.5, 5.5])
    gs = gridspec.GridSpec(1, 1)
    ax = fig.add_subplot(gs[0])
    ax.plot(t_sim, sim_data, label="TMAP8", c="tab:blue")
    ax.plot(
        t_exp,
        exp_data,
        label="Experiment",
        marker="o",
        linestyle="None",
        c="k",
    )
    mapped = numerical_solution_on_experiment_input(t_exp, t_sim, sim_data)
    annotate_rmspe(mapped, exp_data, t_sim[-1] / 2, sim_data[-1] / 4)
    ax.set_xlabel("Time (days)")
    ax.set_ylabel(ylabel)
    ax.legend(loc="best")
    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0)
    plt.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
    ax.minorticks_on()
    plt.savefig(filename, bbox_inches="tight", dpi=300)
    plt.close(fig)


# =========================== SRNL experimental data extraction ========================== #

SRNL_dose, SRNL_H2_yield, SRNL_gas_pressure, SRNL_H2_fraction = read_csv_from_TMAP8(
    "SRNL_data.csv",
    ["Dose (MGy)", "Cum. H2 yield (μmol)", "Gas pressure (kPa)", "H2 gas fraction (%)"],
)
# Assuming 124 Gy/min in Cobalt-60 irradiator
SRNL_time = SRNL_dose * 365.25 / 65.21904
SRNL_total_mass_gas = 2 * SRNL_H2_yield  # Count H atoms
SRNL_partial_pressure = 1e3 * SRNL_gas_pressure * SRNL_H2_fraction / 100

# =========================== TMAP8 steel-only simulation data extraction ========================== #

# SRNL-pressure run: used for conservation of mass and the steel-only vs. gas-steel
# hydrogen-yield comparison so the steel-only boundary condition matches the time-
# dependent pressure history seen by the gas-steel model.
(
    steel_only_t,
    steel_only_total_mass_steel,
    steel_only_flux_steel,
) = read_csv_from_TMAP8(
    "steel_only_out_SRNL_pressure.csv",
    [
        "time",
        "annular_cylinder_total_mass_steel",
        "annular_cylinder_time_integrated_flux",
    ],
)

# Constant-pressure run: used only for the diffusion-front verification, whose
# analytical solution ell(t) = sqrt(pi*D*t) assumes a step Dirichlet BC.
(
    steel_only_const_t,
    steel_only_exact_diffusion_length,
    steel_only_simulated_diffusion_length,
) = read_csv_from_TMAP8(
    "steel_only_out_constant_pressure.csv",
    [
        "time",
        "exact_diffusion_length",
        "simulated_diffusion_length",
    ],
)

# =========================== TMAP8 gas-steel simulation data extraction ========================== #

(
    t,
    H_partial_pressure_interface,
    total_mass_steel,
    total_mass_gas,
    total_mass,
    time_integrated_flux,
    total_generation,
) = read_csv_from_TMAP8(
    "gas_steel_out.csv",
    [
        "time",
        "H_partial_pressure_interface",
        "annular_cylinder_total_mass_steel",
        "inner_cylinder_total_mass_gas",
        "cylinder_total_mass",
        "cylinder_time_integrated_flux",
        "cylinder_total_generation",
    ],
)

# =========================== Hydrogen yield in steel model comparison ========================== #

# Compute RMSPE between the two solid mass lines, interpolating if timestep counts differ
if len(steel_only_t) < len(t):
    rmspe = compute_rmspe(
        numerical_solution_on_experiment_input(steel_only_t, t, total_mass_steel),
        steel_only_total_mass_steel,
    )
elif len(steel_only_t) > len(t):
    rmspe = compute_rmspe(
        total_mass_steel,
        numerical_solution_on_experiment_input(
            t, steel_only_t, steel_only_total_mass_steel
        ),
    )
else:
    rmspe = compute_rmspe(total_mass_steel, steel_only_total_mass_steel)
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])
ax2 = ax1.twinx()
for t_arr, mass_steel, total, color, label in [
    (
        steel_only_t,
        steel_only_total_mass_steel,
        total_generation + steel_only_total_mass_steel,
        "tab:blue",
        "Steel-only",
    ),
    (t, total_mass_steel, total_mass, "tab:red", "Gas-steel"),
]:
    ax1.plot(t_arr, mass_steel, color=color, label=f"{label} mass")
    # Avoid dividing by 0 at initial time t=0
    percentage = np.divide(
        100 * mass_steel,
        total,
        out=np.zeros_like(mass_steel, dtype=float),
        where=total > 0,
    )
    ax2.plot(t_arr, percentage, color=color, linestyle="--", label=f"{label} %")
ax1.text(
    0.65 * max(steel_only_t[-1], t[-1]),
    max(steel_only_total_mass_steel[-1], total_mass_steel[-1]) / 2,
    "RMSPE = %.2f %%" % rmspe,
    fontweight="bold",
)
ax1.set_xlabel("Time (days)")
ax1.set_ylabel(r"Total mass ($\mathrm{\mu mol\,H}$)")
ax2.set_ylabel("H in steel (%)")
ax1.set_xlim(left=0)
ax1.set_ylim(bottom=0)
ax2.set_ylim(bottom=0)
ax1.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
ax1.minorticks_on()
ax2.minorticks_on()
handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(handles1 + handles2, labels1 + labels2, loc="lower right")
plt.savefig("hydrogen_yield_in_steel.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# =========================== TMAP8 steel-only verification plots ========================== #

# Check length of diffusion front
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(
    steel_only_const_t,
    steel_only_simulated_diffusion_length,
    label="TMAP8",
    c="tab:gray",
)
ax.plot(
    steel_only_const_t,
    steel_only_exact_diffusion_length,
    label="Analytical",
    c="k",
    linestyle="--",
)
annotate_rmspe(
    steel_only_simulated_diffusion_length,
    steel_only_exact_diffusion_length,
    steel_only_const_t[-1] / 2,
    steel_only_exact_diffusion_length[-1] / 4,
)
ax.set_xlabel("Time (days)")
ax.set_ylabel("Length (mm)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()
plt.savefig("diffusion_length.png", bbox_inches="tight", dpi=300)
plt.close(fig)

plot_conservation_of_mass(
    steel_only_t,
    steel_only_flux_steel,
    steel_only_total_mass_steel,
    "steel_only_conservation_of_mass.png",
)

# =========================== TMAP8 gas-steel V&V plots ========================== #

plot_comparison(
    t,
    H_partial_pressure_interface,
    SRNL_time,
    SRNL_partial_pressure,
    r"$\mathrm{H}_2$ partial pressure (Pa)",
    "partial_pressure_comparison.png",
)

plot_comparison(
    t,
    total_mass_gas,
    SRNL_time,
    SRNL_total_mass_gas,
    r"Total mass ($\mathrm{\mu mol\,H}_2$)",
    "gas_phase_comparison.png",
)

plot_conservation_of_mass(
    t,
    time_integrated_flux + total_generation,
    total_mass,
    "gas_steel_conservation_of_mass.png",
)
