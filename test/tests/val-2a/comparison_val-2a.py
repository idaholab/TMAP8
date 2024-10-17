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
length = 5e-4 # m
radius =  2.5e-2 / 2 # m
area = np.pi * radius ** 2 # m^2
Temperature = 703 # K

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
    csv_folder = "../../../../test/tests/val-2a/gold/val-2a_TMAP7_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2a_TMAP7_out.csv"
simulation_TMAP7_data = pd.read_csv(csv_folder)
simulation_time_TMAP7 = simulation_TMAP7_data['time']
simulation_flux_left_TMAP7 = simulation_TMAP7_data['scaled_flux_surface_left']
simulation_flux_right_TMAP7 = simulation_TMAP7_data['scaled_flux_surface_right']

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2a/gold/val-2a_TMAP4_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2a_TMAP4_out.csv"
simulation_TMAP4_data = pd.read_csv(csv_folder)
simulation_time_TMAP4 = simulation_TMAP4_data['time']
simulation_flux_left_TMAP4 = simulation_TMAP4_data['scaled_flux_surface_left']
simulation_flux_right_TMAP4 = simulation_TMAP4_data['scaled_flux_surface_right']

# Read experiment data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2a/gold/experiment_data_TMAP7.csv"
else:                                  # if in test folder
    csv_folder = "./gold/experiment_data_TMAP7.csv"
experiment_TMAP7_data = pd.read_csv(csv_folder)
experiment_time_TMAP7 = experiment_TMAP7_data['x']
experiment_flux_TMAP7 = experiment_TMAP7_data[' y']

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2a/gold/experiment_data_TMAP4.csv"
else:                                  # if in test folder
    csv_folder = "./gold/experiment_data_TMAP4.csv"
experiment_TMAP4_data = pd.read_csv(csv_folder)
experiment_time_TMAP4 = experiment_TMAP4_data['x']
experiment_flux_TMAP4 = experiment_TMAP4_data[' y']


TMAP7_file_base = 'val-2a_comparison_TMAP7'
TMAP4_file_base = 'val-2a_comparison_TMAP4'
############################ TMAP7 atom/m$^2$/s ############################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(simulation_time_TMAP7/1000, simulation_flux_right_TMAP7, linestyle='-', label=r"right", c='tab:brown')
ax.plot(experiment_time_TMAP7/1000, experiment_flux_TMAP7, linestyle='--', label=r"experiment", c='k')

ax.set_xlabel(u'time (1000s)')
ax.set_ylabel(u"Deuterium flux (atom/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
# ax.set_yscale("log")
ax.set_xlim(left=-0.1,right=2e1)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
ax.ticklabel_format(axis='y', style='sci', scilimits=(15,15))
plt.savefig(f'{TMAP7_file_base}.png', bbox_inches='tight')
plt.close(fig)

############################ TMAP4 atom/m$^2$/s ############################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(simulation_time_TMAP4/1000, simulation_flux_right_TMAP4, linestyle='-', label=r"right", c='tab:brown')
ax.plot(experiment_time_TMAP4/1000, experiment_flux_TMAP4, linestyle='--', label=r"experiment", c='k')

ax.set_xlabel(u'time (1000s)')
ax.set_ylabel(u"Deuterium flux (atom/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
# ax.set_yscale("log")
ax.set_xlim(left=-0.1,right=2e1)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
ax.ticklabel_format(axis='y', style='sci', scilimits=(15,15))
plt.savefig(f'{TMAP4_file_base}.png', bbox_inches='tight')
plt.close(fig)
