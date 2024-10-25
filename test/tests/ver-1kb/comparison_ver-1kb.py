import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract time and pressure data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1kb/gold/ver-1kb_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1kb_out.csv"
expt_data = pd.read_csv(csv_folder)
TMAP8_time = expt_data['time']
TMAP8_pressure_enclosure_1 = expt_data['pressure_enclosure_1']
TMAP8_pressure_enclosure_2 = expt_data['pressure_enclosure_2']

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# Plot the experimental data
ax.plot(TMAP8_time/3600, TMAP8_pressure_enclosure_1, label=r"H2 Encl 1", c='tab:gray',linestyle='-')

# Plot the selected theoretical data
ax.plot(TMAP8_time/3600, TMAP8_pressure_enclosure_2, label=r"H2 Encl 2",c='k', linestyle='--')

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
plt.savefig('ver-1kb_comparison_time.png', bbox_inches='tight')
