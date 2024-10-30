import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract columns for time, pressures, concentration_enclosure_1_at_interface, and concentration_enclosure_2_at_interface
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1kb/gold/ver-1kb_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1kb_out.csv"
expt_data = pd.read_csv(csv_folder)
TMAP8_time = expt_data['time']
TMAP8_pressure_enclosure_1 = expt_data['pressure_enclosure_1']
TMAP8_pressure_enclosure_2 = expt_data['pressure_enclosure_2']
concentration_enclosure_1_at_interface = expt_data['concentration_enclosure_1_at_interface']
pressure_enclosure_2_at_interface = expt_data['pressure_enclosure_2_at_interface']

# Create a figure with 3 subplots
fig = plt.figure(figsize=[12, 5.5])
gs = gridspec.GridSpec(1, 3, width_ratios=[1, 1, 1])

# Subplot 1: Time vs Pressure
ax1 = fig.add_subplot(gs[0])
ax1.plot(TMAP8_time/3600, TMAP8_pressure_enclosure_1, label=r"H2 Encl 1", c='tab:gray', linestyle='-')
ax1.plot(TMAP8_time/3600, TMAP8_pressure_enclosure_2, label=r"H2 Encl 2", c='black', linestyle='-')
ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax1.set_xlabel('Time (hr)')
ax1.set_ylabel('Pressure (Pa)')
ax1.set_xlim(0, 3)
ax1.set_ylim(bottom=0)
ax1.legend(loc="best")
ax1.grid(which='major', color='0.65', linestyle='--', alpha=0.3)

# Subplot 2: Pressure Encl 2 vs Concentration Encl 1 at interface
k = np.sum(concentration_enclosure_1_at_interface * pressure_enclosure_2_at_interface) / np.sum(pressure_enclosure_2_at_interface ** 2)
print(f"K (après ajustement d'échelle) : {k:.2e}")
line_fit = k * pressure_enclosure_2_at_interface[1:]
print(f'k = {k:.2e}')
ax2 = fig.add_subplot(gs[1])
ax2.plot(pressure_enclosure_2_at_interface[1:], concentration_enclosure_1_at_interface[1:], marker='o', linestyle='None', c='tab:blue')
ax2.plot(pressure_enclosure_2_at_interface[1:], line_fit, label=f'Fit: y = {k:.2e}x\n', c='tab:red', linestyle='--')
ax2.set_xlabel(r"Pressure Encl 2 at interface (Pa)")
ax2.set_ylabel(r"Concentration Encl 1 at interface (mol/m^3)")
ax2.legend(loc="best")
ax2.grid(which='major', color='0.65', linestyle='--', alpha=0.3)

# Subplot 3: Mass Conservation Sum Encl 1 and 2 vs Time
mass_conservation_sum_encl1_encl2 = expt_data['mass_conservation_sum_encl1_encl2'].values
ax3 = fig.add_subplot(gs[2])
ax3.plot(TMAP8_time/3600, mass_conservation_sum_encl1_encl2, '-', color='tab:blue')
ax3.set_xlabel('Time (hr)')
ax3.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m^3)")
ax3.legend(loc="best")
ax3.grid(which='major', color='0.65', linestyle='--', alpha=0.3)

# Save the figure
plt.tight_layout()
plt.savefig('ver-1kb_comparison_time.png', bbox_inches='tight')
plt.show()
