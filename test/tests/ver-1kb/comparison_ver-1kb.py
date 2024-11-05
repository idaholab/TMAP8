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
    csv_folder = "../../../../test/tests/ver-1kb/gold/ver-1kb_out_k1.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1kb_out_k1.csv"
expt_data = pd.read_csv(csv_folder)
TMAP8_time = expt_data['time']
TMAP8_pressure_enclosure_1 = expt_data['pressure_enclosure_1']
TMAP8_pressure_enclosure_2 = expt_data['pressure_enclosure_2']
concentration_enclosure_1_at_interface = expt_data['concentration_enclosure_1_at_interface']
pressure_enclosure_2_at_interface = expt_data['pressure_enclosure_2_at_interface']
mass_conservation_sum_encl1_encl2 = expt_data['mass_conservation_sum_encl1_encl2'].values

# Repeat the same for K=10/RT
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder_k10 = "../../../../test/tests/ver-1kb/gold/ver-1kb_out_k10.csv"
else:                                  # if in test folder
    csv_folder_k10 = "./gold/ver-1kb_out_k10.csv"
expt_data_k10 = pd.read_csv(csv_folder_k10)
TMAP8_time_k10 = expt_data_k10['time']
TMAP8_pressure_enclosure_1_k10 = expt_data_k10['pressure_enclosure_1']
TMAP8_pressure_enclosure_2_k10 = expt_data_k10['pressure_enclosure_2']
concentration_enclosure_1_at_interface_k10 = expt_data_k10['concentration_enclosure_1_at_interface']
pressure_enclosure_2_at_interface_k10 = expt_data_k10['pressure_enclosure_2_at_interface']
mass_conservation_sum_encl1_encl2_k10 = expt_data_k10['mass_conservation_sum_encl1_encl2'].values

# Subplot 1: Time vs Pressure
fig1 = plt.figure(figsize=[6, 5.5])
ax1 = fig1.add_subplot(111)
ax1.plot(TMAP8_time / 3600, TMAP8_pressure_enclosure_1, label=r"H2 Encl 1", c='tab:red', linestyle='dotted')
ax1.plot(TMAP8_time / 3600, TMAP8_pressure_enclosure_2, label=r"H2 Encl 2", c='tab:blue', linestyle='dotted')
ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax1.set_xlabel('Time (hr)')
ax1.set_ylabel('Pressure (Pa)')
ax1.set_xlim(0, 3)
ax1.set_ylim(bottom=0)
ax1.legend(loc="best")
ax1.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig1.savefig('ver-1kb_comparison_time.png', bbox_inches='tight')

# Subplot 2: Pressure Encl 2 vs Concentration Encl 1 at interface
k = np.sum(concentration_enclosure_1_at_interface * pressure_enclosure_2_at_interface) / np.sum(pressure_enclosure_2_at_interface ** 2)
line_fit = k * pressure_enclosure_2_at_interface[1:]
fig2 = plt.figure(figsize=[6, 5.5])
ax2 = fig2.add_subplot(111)
ax2.plot(pressure_enclosure_2_at_interface[1:], concentration_enclosure_1_at_interface[1:], marker='o', linestyle='None', c='tab:blue')
ax2.plot(pressure_enclosure_2_at_interface[1:], line_fit, label=f'Fit: y = {k:.2e}x\n', c='tab:red', linestyle='--')
ax2.set_xlabel(r"Pressure Encl 2 at interface (Pa)")
ax2.set_ylabel(r"Concentration Encl 1 at interface (mol/m^3)")
ax2.legend(loc="best")
ax2.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig2.savefig('ver-1kb_comparison_concentration.png', bbox_inches='tight')

# Subplot 3: Mass Conservation Sum Encl 1 and 2 vs Time
fig3 = plt.figure(figsize=[6, 5.5])
ax3 = fig3.add_subplot(111)
ax3.plot(TMAP8_time / 3600, mass_conservation_sum_encl1_encl2, 'o', color='tab:blue', markersize=0.7)
ax3.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.3e}'.format(val)))
ax3.set_xlabel('Time (hr)')
ax3.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m^3)")
ax3.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig3.savefig('ver-1kb_mass_conservation.png', bbox_inches='tight')

# Repeat the same for K=10/RT
# Subplot 1 : Time vs Pressure
fig1_k10 = plt.figure(figsize=[6, 5.5])
ax1_k10 = fig1_k10.add_subplot(111)
ax1_k10.plot(TMAP8_time_k10 / 3600, TMAP8_pressure_enclosure_1_k10, label=r"H2 Encl 1", c='tab:red', linestyle='-')
ax1_k10.plot(TMAP8_time_k10 / 3600, TMAP8_pressure_enclosure_2_k10, label=r"H2 Encl 2", c='tab:blue', linestyle='-')
ax1_k10.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax1_k10.set_xlabel('Time (hr)')
ax1_k10.set_ylabel('Pressure (Pa)')
ax1_k10.set_xlim(0, 3)
ax1_k10.set_ylim(bottom=0)
ax1_k10.legend(loc="best")
ax1_k10.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig1_k10.savefig('ver-1kb_comparison_time_k10.png', bbox_inches='tight')

# Subplot 2 : Pressure Encl 2 vs Concentration Encl 1 at interface
k_k10 = np.sum(concentration_enclosure_1_at_interface_k10 * pressure_enclosure_2_at_interface_k10) / np.sum(pressure_enclosure_2_at_interface_k10 ** 2)
line_fit_k10 = k_k10 * pressure_enclosure_2_at_interface_k10[1:]
fig2_k10 = plt.figure(figsize=[6, 5.5])
ax2_k10 = fig2_k10.add_subplot(111)
ax2_k10.plot(pressure_enclosure_2_at_interface_k10[1:], concentration_enclosure_1_at_interface_k10[1:], marker='o', linestyle='None', c='tab:blue')
ax2_k10.plot(pressure_enclosure_2_at_interface_k10[1:], line_fit_k10, label=f'Fit: y = {k_k10:.2e}x\n', c='tab:red', linestyle='--')
ax2_k10.set_xlabel(r"Pressure Encl 2 at interface (Pa)")
ax2_k10.set_ylabel(r"Concentration Encl 1 at interface (mol/m^3)")
ax2_k10.legend(loc="best")
ax2_k10.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig2_k10.savefig('ver-1kb_comparison_concentration_k10.png', bbox_inches='tight')

# Subplot 3 : Mass Conservation Sum Encl 1 and 2 vs Time
fig3_k10 = plt.figure(figsize=[6, 5.5])
ax3_k10 = fig3_k10.add_subplot(111)
ax3_k10.plot(TMAP8_time_k10 / 3600, mass_conservation_sum_encl1_encl2_k10, 'o', color='tab:blue', markersize=0.7)
ax3.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.3e}'.format(val)))
ax3_k10.set_xlabel('Time (hr)')
ax3_k10.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m^3)")
ax3_k10.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig3_k10.savefig('ver-1kb_mass_conservation_k10.png', bbox_inches='tight')

