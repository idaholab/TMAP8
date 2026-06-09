import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import scipy.stats as stats
import os

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


def plot_validation(t_sim, sim_data, t_exp, exp_data, ylabel, title, filename):
    """Plot simulation results against SRNL experimental data with RMSPE annotation

    Args:
        t_sim (float, ndarray): simulation time array in days
        sim_data (float, ndarray): simulation output values
        t_exp (float, ndarray): experimental time array in days
        exp_data (float, ndarray): experimental measurement values
        ylabel (str): y-axis label
        title (str): plot title
        filename (str): output PNG filename
    """
    fig = plt.figure(figsize=(10, 6))
    plt.plot(t_sim, sim_data, label="Simulation")
    plt.plot(t_exp, exp_data, "ro", label="Experimental Data")
    mapped = numerical_solution_on_experiment_input(t_exp, t_sim, sim_data)
    annotate_rmspe(mapped, exp_data, t_sim[-1] / 2, sim_data[-1] / 4)
    plt.ylabel(ylabel)
    plt.xlabel("Time (Days)")
    plt.title(title)
    plt.xlim(0)
    plt.ylim(0)
    plt.legend()
    plt.grid(True)
    plt.savefig(filename, bbox_inches="tight", dpi=300)
    plt.close(fig)


def plot_source_function(depth, width, flux, filename, n_widths=6):
    """Plot the Gaussian implantation source term centered around the implantation depth

    The source rate evaluated at position x (µm) is:
        S(x) = flux / (width * sqrt(2*pi)) * exp(-0.5 * ((x - depth) / width)^2)

    Args:
        depth (float): mean implantation depth in µm
        width (float): standard deviation (sigma) of the implantation profile in µm
        flux (float): incident surface flux in at/µm²/s
        filename (str): output PNG filename
        n_widths (int): half-width of the x-axis expressed in number of sigmas
    """
    x_lo = max(0.0, depth - n_widths * width)
    x_hi = depth + n_widths * width
    x = np.linspace(x_lo, x_hi, 2000)
    source = flux / (width * np.sqrt(2 * np.pi)) * np.exp(-0.5 * ((x - depth) / width) ** 2)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(x, source, color="steelblue", linewidth=2, label="Source rate")
    ax.axvline(depth, color="k", linestyle="--", linewidth=1, label=f"Depth = {depth:.4f} µm")
    ax.set_xlabel(r"Depth ($\mu$m)")
    ax.set_ylabel(r"Source rate (at/$\mu$m$^3$/s)")
    ax.set_title("Gaussian implantation source profile")
    ax.set_xlim(x_lo, x_hi)
    ax.set_ylim(bottom=0)
    ax.legend()
    ax.grid(True)
    plt.tight_layout()
    plt.savefig(filename, bbox_inches="tight", dpi=300)
    plt.close(fig)

# =========================== TMAP8 steel-only simulation data extraction ========================== #

# (
#     steel_only_t,
#     steel_only_total_mass_steel,
#     steel_only_flux_steel,
#     steel_only_exact_diffusion_length,
#     steel_only_simulated_diffusion_length,
# ) = read_csv_from_TMAP8(
#     "steel_only_out.csv",
#     [
#         "time",
#         "annular_cylinder_total_mass_steel",
#         "annular_cylinder_time_integrated_flux",
#         "exact_diffusion_length",
#         "simulated_diffusion_length",
#     ],
# )
csv_folder = "val-2l_out.csv"
simulation_TMAP8_data = pd.read_csv(csv_folder)
simulation_time_TMAP8 = simulation_TMAP8_data["time"]
# simulation_recom_flux_left_TMAP8 = simulation_TMAP8_data[
    # "scaled_recombination_flux_left"
# ]
# simulation_recom_flux_right_TMAP8 = simulation_TMAP8_data[
    # "scaled_recombination_flux_right"
# ]

### Conservation of Mass ###
time_integrated_flux_difference = simulation_TMAP8_data['time_integrated_desorbed_flux_difference']
total_deuterium_retention = simulation_TMAP8_data['total_deuterium_retention']

