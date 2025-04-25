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
    csv_folder = "../../../../test/tests/val-2f/gold/val-2f_heavy_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2f_heavy_out.csv"

tmap_solution = pd.read_csv(csv_folder)
tmap_time = tmap_solution['time'] # s
tmap_temperature = tmap_solution['temperature'] # K
tmap_flux_left = tmap_solution['scaled_flux_surface_left'] # atoms/m^2/s
tmap_flux_right = tmap_solution['scaled_flux_surface_right'] # atoms/m^2/s
tmap_flux_total = tmap_flux_left+tmap_flux_right # atoms/m^2/s
# select only the simulation data for desorption
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
        tmap_flux_desorption_total.append(tmap_flux_total[i])
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
experiment_data = pd.read_csv(csv_folder)
tds_data = np.genfromtxt(csv_folder, delimiter=",")
experiment_temperature = tds_data[:, 0]
area = 12e-03 * 15e-03
experiment_flux = tds_data[:, 1] / area

#===============================================================================
# Plot implantation distribution

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

sigma = 0.5e-9 # m
R_p = 0.7e-9 # m
flux = 5.79e19 # at/m^2/s
x = np.linspace(0, 6*sigma, 1000)
implantation_distribution = 1 / (sigma * (2 * np.pi) ** 0.5) * np.exp(-0.5 * ((x - R_p) / sigma) ** 2)
source_deuterium = flux * implantation_distribution

ax.axvline(R_p + 5*sigma, color='r', linestyle='--', label=r'$R_p + 5\sigma$')

ax.plot(x, source_deuterium, label=r"Implantation distribution", c='b')

ax.set_xlabel(u'x (m)')
ax.set_ylabel(u"Deuterium source (at/m/s)")
ax.legend(loc="lower left")
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

plt.savefig('val-2f_implantation_distribution.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Plot temperature and pressure history

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_time/60/60, tmap_temperature, label=r"Temperature", c='b',ls='--')

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

ax.plot (tmap_temperature_desorption, tmap_flux_desorption_total, label=r"TMAP8", c='tab:gray')
ax.scatter(experiment_temperature, experiment_flux, label="Experiment", color="black")
ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Deuterium flux (atom/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_temperature, tmap_temperature_desorption, tmap_flux_desorption_total)
RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_flux)**2) )
RMSPE = RMSE*100/np.mean(experiment_flux)
ax.text(800,6e16, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('val-2f_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)
