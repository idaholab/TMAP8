import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Necessary parameters
length = 1e-4 # m
initial_temperature = 300 # K
final_temperature = 1273 # K
flux_environment_max = 4.87e17 # atom/m^2/s
temperature_rate = 50/60 # K/s

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
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (tmap_input[right_limit] - tmap_input[left_limit]) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[left_limit]
    return new_tmap_output



# Read simulation data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2d/gold/val-2d_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2d_out.csv"
simulation_TMAP7_data = pd.read_csv(csv_folder)
simulation_time_TMAP7 = simulation_TMAP7_data['time']
simulation_flux_left_TMAP7 = simulation_TMAP7_data['scaled_flux_surface_left']

# build the environmental desorption flux
flux_environment = flux_environment_max / ((final_temperature - initial_temperature) / temperature_rate) * (simulation_time_TMAP7 - 5000)
flux_environment[flux_environment > flux_environment_max] = flux_environment_max
flux_environment[flux_environment < 0] = 0


# Read experiment data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2d/gold/experiment_data_paper.csv"
else:                                  # if in test folder
    csv_folder = "./gold/experiment_data_paper.csv"
experiment_data = pd.read_csv(csv_folder)
experiment_time = experiment_data['time (s)']
experiment_flux = experiment_data['flux (atom/m^2/s)']


file_base = 'val-2d_comparison'
############################ desorption flux atom/m$^2$/s ############################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(simulation_time_TMAP7, flux_environment + simulation_flux_left_TMAP7/2, linestyle='-', label=r"TMAP8", c='tab:brown')
ax.plot(simulation_time_TMAP7, flux_environment, linestyle='-', label=r"Environmental background", c='tab:orange')
ax.plot(experiment_time, experiment_flux, linestyle='--', label=r"Experimental measurement", c='k')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(u"Desorption flux (H$_2$/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0, top=1.8e18)
ax.set_xlim(left=5000,right=6800)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_time, simulation_time_TMAP7, simulation_flux_left_TMAP7/2 + flux_environment)
RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_flux)**2) )
RMSPE = RMSE*100/np.mean(experiment_flux)
ax.text(6000.0,0.85e18, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig(f'{file_base}.png', bbox_inches='tight')
plt.close(fig)
