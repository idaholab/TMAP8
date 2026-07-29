import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
from matplotlib.patches import Patch
import pandas as pd
from scipy import special
import scipy.stats as stats
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#  Must match val-2l.i: trap_per_free = ... (rescaling factor for trapped variable)
trap_per_free = 1e4  # update this if val-2l.i changes

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
        csv_folder = f"../../../../test/tests/val-2l/gold/{file_name}"

    else:  # if in test folder
        # csv_folder = f"./gold/{file_name}"
        csv_folder = f"./{file_name}"
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


def plot_conservation_of_mass(t, flux, mass, flux_label, title, filename):
    """Plot accumulated boundary flux against total mass to verify conservation

    Args:
        t (float, ndarray): time array in days
        flux (float, ndarray): accumulated boundary flux in µmol H
        mass (float, ndarray): total H mass in domain in µmol H
        flux_label (str): legend label for the flux line
        title (str): plot title
        filename (str): output PNG filename
    """
    fig = plt.figure(figsize=(10, 6))
    plt.plot(t, flux, label=flux_label)
    plt.plot(t, mass, label="H Total Mass")
    annotate_rmspe(flux, mass, t[-1] / 2, mass[-1] / 4)
    plt.xlabel("Time (Days)")
    plt.ylabel(r"$\mu$mol H")
    plt.title(title)
    plt.xlim(0, t.max())
    plt.ylim(0)
    plt.legend()
    plt.grid(True)
    plt.savefig(filename, bbox_inches="tight", dpi=300)
    plt.close(fig)

def plot_diffusivity_vs_temperature(
    simulation_file="val-2l_out.csv",
    filename="val-2l_diffusivity_vs_temperature.png",
):
    """Plot the deuterium diffusivity in tungsten against temperature

    The diffusivity is spatially uniform (it depends only on temperature), so the
    ``diffusivity_pp`` and ``temperature`` postprocessors from the TMAP8 output fully
    describe D(T) over the simulated TDS ramp. Reading them straight from the CSV
    keeps the Arrhenius law defined in exactly one place (val-2l.i). It is the
    Frauenfelder relation corrected for deuterium, Shimada et al. 2010
    (p. S668, Section 3): D = 2.9e-7 * exp(-0.39 eV / (k_B T)) m^2/s.

    Args:
        simulation_file (str): TMAP8 CSV with "temperature" (K) and "diffusivity_pp"
            (µm²/s) columns
        filename (str): output PNG filename
    """
    temperature, diffusivity = read_csv_from_TMAP8(
        simulation_file, ["temperature", "diffusivity_pp"]
    )
    # Drop the INITIAL row (t = 0), where postprocessors are still 0, then sort by T.
    valid = diffusivity > 0
    temperature, diffusivity = temperature[valid], diffusivity[valid]
    order = np.argsort(temperature)
    temperature, diffusivity = temperature[order], diffusivity[order]
    diffusivity_m2_s = diffusivity * 1e-12  # µm²/s -> m²/s

    reciprocal_temperature = 1000.0 / temperature  # 1000/T (1/K)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(reciprocal_temperature, diffusivity_m2_s, color="steelblue", linewidth=2)
    ax.set_xlabel(r"Reciprocal temperature 1000/T (K$^{-1}$)")
    ax.set_ylabel(r"Diffusivity (m$^2$/s)")
    ax.set_title("Deuterium diffusivity in tungsten TMAP8 Material")
    ax.grid(True, which="both", linestyle="--", alpha=0.4)
    plt.tight_layout()
    plt.savefig(filename, bbox_inches="tight", dpi=300)
    plt.close(fig)


