import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Read TMAP8 simulation data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/val-2g_673_out.csv"
else:                                  # if in test folder
    csv_folder = "./val-2g_673_out.csv"
simulation_673_data = pd.read_csv(csv_folder)
simulation_time_673 = simulation_673_data['time']
simulation_flux_left_673 = simulation_673_data['scaled_flux_surface_left']

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/val-2g_873_out.csv"
else:                                  # if in test folder
    csv_folder = "./val-2g_873_out.csv"
simulation_873_data = pd.read_csv(csv_folder)
simulation_time_873 = simulation_873_data['time']
simulation_flux_left_873 = simulation_873_data['scaled_flux_surface_left']

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/val-2g_973_out.csv"
else:                                  # if in test folder
    csv_folder = "./val-2g_973_out.csv"
simulation_973_data = pd.read_csv(csv_folder)
simulation_time_973 = simulation_973_data['time']
simulation_flux_left_973 = simulation_973_data['scaled_flux_surface_left']

# Read TMAP4 simulation data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/tmap4_data.csv"
else:                                  # if in test folder
    csv_folder = "./tmap4_data.csv"
simulation_TMAP4_data = pd.read_csv(csv_folder)
simulation_time_TMAP4 = simulation_TMAP4_data['time (s)']
simulation_temperature_TMAP4 = simulation_TMAP4_data['temperature (K)']
simulation_flux_TMAP4_673 = simulation_TMAP4_data['TMAP - 400C (D m^-2 s^-1)']
simulation_flux_TMAP4_873 = simulation_TMAP4_data['TMAP - 600C (D m^-2 s^-1)']
simulation_flux_TMAP4_973 = simulation_TMAP4_data['TMAP - 700C (D m^-2 s^-1)']

# Read experiment data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/experimental_data.csv"
else:                                  # if in test folder
    csv_folder = "./experimental_data.csv"
experiment_data = pd.read_csv(csv_folder)
experiment_time = experiment_data['time (s)']
experiment_temperature = experiment_data['temperature (K)']
experiment_flux_673 = experiment_data['Exp - 400C (D m^-2 s^-1)']
experiment_flux_873 = experiment_data['Exp - 600C (D m^-2 s^-1)']
experiment_flux_973 = experiment_data['Exp - 700C (D m^-2 s^-1)']

# Setup mask using a random sampling method to reduce density of scatter plot points in experimental
# data (there is a lot of "noise").
# These preserve 10% of the data points. (adjusted within the 'size' parameter).
mask = np.random.choice(len(experiment_flux_673), size=int(len(experiment_flux_673) * 0.1), replace=False)


file_base = 'val-2g_comparison'
############################ desorption flux atom/m$^2$/s ############################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# TMAP8
ax.semilogy(simulation_time_673-12000, simulation_flux_left_673, linestyle='-', label=r"673 K", c='blue', linewidth=3.0)
ax.semilogy(simulation_time_873-12000, simulation_flux_left_873, linestyle='-', label=r"873 K", c='red', linewidth=3.0)
ax.semilogy(simulation_time_973-12000, simulation_flux_left_973, linestyle='-', label=r"973 K", c='green', linewidth=3.0)

# TMAP4
ax.semilogy(simulation_time_TMAP4, simulation_flux_TMAP4_673, linestyle='--', label=r"TMAP4 - 673 K", c='blue', linewidth=3.0, alpha=0.7)
ax.semilogy(simulation_time_TMAP4, simulation_flux_TMAP4_873, linestyle='--', label=r"TMAP4 - 873 K", c='red', linewidth=3.0, alpha=0.7)
ax.semilogy(simulation_time_TMAP4, simulation_flux_TMAP4_973, linestyle='--', label=r"TMAP4 - 973 K", c='green', linewidth=3.0, alpha=0.7)

# Experimental Data
s = (3.0)**2
ax.scatter(experiment_time[mask], experiment_flux_673[mask], marker='o', s=s, label=r"Exp - 673 K", c='blue')
ax.scatter(experiment_time[mask], experiment_flux_873[mask], marker='o', s=s, label=r"Exp - 873 K", c='red')
ax.scatter(experiment_time[mask], experiment_flux_973[mask], marker='o', s=s, label=r"Exp - 973 K", c='green')


# Font sizes for labels and axes
SMALL_SIZE = 10
MEDIUM_SIZE = 14
BIGGER_SIZE = 16

ax.set_xlabel(u'Time (s)', weight='bold', fontsize=BIGGER_SIZE)
ax.set_ylabel(u"Desorption flux (H$_2$/m$^2$/s)", weight='bold', fontsize=BIGGER_SIZE)
ax.legend(loc="upper left", fontsize=SMALL_SIZE)
ax.set_ylim(bottom=6e15, top=4.0e18)
ax.set_xlim(left=0,right=7200)
ax.xaxis.set_ticks(np.arange(0, 7205, 1800))
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
# tmap_flux_for_rmspe = numerical_solution_on_experiment_input(experiment_time, simulation_time_TMAP7, simulation_flux_left_TMAP7/2 + flux_environment)
# RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-experiment_flux)**2) )
# RMSPE = RMSE*100/np.mean(experiment_flux)
# ax.text(6000.0,0.85e18, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.tick_params(axis='both', which='both', direction='out', bottom=True, top=True, left=True,
               right=True, labelsize=MEDIUM_SIZE)
ax.grid(True, which='minor', color='0.9', linestyle='--')
ax.set_axisbelow(True) # Ensures that grid is drawn behind data. Without this, sometimes the grid is seen atop marker points.
plt.savefig(f'{file_base}.png', bbox_inches='tight', dpi=300)
plt.close(fig)
