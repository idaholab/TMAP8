import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
from matplotlib.patches import Patch
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Constants and history (see input file val-2f.i)

temperature_desorption_min = 300 # K
temperature_desorption_max = 1000 # K
desorption_heating_rate = 3/60 # K/minutes -> K/s
charge_time = 72*60*60 # h -> s
cooldown_duration = 12*60*60 # h -> s
start_time_desorption = charge_time + cooldown_duration
desorption_duration = (temperature_desorption_max-temperature_desorption_min)/desorption_heating_rate
endtime = charge_time + cooldown_duration + desorption_duration

#===============================================================================
# Define methods

def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output):
    """interpolate numerical solution to the experimental time step

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
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (tmap_input[right_limit] - tmap_input[left_limit]) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[left_limit]
    return new_tmap_output

#===============================================================================
# Extract TMAP8 predictions

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2f/gold/val-2f_out.csv"
    csv_folder_inf_recombination = "../../../../test/tests/val-2f/gold/val-2f_out_sieverts.csv"
    csv_folder_low_recombination = "../../../../test/tests/val-2f/gold/val-2f_out_low_recombination.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2f_out.csv"
    csv_folder_inf_recombination = "./gold/val-2f_out_sieverts.csv"
    csv_folder_low_recombination = "./gold/val-2f_out_low_recombination.csv"

# Read TMAP8 solution from CSV files
tmap_solution = pd.read_csv(csv_folder)
tmap_solution_inf_recombination = pd.read_csv(csv_folder_inf_recombination)
tmap_solution_low_recombination = pd.read_csv(csv_folder_low_recombination)

def extract_tmap_data_desorption(tmap_solution):
    tmap_time = tmap_solution['time'] # s
    tmap_temperature = tmap_solution['temperature'] # K
    tmap_flux_left = tmap_solution['scaled_flux_surface_left'] # atoms/s
    tmap_flux_right = tmap_solution['scaled_flux_surface_right'] # atoms/s
    tmap_escaping_deuterium = tmap_flux_left + tmap_flux_right # atoms/s
    tmap_implanted_deuterium = tmap_solution['scaled_implanted_deuterium'] # atoms/s
    tmap_mobile_deuterium = tmap_solution['scaled_mobile_deuterium'] # atoms
    tmap_trapped_deuterium_1 = tmap_solution['scaled_trapped_deuterium_1'] # atoms
    tmap_trapped_deuterium_2 = tmap_solution['scaled_trapped_deuterium_2'] # atoms
    tmap_trapped_deuterium_3 = tmap_solution['scaled_trapped_deuterium_3'] # atoms
    tmap_trapped_deuterium_4 = tmap_solution['scaled_trapped_deuterium_4'] # atoms
    tmap_trapped_deuterium_5 = tmap_solution['scaled_trapped_deuterium_5'] # atoms
    tmap_trapped_deuterium_intrinsic = tmap_solution['scaled_trapped_deuterium_intrinsic'] # atoms
    tmap_trapped_deuterium = tmap_trapped_deuterium_1+tmap_trapped_deuterium_2+tmap_trapped_deuterium_3+tmap_trapped_deuterium_4+tmap_trapped_deuterium_5+tmap_trapped_deuterium_intrinsic # atoms

    # Select only the simulation data for desorption period
    tmap_time_desorption = []
    tmap_temperature_desorption = []
    tmap_flux_desorption_left = []
    tmap_flux_desorption_right = []
    tmap_flux_desorption_total = []
    tmap_implanted_deuterium_desorption= []
    tmap_trapped_deuterium_desorption = []
    tmap_mobile_deuterium_desorption = []
    tmap_trapped_deuterium_1_desorption = []
    tmap_trapped_deuterium_2_desorption = []
    tmap_trapped_deuterium_3_desorption = []
    tmap_trapped_deuterium_4_desorption = []
    tmap_trapped_deuterium_5_desorption = []
    tmap_trapped_deuterium_intrinsic_desorption = []
    tmap_trapped_deuterium_desorption = []

    for i in range(len(tmap_time)):
        if tmap_time[i]>=start_time_desorption:
            tmap_time_desorption.append(tmap_time[i])
            tmap_temperature_desorption.append(tmap_temperature[i])
            tmap_flux_desorption_left.append(tmap_flux_left[i])
            tmap_flux_desorption_right.append(tmap_flux_right[i])
            tmap_flux_desorption_total.append(tmap_escaping_deuterium[i])
            tmap_implanted_deuterium_desorption.append(tmap_implanted_deuterium[i])
            tmap_trapped_deuterium_desorption.append(tmap_trapped_deuterium[i])
            tmap_mobile_deuterium_desorption.append(tmap_mobile_deuterium[i])
            tmap_trapped_deuterium_1_desorption.append(tmap_trapped_deuterium_1[i])
            tmap_trapped_deuterium_2_desorption.append(tmap_trapped_deuterium_2[i])
            tmap_trapped_deuterium_3_desorption.append(tmap_trapped_deuterium_3[i])
            tmap_trapped_deuterium_4_desorption.append(tmap_trapped_deuterium_4[i])
            tmap_trapped_deuterium_5_desorption.append(tmap_trapped_deuterium_5[i])
            tmap_trapped_deuterium_intrinsic_desorption.append(tmap_trapped_deuterium_intrinsic[i])

    tmap_time_desorption = np.array(tmap_time_desorption)
    tmap_temperature_desorption = np.array(tmap_temperature_desorption)
    tmap_flux_desorption_left = np.array(tmap_flux_desorption_left)
    tmap_flux_desorption_right = np.array(tmap_flux_desorption_right)
    tmap_flux_desorption_total = np.array(tmap_flux_desorption_total)
    tmap_implanted_deuterium_desorption = np.array(tmap_implanted_deuterium_desorption)
    tmap_trapped_deuterium_desorption = np.array(tmap_trapped_deuterium_desorption)
    tmap_mobile_deuterium_desorption = np.array(tmap_mobile_deuterium_desorption)
    tmap_trapped_deuterium_1_desorption = np.array(tmap_trapped_deuterium_1_desorption)
    tmap_trapped_deuterium_2_desorption = np.array(tmap_trapped_deuterium_2_desorption)
    tmap_trapped_deuterium_3_desorption = np.array(tmap_trapped_deuterium_3_desorption)
    tmap_trapped_deuterium_4_desorption = np.array(tmap_trapped_deuterium_4_desorption)
    tmap_trapped_deuterium_5_desorption = np.array(tmap_trapped_deuterium_5_desorption)
    tmap_trapped_deuterium_intrinsic_desorption = np.array(tmap_trapped_deuterium_intrinsic_desorption)

    return (tmap_time_desorption, tmap_temperature_desorption,
            tmap_flux_desorption_left, tmap_flux_desorption_right,
            tmap_flux_desorption_total, tmap_implanted_deuterium_desorption,
            tmap_trapped_deuterium_desorption, tmap_mobile_deuterium_desorption,
            tmap_trapped_deuterium_1_desorption, tmap_trapped_deuterium_2_desorption,
            tmap_trapped_deuterium_3_desorption, tmap_trapped_deuterium_4_desorption,
            tmap_trapped_deuterium_5_desorption, tmap_trapped_deuterium_intrinsic_desorption)

# Extract data for traps
tmap_time_desorption, tmap_temperature_desorption, tmap_flux_desorption_left, tmap_flux_desorption_right, tmap_flux_desorption_total, tmap_implanted_deuterium_desorption, tmap_trapped_deuterium_desorption, tmap_mobile_deuterium_desorption, tmap_trapped_deuterium_1_desorption, tmap_trapped_deuterium_2_desorption, tmap_trapped_deuterium_3_desorption, tmap_trapped_deuterium_4_desorption, tmap_trapped_deuterium_5_desorption, tmap_trapped_deuterium_intrinsic_desorption = extract_tmap_data_desorption(tmap_solution)

#===============================================================================
# Extract experimental data

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2f/gold/0.1_dpa.csv"
else:                                  # if in test folder
    csv_folder = "./gold/0.1_dpa.csv"

# Read experimental data from CSV file
experiment_data = pd.read_csv(csv_folder)
experiment_temperature = experiment_data['Temperature (K)']
area = 12e-03 * 15e-03
experiment_flux = experiment_data['Deuterium Loss Rate (at/s)'] / area

#===============================================================================
# Plot implantation distribution

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Define parameters for implantation distribution
sigma = 0.5e-9 # m
R_p = 0.7e-9 # m
flux = 5.79e19 # at/m^2/s

# Calculate implantation distribution
x = np.linspace(0, 6*sigma, 1000)
implantation_distribution = 1 / (sigma * (2 * np.pi) ** 0.5) * np.exp(-0.5 * ((x - R_p) / sigma) ** 2)
source_deuterium = flux * implantation_distribution

# Plot implantation distribution
ax.axvline(R_p + 6*sigma, color='r', linestyle='--', label=r'$R_p + 6\sigma$')
ax.plot(x, source_deuterium, label=r"Implantation distribution", c='b')

# Set plot labels and limits
ax.set_xlabel(u'x (m)')
ax.set_ylabel(u"Deuterium source (at/m$^3$/s)")
ax.legend(loc="lower left")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('val-2f_implantation_distribution.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Plot temperature history

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Plot temperature history over time
ax.plot(tmap_solution['time']/60/60, tmap_solution['temperature'], label=r"Temperature", c='b', ls='--')

# Set plot labels and limits
ax.set_xlabel(u'Time (h)')
ax.set_ylabel(u"Temperature (K)", c='b')
ax.legend(loc="lower left")
ax.set_ylim(bottom=0)
ax.set_xlim(left=0, right=endtime/60/60)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

plt.savefig('val-2f_temperature_history.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Plot comparison between TMAP8 predictions and experimental data

comparison_cases = [
    (tmap_solution, "val-2f_comparison"),
    (tmap_solution_low_recombination, "val-2f_comparison_low_recombination"),
    (tmap_solution_inf_recombination, "val-2f_comparison_inf_recombination")
]

for solution, filename in comparison_cases:
    # Extract relevant TMAP data
    (_, temperature, _, _, flux_total, *_) = extract_tmap_data_desorption(solution)

    # Create figure
    fig = plt.figure(figsize=[6.5, 5.5])
    gs = gridspec.GridSpec(1, 1)
    ax = fig.add_subplot(gs[0])

    # Plot TMAP and experimental data
    ax.plot(temperature, flux_total, label=r"TMAP8 (5 traps)", c='tab:blue')
    ax.scatter(experiment_temperature, experiment_flux, label="Experiment", color="black")

    # Labels and grid
    ax.set_xlabel("Temperature (K)")
    ax.set_ylabel("Deuterium flux (at/m$^2$/s)")
    ax.set_xlim(left=min(temperature), right=max(temperature))
    ax.set_ylim(bottom=0)
    ax.legend(loc="best")
    ax.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
    ax.minorticks_on()

    # Interpolate TMAP to experimental temperature for RMSPE
    interp_flux = numerical_solution_on_experiment_input(experiment_temperature, temperature, flux_total)
    RMSE = np.sqrt(np.mean((interp_flux - experiment_flux) ** 2))
    RMSPE = RMSE * 100 / np.mean(experiment_flux)
    ax.text(750, 6e16, f'RMSPE = {RMSPE:.2f} %', fontweight='bold')
    ax.text(750, 5.5e16, 'Damage = 0.1 dpa')

    # Save the plot
    plt.savefig(f"{filename}.png", bbox_inches='tight', dpi=300)
    plt.close(fig)


# ===============================================================================
# Plot trapped deuterium over time from desorption start

solutions = [
    (tmap_solution, "val-2f_deuterium_desorption"),
    (tmap_solution_low_recombination, "val-2f_deuterium_desorption_low_recombination"),
    (tmap_solution_inf_recombination, "val-2f_deuterium_desorption_inf_recombination")
]

colors = ['#00ffff','#40e0d0','#72c6f2','#a28bd9','#a167c9','#800080']

for solution, filename in solutions:
# Extract data from TMAP solution
    (time, temp, flux_left, flux_right, flux_total,
     implanted, trapped, mobile,
     trap1, trap2, trap3, trap4, trap5, trap_intrinsic) = extract_tmap_data_desorption(solution)

    # Time adjustment and conversion to hours
    time = time - time[0]
    time_hours = time / 3600
    time_intervals = np.diff(time)

    # Compute the escaping deuterium using trapezoidal integration
    escaping = np.zeros_like(flux_total)
    for i in range(1, len(flux_total)):
        avg_flux = (flux_total[i-1] + flux_total[i]) / 2
        escaping[i] = escaping[i-1] + avg_flux * time_intervals[i-1]

    # Total deuterium = mobile + escaping + trapped
    combined = mobile + escaping + trapped
    initial = mobile[0] + trapped[0]

    # Create figure
    fig = plt.figure(figsize=[6.5, 5.5])
    gs = gridspec.GridSpec(1, 1)
    ax1 = fig.add_subplot(gs[0])

    # Fill under the curves for trap and mobile deuterium
    ax1.fill_between(time_hours, 0, trap5, color=colors[0], alpha=0.3)
    ax1.fill_between(time_hours, trap5, trap5 + trap4, color=colors[1], alpha=0.3)
    ax1.fill_between(time_hours, trap5 + trap4, trap5 + trap4 + trap3, color=colors[2], alpha=0.3)
    ax1.fill_between(time_hours, trap5 + trap4 + trap3, trap5 + trap4 + trap3 + trap2, color=colors[3], alpha=0.3)
    ax1.fill_between(time_hours, trap5 + trap4 + trap3 + trap2, trapped, color=colors[4], alpha=0.3)
    ax1.fill_between(time_hours, trapped, trapped + mobile, color=colors[5], alpha=0.3)

    # Plot lines
    ax1.plot(time_hours, combined, c='tab:green', linestyle='-', label='Total')
    ax1.axhline(initial, color='tab:red', linestyle=':', label='Initial mobile and trapped deuterium')
    ax1.plot(time_hours, trap5, label='Trap 5', c=colors[0])
    ax1.plot(time_hours, trap5 + trap4, label='Trap 4', c=colors[1])
    ax1.plot(time_hours, trap5 + trap4 + trap3, label='Trap 3', c=colors[2])
    ax1.plot(time_hours, trap5 + trap4 + trap3 + trap2, label='Trap 2', c=colors[3])
    ax1.plot(time_hours, trapped, label='Trap 1', c=colors[4])
    ax1.plot(time_hours, trapped + mobile, label='Mobile', c=colors[5])

    ax1.set_xlabel('Time (hours)')
    ax1.set_ylabel('Deuterium amount (atoms)')
    ax1.set_ylim(bottom=0)
    ax1.set_xlim(left=0, right=max(time_hours))
    ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

    # Plot temperature on a second y-axis
    ax2 = ax1.twinx()
    ax2.plot(time_hours, temp, label='Temperature', c='tab:orange', linestyle='-')
    ax2.set_ylabel('Temperature (K)')
    ax2.set_ylim(bottom=min(temp), top=max(temp))

    # Custom legend with colored patches and lines
    legend_patches = [
        Patch(color=colors[0], alpha=0.5, label='Trap 5'),
        Patch(color=colors[1], alpha=0.5, label='Trap 4'),
        Patch(color=colors[2], alpha=0.5, label='Trap 3'),
        Patch(color=colors[3], alpha=0.5, label='Trap 2'),
        Patch(color=colors[4], alpha=0.5, label='Trap 1'),
        Patch(color=colors[5], alpha=0.5, label='Mobile deuterium'),
        plt.Line2D([0], [0], color='tab:green', linestyle='-', label='Total'),
        plt.Line2D([0], [0], color='tab:red', linestyle=':', label='Initial mobile and trapped deuterium'),
        plt.Line2D([0], [0], color='tab:orange', label='Temperature')
    ]
    labels = [item.get_label() for item in legend_patches]
    fig.legend(legend_patches, labels, bbox_to_anchor=(0.9, 0.55), fontsize=6, frameon=True, framealpha=0.9)

    # RMSPE calculation and annotation
    RMSE = np.sqrt(np.mean((combined - initial) ** 2))
    RMSPE = RMSE * 100 / initial
    ax1.text(0.40, 0.90, f'RMSPE = {RMSPE:.2f} %', transform=ax1.transAxes, fontsize=12, fontweight='bold', verticalalignment='top')

    # Save the figure
    plt.savefig(f"{filename}.png", bbox_inches='tight', dpi=300)
    plt.close(fig)