def plot_unirradiated_desorption(
    experiment_file="unirradiated_data.csv",
    simulation_file="val-2l_out.csv",
    simulation_flux_column="deuterium_release_flux_total",
    experiment_plot="val-2l_experimental_desorption.png",
    simulation_plot="val-2l_simulated_desorption.png",
    comparison_plot="val-2l_comparison_desorption.png",
):
    """Plot the Shimada (2010) unirradiated desorption data and the TMAP8 comparison

    Produces three figures:
        1. The digitized experimental desorbed-flux history (Shimada 2010,
           unirradiated / 0 dpa): temperature (K) versus desorbed flux (m^-2 s^-1).
           Experimental times are mapped to temperatures via the simulation's T(t) ramp.
        2. The raw TMAP8 simulated desorbed-flux history: temperature (K) versus
           desorbed flux (m^-2 s^-1).
        3. The TMAP8 simulated desorbed flux mapped onto the experimental temperature
           points, overlaid on the experimental data and annotated with the RMSPE.

    Args:
        experiment_file (str): two-column, header-less CSV of
            (time [s], desorbed flux [m^-2 s^-1])
        simulation_file (str): TMAP8 CSV output holding "time", "temperature", and
            the desorbed-flux column
        simulation_flux_column (str): name of the desorbed-flux column in
            simulation_file. TMAP8 reports it in at/mum^2/s; it is converted to
            at/m^2/s to match the experiment.
        experiment_plot (str): output PNG filename for plot 1
        simulation_plot (str): output PNG filename for plot 2
        comparison_plot (str): output PNG filename for plot 3
    """
    # experiment: header-less (time [s], desorbed flux [m^-2 s^-1])
    experiment = np.loadtxt(experiment_file, delimiter=",")
    experiment_time, experiment_flux = experiment[:, 0], experiment[:, 1]

    # simulation data: time, temperature, and desorbed flux
    simulation_time, simulation_temperature, simulation_flux = read_csv_from_TMAP8(
        simulation_file, ["time", "temperature", simulation_flux_column]
    )
    # at/mum^2/s -> at/m^2/s (x1e12); atomic D flux -> molecular D2 flux (/2) to match the
    # RGA, which detects D2 (mass 4) and HD (mass 3) -- same convention as val-2d
    simulation_flux = simulation_flux * 1e12 / 2

    # Map experimental times to temperatures using the simulation's T(t) ramp,
    # then truncate to the simulation time range to avoid extrapolation.
    in_sim_range = experiment_time <= simulation_time.max()
    experiment_time = experiment_time[in_sim_range]
    experiment_flux = experiment_flux[in_sim_range]
    experiment_temperature = numerical_solution_on_experiment_input(
        experiment_time, simulation_time, simulation_temperature
    )

    # ---- Plot 1: experimental desorption history ----
    plt.figure(figsize=(10, 6))
    plt.plot(experiment_temperature, experiment_flux, "ro", label="Experiment (Shimada 2010, 0 dpa)")
    plt.xlabel("Temperature (K)")
    plt.ylabel(r"Desorbed flux (m$^{-2}$s$^{-1}$)")
    plt.title("Unirradiated deuterium desorption")
    plt.xlim(experiment_temperature.min(), experiment_temperature.max())
    plt.ylim(0)
    plt.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(experiment_plot, bbox_inches="tight", dpi=300)
    # plt.show()

    # ---- Plot 2: raw simulated desorption history ----
    plt.figure(figsize=(10, 6))
    plt.plot(simulation_temperature, simulation_flux, "b-", label="TMAP8 (0 dpa)")
    plt.xlabel("Temperature (K)")
    plt.ylabel(r"Desorbed flux (m$^{-2}$s$^{-1}$)")
    plt.title("Unirradiated deuterium desorption: TMAP8")
    plt.xlim(simulation_temperature.min(), simulation_temperature.max())
    plt.ylim(0)
    plt.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(simulation_plot, bbox_inches="tight", dpi=300)
    # plt.show()

    # Map simulated flux onto experimental temperature points for RMSPE
    mapped_simulation_flux = numerical_solution_on_experiment_input(
        experiment_temperature, simulation_temperature, simulation_flux
    )
    tmin = 1000
    tmax = 2600
    rmspe_region = (experiment_time >= tmin) & (experiment_time <= tmax)

    # ---- Plot 3: simulation vs experiment with RMSPE ----
    plt.figure(figsize=(10, 6))
    plt.plot(experiment_temperature, experiment_flux, "ro", label="Experiment (Shimada 2010, 0 dpa)")
    plt.plot(simulation_temperature, simulation_flux, "b-", label="TMAP8")
    if rmspe_region.any():
        plt.axvline(experiment_temperature[rmspe_region].min(), color="green", linestyle="--",
                    linewidth=1.2, label="RMSPE region")
        plt.axvline(experiment_temperature[rmspe_region].max(), color="green", linestyle="--",
                    linewidth=1.2)
        annotate_rmspe(
            mapped_simulation_flux[rmspe_region],
            experiment_flux[rmspe_region],
            experiment_temperature.mean(),
            experiment_flux.max() / 4,
        )
    plt.xlabel("Temperature (K)")
    plt.ylabel(r"Desorbed flux (m$^{-2}$s$^{-1}$)")
    plt.title("Unirradiated deuterium desorption: TMAP8 vs experiment")
    plt.xlim(experiment_temperature.min(), experiment_temperature.max())
    plt.ylim(0)
    plt.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(comparison_plot, bbox_inches="tight", dpi=300)
    # plt.show()

# =========================== TMAP8 simulation data extraction ========================== #

