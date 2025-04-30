import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
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

# Read TMAP8 solution from CSV file
tmap_solution = pd.read_csv(csv_folder)
tmap_time = tmap_solution['time'] # s
tmap_temperature = tmap_solution['temperature'] # K
tmap_flux_left = tmap_solution['scaled_flux_surface_left'] # atoms/s
tmap_flux_right = tmap_solution['scaled_flux_surface_right'] # atoms/s
tmap_escaping_deuterium = tmap_flux_left + tmap_flux_right # atoms/s
tmap_implanted_deuterium = tmap_solution['scaled_implanted_deuterium'] # atoms/s
tmap_mobile_deuterium = tmap_solution['scaled_mobile_deuterium'] # atoms

# Select only the simulation data for desorption period
tmap_time_desorption = []
tmap_temperature_desorption = []
tmap_flux_desorption_left = []
tmap_flux_desorption_right = []
tmap_flux_desorption_total = []
for i in range(len(tmap_time)):
    if tmap_time[i]>=start_time_desorption:
        tmap_time_desorption.append(tmap_time[i])
        tmap_temperature_desorption.append(tmap_temperature[i])
        tmap_flux_desorption_left.append(tmap_flux_left[i])
        tmap_flux_desorption_right.append(tmap_flux_right[i])
        tmap_flux_desorption_total.append(tmap_escaping_deuterium[i])
tmap_time_desorption = np.array(tmap_time_desorption)
tmap_temperature_desorption = np.array(tmap_temperature_desorption)
tmap_flux_desorption_left = np.array(tmap_flux_desorption_left)
tmap_flux_desorption_right = np.array(tmap_flux_desorption_right)
tmap_flux_desorption_total = np.array(tmap_flux_desorption_total)

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
ax.axvline(R_p + 5*sigma, color='r', linestyle='--', label=r'$R_p + 5\sigma$')
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
ax.plot(tmap_time/60/60, tmap_temperature, label=r"Temperature", c='b',ls='--')

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

# #===============================================================================
# Plot comparison between TMAP8 predictions and experimental data

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Plot TMAP8 predictions and experimental data
ax.plot (tmap_temperature_desorption, tmap_flux_desorption_total, label=r"TMAP8", c='tab:gray')
ax.scatter(experiment_temperature, experiment_flux, label="Experiment", color="black")

# Set plot labels and limits
ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Deuterium flux (at/m$^2$/s)")
ax.legend(loc="best")
ax.set_xlim(left=tmap_temperature_desorption[0], right=tmap_temperature_desorption[-1])
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

