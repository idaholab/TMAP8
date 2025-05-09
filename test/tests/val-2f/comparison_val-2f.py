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
else:                                  # if in test folder
    csv_folder = "./gold/val-2f_out.csv"

# Read TMAP8 solution from CSV files
tmap_solution = pd.read_csv(csv_folder)

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
    tmap_trapped_deuterium = tmap_trapped_deuterium_1 + tmap_trapped_deuterium_2 # atoms

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

    return (tmap_time_desorption, tmap_temperature_desorption,
            tmap_flux_desorption_left, tmap_flux_desorption_right,
            tmap_flux_desorption_total, tmap_implanted_deuterium_desorption,
            tmap_trapped_deuterium_desorption, tmap_mobile_deuterium_desorption,
            tmap_trapped_deuterium_1_desorption, tmap_trapped_deuterium_2_desorption)

# Extract data for traps
tmap_time_desorption, tmap_temperature_desorption, tmap_flux_desorption_left, tmap_flux_desorption_right, tmap_flux_desorption_total, tmap_implanted_deuterium_desorption, tmap_trapped_deuterium_desorption, tmap_mobile_deuterium_desorption, tmap_trapped_deuterium_1_desorption, tmap_trapped_deuterium_2_desorption = extract_tmap_data_desorption(tmap_solution)

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

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Plot TMAP8 predictions and experimental data
ax.plot(tmap_temperature_desorption, tmap_flux_desorption_total, label=r"TMAP8 (Two traps)", c='tab:blue')
ax.scatter(experiment_temperature, experiment_flux, label="Experiment", color="black")

# Set plot labels and limits
ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Deuterium flux (at/m$^2$/s)")
ax.legend(loc="best")
ax.set_xlim(left=min(tmap_temperature_desorption), right=max(tmap_temperature_desorption))
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

# Calculate and display the Root Mean Square Percentage Error (RMSPE) for both traps
tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_temperature, tmap_temperature_desorption, tmap_flux_desorption_total)

RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe - experiment_flux) ** 2))
RMSPE = RMSE * 100 / np.mean(experiment_flux)
ax.text(750, 6e16, 'RMSPE = %.2f ' % RMSPE + '%', fontweight='bold')

# Add damage annotation
ax.text(750, 5.5e16, 'Damage = 0.1 dpa')

ax.minorticks_on()

plt.savefig('val-2f_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ===============================================================================
# Plot trapped deuterium over time from desorption start

# Extract and adjust time array for desorption period
tmap_time_desorption = tmap_time_desorption - start_time_desorption
tmap_time_in_hours_desorption = tmap_time_desorption / 3600
time_intervals = np.diff(tmap_time_desorption) # Calculate time intervals between measurements

tmap_escaping_deuterium_desorption = np.zeros_like(tmap_flux_desorption_total)

# Using trapezoidal method for integration
for i in range(1, len(tmap_flux_desorption_total)):
    average_flux = (tmap_flux_desorption_total[i-1] + tmap_flux_desorption_total[i]) / 2
    tmap_escaping_deuterium_desorption[i] = tmap_escaping_deuterium_desorption[i-1] + average_flux * time_intervals[i-1]

# Calculate the combined deuterium desorption (mobile + escaping + trapped)
tmap_combined_deuterium_desorption = tmap_mobile_deuterium_desorption + tmap_escaping_deuterium_desorption + tmap_trapped_deuterium_desorption

# Store the initial mobile deuterium value
initial_deuterium = tmap_mobile_deuterium_desorption[0] + tmap_trapped_deuterium_desorption[0]

# Plotting the results
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])

# Fill the areas under the blue and green curves accurately
ax1.fill_between(tmap_time_in_hours_desorption, 0, tmap_trapped_deuterium_1_desorption, color='tab:cyan', alpha=0.3)
ax1.fill_between(tmap_time_in_hours_desorption, tmap_trapped_deuterium_1_desorption, tmap_trapped_deuterium_1_desorption + tmap_trapped_deuterium_2_desorption, color='tab:purple', alpha=0.3)

# Plot the lines
line1, = ax1.plot(tmap_time_in_hours_desorption, tmap_combined_deuterium_desorption, c='tab:green', linestyle='-', label='Total')
line2 = ax1.axhline(initial_deuterium, color='tab:red', linestyle=':', label='Initial mobile and trapped  deuterium')
line3, = ax1.plot(tmap_time_in_hours_desorption, tmap_mobile_deuterium_desorption + tmap_trapped_deuterium_desorption, label='Mobile + Trapped', c='tab:blue')
line4, = ax1.plot(tmap_time_in_hours_desorption, tmap_mobile_deuterium_desorption + tmap_trapped_deuterium_1_desorption, label='Trap 1', c='tab:cyan')
line5, = ax1.plot(tmap_time_in_hours_desorption, tmap_trapped_deuterium_1_desorption + tmap_trapped_deuterium_2_desorption, label='Trap 1 + Trap 2', c='tab:purple')

# Set plot labels and limits
ax1.set_xlabel(u'Time (hours)')
ax1.set_ylabel(u'Deuterium amount (atoms)')
ax1.set_ylim(bottom=0)
ax1.set_xlim(left=0, right=max(tmap_time_in_hours_desorption))
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

# Create a second y-axis for temperature
ax2 = ax1.twinx()
line6, = ax2.plot(tmap_time_in_hours_desorption, tmap_temperature_desorption, label='Temperature', c='tab:orange', linestyle='-')
ax2.set_ylabel(u'Temperature (K)')
ax2.set_ylim(bottom=min(tmap_temperature_desorption), top=max(tmap_temperature_desorption))

# Create custom legend with colored boxes instead of lines
trap1_patch = Patch(color='tab:cyan', alpha=0.3, label='Trap 1')
trap1_2_patch = Patch(color='tab:purple', alpha=0.3, label='Trap 1 + Trap 2')
total_deuterium_line = plt.Line2D([0], [0], color='tab:green', linestyle=':', label='Total')
initial_deuterium_line = plt.Line2D([0], [0], color='tab:red', linestyle=':', label='Initial mobile and trapped deuterium')
mobile_trapped_deuterium = plt.Line2D([0], [0], color='tab:blue', label='Mobile + Trapped deuterium')
temperature_line = plt.Line2D([0], [0], color='tab:orange', label='Temperature')

# Add legend to the plot
lines = [temperature_line, total_deuterium_line, initial_deuterium_line, mobile_trapped_deuterium, trap1_2_patch, trap1_patch]
labels = [line.get_label() for line in lines]
fig.legend(lines, labels, bbox_to_anchor=(0.9, 0.35), fontsize=8, frameon=True, framealpha=0.9)

# Calculate and display the Root Mean Square Percentage Error (RMSPE)
RMSE = np.sqrt(np.mean((tmap_combined_deuterium_desorption - initial_deuterium) ** 2))
RMSPE = RMSE * 100 / initial_deuterium
ax1.text(0.40, 0.90, f'RMSPE = {RMSPE:.2f} %', transform=ax1.transAxes, fontsize=12, fontweight='bold', verticalalignment='top')

plt.savefig('val-2f_deuterium_desorption.png', bbox_inches='tight', dpi=300)
plt.close(fig)
