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
# Constants and history (see input file val-2b.i)

temperature_desorption_min = 300 # K
temperature_desorption_max = 1073 # K
desorption_heating_rate = 3/60 # K/minutes -> K/s
charge_time = 50*60*60 # h -> s
# TMAP4 and TMAP7 used 40 minutes for the cooldown duration,
# We use a 5 hour cooldown period to let the temperature decrease to around 300 K for the start of the desorption.
# R.G. Macaulay-Newcombe et al. (1991) is not very clear on how long samples cooled down.
cooldown_duration = 5*60*60 # h -> s
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

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2b/gold/val-2b_heavy_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2b_heavy_out.csv"

tmap_solution = pd.read_csv(csv_folder)
tmap_time = tmap_solution['time'] # s
tmap_temperature = tmap_solution['temperature'] # K
tmap_pressure = tmap_solution['enclosure_pressure'] # Pa
tmap_flux = tmap_solution['avg_flux_total']*1e12 # atoms/microns^2/s -> atoms/m^2/s
tmap_solubility_ratio = tmap_solution['gold_solubility_ratio'] # (/)
tmap_concentration_ratio = tmap_solution['variable_ratio'] # (/)

# select only the simulation data for desorption
tmap_time_desorption = []
tmap_temperature_desorption = []
tmap_flux_desorption = []
for i in range(len(tmap_time)):
    if tmap_time[i]>=start_time_desorption:
        tmap_time_desorption.append(tmap_time[i])
        tmap_temperature_desorption.append(tmap_temperature[i])
        tmap_flux_desorption.append(tmap_flux[i])
tmap_time_desorption = np.array(tmap_time_desorption)
tmap_temperature_desorption = np.array(tmap_temperature_desorption)
tmap_flux_desorption = np.array(tmap_flux_desorption)

#===============================================================================
# Extract experimental data

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2b/gold/experimental_data.csv"
else:                                  # if in test folder
    csv_folder = "./gold/experimental_data.csv"
experiment_data = pd.read_csv(csv_folder)
experiment_temperature = experiment_data['temperature (C)'] + 273.15 # conversion from C to Kelvin
experiment_flux = experiment_data['flux (atoms/mm^2/s x 10^10)'] * 1e10 * 1e6 # conversion from (atoms/mm^2/s x 10^10) to (atom/m$^2$/s)

#===============================================================================
# Plot temperature and pressure history

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax2 = ax.twinx()

ax2.plot(tmap_time/60/60, tmap_pressure, label=r"Pressure", c='r')
ax.plot(tmap_time/60/60, tmap_temperature, label=r"Temperature", c='b',ls='--')

ax.set_xlabel(u'Time (h)')
ax.set_ylabel(u"Temperature (K)", c='b')
ax.legend(loc="lower left")
ax.set_ylim(bottom=0)
ax.set_xlim(left=0, right=endtime/60/60)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

ax2.set_ylabel(u"Pressure (Pa)", c='r')
ax2.legend(loc="lower center")
ax2.set_xlim(left=0)
ax2.set_yscale('log')
ax2.minorticks_on()

plt.savefig('val-2b_temperature_pressure_history.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Plot comparison between TMAP8 predictions and experimental data

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.scatter(experiment_temperature, experiment_flux,label=r"Experiment", c='k', marker='^')
ax.plot(tmap_temperature_desorption, tmap_flux_desorption, label=r"TMAP8", c='tab:gray')

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Deuterium flux (atom/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_temperature, tmap_temperature_desorption, tmap_flux_desorption)
RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_flux)**2) )
RMSPE = RMSE*100/np.mean(experiment_flux)
ax.text(870,3e16, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('val-2b_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Plot solubility ratio and concentration ratio to ensure the jump is properly enforced

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap_time/60/60, tmap_solubility_ratio, label=r"Solubility", c='k')
ax.plot(tmap_time/60/60, tmap_concentration_ratio, label=r"Concentration", c='tab:gray', ls=':')
ax.set_xlabel(u'Time (h)')
ax.set_ylabel(u"Ratio (-)")
ax.set_xlim(left=0, right=endtime/60/60)
ax.set_yscale('log')
ax.legend(loc="best")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('val-2b_ratio.png', bbox_inches='tight', dpi=300)
plt.close(fig)