# Calculate and display the Root Mean Square Percentage Error (RMSPE)
tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_temperature, tmap_temperature_desorption, tmap_flux_desorption_total)
RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_flux)**2) )
RMSPE = RMSE*100/np.mean(experiment_flux)
ax.text(750,6e16, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()

plt.savefig('val-2f_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# #===============================================================================
# Plot the mobile deuterium and escaping deuterium starting from desorption start

# Determine the start index for desorption based on the start time
desorption_start_index = np.argmax(tmap_time >= start_time_desorption)

# Extract and adjust time array for desorption period
tmap_time_desorption = tmap_time[desorption_start_index:] - start_time_desorption
tmap_time_in_hours_desorption = tmap_time_desorption / 3600
time_intervals = np.diff(tmap_time_desorption) # Calculate time intervals between measurements

# Extract mobile deuterium values starting from the desorption start time
tmap_mobile_deuterium_desorption = tmap_mobile_deuterium[desorption_start_index:]

tmap_escaping_deuterium_desorption = np.zeros_like(tmap_flux_desorption_total)

# Using trapezoidal method for integration
for i in range(1, len(tmap_flux_desorption_total)):
    average_flux = (tmap_flux_desorption_total[i-1] + tmap_flux_desorption_total[i]) / 2
    tmap_escaping_deuterium_desorption[i] = tmap_escaping_deuterium_desorption[i-1] + average_flux * time_intervals[i-1]

# Calculate the combined deuterium desorption (mobile + escaping)
tmap_combined_deuterium_desorption = tmap_mobile_deuterium_desorption + tmap_escaping_deuterium_desorption

# Store the initial mobile deuterium value
initial_mobile_deuterium = tmap_mobile_deuterium[desorption_start_index]

# Plotting the results
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax1 = fig.add_subplot(gs[0])

# Fill the areas under the blue and green curves accurately
ax1.fill_between(tmap_time_in_hours_desorption, 0, tmap_mobile_deuterium_desorption, color='tab:blue', alpha=0.3)
ax1.fill_between(tmap_time_in_hours_desorption,tmap_mobile_deuterium_desorption,tmap_combined_deuterium_desorption, color='tab:green', alpha=0.3)

# Plot the lines
line1, = ax1.plot(tmap_time_in_hours_desorption, tmap_mobile_deuterium_desorption, label='Mobile deuterium', c='tab:blue')
line2, = ax1.plot(tmap_time_in_hours_desorption, tmap_combined_deuterium_desorption, label='Mobile + Escaping deuterium', c='tab:green', linestyle='-')
line3 = ax1.axhline(initial_mobile_deuterium, color='tab:red', linestyle=':', label='Initial mobile deuterium')

# Set plot labels and limits
ax1.set_xlabel(u'Time (hours)')
ax1.set_ylabel(u'Deuterium amount (atoms)')
ax1.set_ylim(bottom=0)
ax1.set_xlim(left=0, right=max(tmap_time_in_hours_desorption))
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

# Create a second y-axis for temperature
ax2 = ax1.twinx()
line4, = ax2.plot(tmap_time_in_hours_desorption, tmap_temperature[desorption_start_index:], label='Temperature', c='tab:orange', linestyle='-')
ax2.set_ylabel(u'Temperature (K)')
ax2.set_ylim(bottom=min(tmap_temperature[desorption_start_index:]), top=max(tmap_temperature[desorption_start_index:]))

# Add legend to the plot
lines = [line1, line2, line3, line4]
labels = [line.get_label() for line in lines]
fig.legend(lines, labels, bbox_to_anchor=(0.88, 0.3), fontsize=9, frameon=True, framealpha=0.9)

# Calculate and display the Root Mean Square Percentage Error (RMSPE)
RMSE = np.sqrt(np.mean((tmap_combined_deuterium_desorption - initial_mobile_deuterium) ** 2))
RMSPE = RMSE * 100 / initial_mobile_deuterium
ax1.text(0.40, 0.90, f'RMSPE = {RMSPE:.2f} %', transform=ax1.transAxes, fontsize=12, fontweight='bold', verticalalignment='top')
plt.savefig('val-2f_deuterium_desorption.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# #===============================================================================
# Plot the evolution of deuterium atom quantities over time

tmap_time_in_hours = tmap_time / 3600

charge_time = 72  # hours
cooldown_time = 12  # hours
desorption_start = charge_time + cooldown_time

time_intervals = np.diff(tmap_time) # Calculate time intervals between measurements

tmap_escaping_deuterium_integral = np.zeros_like(tmap_escaping_deuterium)
tmap_implanted_deuterium_integral = np.zeros_like(tmap_implanted_deuterium)

# Using trapezoidal method for integration
for i in range(1, len(tmap_escaping_deuterium)):
    average_flux = (tmap_escaping_deuterium[i-1] + tmap_escaping_deuterium[i]) / 2
    tmap_escaping_deuterium_integral[i] = tmap_escaping_deuterium_integral[i-1] + average_flux * time_intervals[i-1]

# Using trapezoidal method for integration
for i in range(1, len(tmap_implanted_deuterium)):
    average_flux = (tmap_implanted_deuterium[i-1] + tmap_implanted_deuterium[i]) / 2
    tmap_implanted_deuterium_integral[i] = tmap_implanted_deuterium_integral[i-1] + average_flux * time_intervals[i-1]

# Compute the mass conservation metric as the difference
mass_conservation = tmap_implanted_deuterium_integral - tmap_escaping_deuterium_integral - tmap_mobile_deuterium

# Plot the mass conservation metric
fig, ax1 = plt.subplots(figsize=[6.5, 5.5])
# ax1.plot(tmap_time_in_hours, tmap_implanted_deuterium_integral, label='Implanted deuterium', c='tab:green', linestyle='-')
# ax1.plot(tmap_time_in_hours, tmap_escaping_deuterium_integral, label='Escaping deuterium', c='tab:blue', linestyle=':')
ax1.plot(tmap_time_in_hours, tmap_mobile_deuterium, label='Mobile deuterium', c='tab:red', linestyle='-')
ax1.plot(tmap_time_in_hours, mass_conservation, label='Mass conservation', c='tab:purple', linestyle=':')

# Set labels and limits for the y-axis
ax1.set_xlabel(u'Time (hours)')
ax1.set_ylabel(u'Mass Conservation Metric (atoms)')
ax1.set_xlim(left=0, right=max(tmap_time_in_hours))
ax1.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

# Highlight different phases with colored spans
charge_color = 'peachpuff'
cooldown_color = 'lightsteelblue'
desorption_color = 'lightgreen'

# Highlight the three phases (charge, cooldown, desorption)
ax1.axvspan(0, charge_time, alpha=0.3, color=charge_color)
ax1.axvspan(charge_time, desorption_start, alpha=0.3, color=cooldown_color)
ax1.axvspan(desorption_start, max(tmap_time_in_hours), alpha=0.3, color=desorption_color)

# Display the legend
ax1.legend(loc='upper right', fontsize=10)

# Calculate and display the Root Mean Square Percentage Error (RMSPE)
RMSE = np.sqrt(np.mean((tmap_implanted_deuterium - tmap_escaping_deuterium) ** 2))
RMSPE = RMSE * 100 / np.mean(tmap_implanted_deuterium)
ax1.text(0.40, 0.90, f'RMSPE = {RMSPE:.4f} %', transform=ax1.transAxes, fontsize=12, fontweight='bold', verticalalignment='top')

plt.savefig('mass_conservation_metric.png', bbox_inches='tight', dpi=300)
plt.close(fig)