# Measure and Plot Conservation of Mass
plt.figure(figsize=(10, 6))
plt.plot(simulation_time_TMAP8, time_integrated_flux_difference, label = 'Time-Accumulated Boundary Flux')
plt.plot(simulation_time_TMAP8,total_deuterium_retention, label = 'Total Concentration in Tungsten')
RMSE = np.sqrt(np.mean((total_deuterium_retention-time_integrated_flux_difference)**2) )
RMSPE = RMSE*100/np.mean(total_deuterium_retention)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(60,0.02, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.xlabel('Time (s)')
plt.ylabel(r'atom/$\mu m^2$')
plt.title(f'Conservation of Mass')
plt.xlim(0,simulation_time_TMAP8.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

difference = abs(time_integrated_flux_difference-total_deuterium_retention)
plt.figure(figsize=(10, 6))
plt.plot(simulation_time_TMAP8,difference)
plt.xlabel('Time (s)')
plt.ylabel(r'atom/$\mu m^2$')
plt.title(f'Conservation of Mass Difference')
plt.xlim(0,simulation_time_TMAP8.max())
plt.grid(True)
plt.tight_layout()
plt.show()
# Read experiment data
# if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
#     csv_folder = "../../../../test/tests/val-2l/gold/experiment_data_paper.csv"
# else:  # if in test folder
#     csv_folder = "./gold/experiment_data_paper.csv"
# experiment_TMAP4_data = pd.read_csv(csv_folder)
# experiment_time_TMAP4 = experiment_TMAP4_data["time (s)"]
# experiment_flux_TMAP4 = experiment_TMAP4_data["permeation flux (atom/m^2/s)"]

TMAP8_file_base = "val-2l_comparison"
############################ recombination flux - atom/m$^2$/s ############################
# fig = plt.figure(figsize=[6.5, 5.5])
# gs = gridspec.GridSpec(1, 1)
# ax = fig.add_subplot(gs[0])

# ax.plot(
#     simulation_time_TMAP8 / 3600,
#     simulation_recom_flux_right_TMAP8,
#     linestyle="-",
#     label=r"TMAP8",
#     c="tab:gray",
# )
# ax.plot(
#     experiment_time_TMAP4 / 3600,
#     experiment_flux_TMAP4,
#     linestyle="--",
#     label=r"Experiment",
#     c="k",
# )

# ax.set_xlabel("Time (hr)")
# ax.set_ylabel("Deuterium flux (atom/m$^2$/s)")
# ax.legend(loc="best")
# ax.set_ylim(bottom=0)
# ax.set_xlim(left=-0.1, right=2e4 / 3600)
# plt.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
# tmap_flux_for_rmspe = numerical_solution_on_experiment_input(
#     experiment_time_TMAP4, simulation_time_TMAP8, simulation_recom_flux_right_TMAP8
# )
# RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe - experiment_flux_TMAP4) ** 2))
# RMSPE = RMSE * 100 / np.mean(experiment_flux_TMAP4)
# ax.text(1e4 / 3600.0, 40e15, "RMSPE = %.2f " % RMSPE + "%", fontweight="bold")
# ax.minorticks_on()
# ax.ticklabel_format(axis="y", style="sci", scilimits=(15, 15))
# plt.savefig(f"{TMAP8_file_base}.png", bbox_inches="tight", dpi=300)
# plt.close(fig)


############################ implantation - atom/m$^2$/s ############################
# Use VPP to pull this from MOOSE simulation???

# Parameters from val-2l.i converted to µm
depth_um = 2.64e-9 * 1e6   # ${units 2.64e-9 m -> mum}
width_um = 3.58e-9 * 1e6   # ${units 3.58e-9 m -> mum}
flux_um  = 5e21 * 1e-12    # ${units 5e21 at/m^2/s -> at/mum^2/s}

plot_source_function(
    depth=depth_um,
    width=width_um,
    flux=flux_um,
    filename="val-2l_comparison_normal_distribution.png",
)