csv_folder = "val-2l_out.csv"
simulation_TMAP8_data = pd.read_csv(csv_folder)
simulation_time_TMAP8 = simulation_TMAP8_data["time"]

### Conservation of Mass (replicating val-2k) ###
# val-2k computes the conservation residual in MOOSE (deuterium_mass_conservation_residual =
# inventory_change + released), then in Python normalizes it by the fixed initial inventory M(0) and
# plots the relative residual over time. We follow the same recipe here. M(0) is read from the t=0 row
# of total_deuterium_retention, which runs on INITIAL (cf. val-2k reading
# deuterium_inventory_in_sample_physical.iloc[0]).
total_deuterium_retention = simulation_TMAP8_data['total_deuterium_retention']
temperature_history = simulation_TMAP8_data['temperature']
mass_conservation_residual = simulation_TMAP8_data['deuterium_mass_conservation_residual']
initial_inventory = total_deuterium_retention.iloc[0]
relative_mass_conservation_residual = mass_conservation_residual / initial_inventory

# --- Read individual mobile and trapped integrals for the stacked inventory plot ---
# total_mobile_retention  : physical mobile inventory  (at/µm²), no scaling needed
# total_trapped_retention : MOOSE stores the *rescaled* variable, so multiply by
#                           trap_per_free to recover the physical trapped inventory.
total_mobile_retention  = simulation_TMAP8_data["total_mobile_retention"]
total_trapped_retention = simulation_TMAP8_data["total_trapped_retention"] * trap_per_free

# --- Total deuterium inventory with temperature history ---
# Add one entry per species to inventory_series. They are stacked bottom-up with
# fill_between, so order matters: put the largest / most stable contribution first.
# Append a new tuple here when additional trap populations are added.
inventory_series = [
    ("Trapped D (trap 1, 1.35 eV)", total_trapped_retention, plt.get_cmap("viridis")(0.45)),
    ("Mobile D",                    total_mobile_retention,   plt.get_cmap("viridis")(0.95)),
]

fig, ax = plt.subplots(figsize=(6.5, 5.5))
inventory_bottom = np.zeros_like(total_deuterium_retention)
legend_patches = []
for label, values, color in inventory_series:
    ax.fill_between(simulation_time_TMAP8, inventory_bottom, inventory_bottom + values,
                    color=color, alpha=0.3)
    ax.plot(simulation_time_TMAP8, inventory_bottom + values, color=color, linewidth=1.0)
    inventory_bottom = inventory_bottom + values
    legend_patches.append(Patch(color=color, alpha=0.5, label=label))

total_inventory = inventory_bottom
total_handle = ax.plot(simulation_time_TMAP8, total_inventory, color="tab:green", linewidth=1.5,
                       label="Total D inventory")[0]

ax_temperature = ax.twinx()
temperature_handle = ax_temperature.plot(simulation_time_TMAP8, temperature_history, linestyle="-",
                                         color="k", linewidth=1.5, label="TMAP8 temperature history")[0]

ax.set_xlabel("Time (s)")
ax.set_ylabel(r"Deuterium inventory (atoms/$\mu m^2$)")
ax.set_xlim(0, simulation_time_TMAP8.max())
ax.set_ylim(bottom=0)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax_temperature.set_ylabel("Temperature (K)")
ax.legend(handles=[total_handle, temperature_handle] + legend_patches[::-1], loc="lower right")
ax.minorticks_on()
plt.savefig("val-2l_inventory.png", bbox_inches="tight", dpi=300)
# plt.show()
plt.close(fig)

# --- Relative deuterium mass-balance residual over time (cf. comparison_val-2k.py Stage 6) ---
fig, ax = plt.subplots(figsize=(6.5, 4.8))
ax.plot(simulation_time_TMAP8, relative_mass_conservation_residual, color="tab:blue", linewidth=1.8)
ax.axhline(0.0, color="0.35", linewidth=1.0, linestyle="--")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Deuterium mass-balance residual / initial inventory (-)")
ax.set_xlim(0, simulation_time_TMAP8.max())
ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()
plt.savefig("val-2l_mass_conservation.png", bbox_inches="tight", dpi=300)
# plt.show()
plt.close(fig)

TMAP8_file_base = "val-2l_comparison"

############################ diffusivity vs temperature ############################
# D(T) over the simulated TDS ramp, read from the temperature/diffusivity postprocessors
plot_diffusivity_vs_temperature()

############################ desorption: experiment + TMAP8 comparison ############################
# Shimada 2010, unirradiated / 0 dpa (unirradiated_data.csv)
plot_unirradiated_desorption()
