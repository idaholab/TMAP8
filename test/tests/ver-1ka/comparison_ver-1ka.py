import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Constants
S = 1e20 # Source term (m^-3 * s^-1)
V = 1 # Volume (m^3)
kb = 1.380649e-23 # Boltzmann constant (J/K)
T = 500 # Temperature (K)

# Extract time and pressure data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1ka/gold/ver-1ka_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1ka_out.csv"
expt_data = pd.read_csv(csv_folder)
TMAP8_time = expt_data['time']
TMAP8_pressure = expt_data['pressure']

# Calculate the theoretical expression for pressure
analytical_pressure = (S / V) * kb * T * TMAP8_time

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Plot the experimental data
ax.plot(TMAP8_time/3600, TMAP8_pressure, label=r"TMAP8", c='tab:gray',linestyle='-')

# Plot the selected theoretical data
ax.plot(TMAP8_time/3600, analytical_pressure, label=r"Analytical",c='k', linestyle='--')

RMSE_pressure = np.linalg.norm(TMAP8_pressure-analytical_pressure)
err_percent_pressure = RMSE_pressure*100/np.mean(analytical_pressure)

# Add text annotation for RMSPE on the plot
ax.text(0.05, 0.95, '$P_{T_2}$ RMSPE = %.2f ' % err_percent_pressure + '%', fontweight='bold')

# Format the y-axis to use scientific notation
plt.gca().yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))

# Label the axes
ax.set_xlabel('Time (hr)')
ax.set_ylabel('Pressure (Pa)')

# define axis range
ax.set_xlim(left=0)
ax.set_xlim(right=3)
ax.set_ylim(bottom=0)

# Add a legend
ax.legend(loc="best")

# Add a grid
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)

# Save the plot as a PNG file
plt.savefig('ver-1ka_comparison_time.png', bbox_inches='tight', dpi=300)
