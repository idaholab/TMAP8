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
concentration_ratio = expt_data['concentration_ratio']

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
concentration_ratio_k10 = expt_data_k10['concentration_ratio']

# Subplot 1: Pressure vs time
fig1 = plt.figure(figsize=[6, 5.5])
ax1 = fig1.add_subplot(111)
ax1.plot(TMAP8_time / 3600, TMAP8_pressure_enclosure_1, label=r"T$_2$ Enclosure 1", c='tab:red', linestyle='-')
ax1.plot(TMAP8_time / 3600, TMAP8_pressure_enclosure_2, label=r"T$_2$ Enclosure 2", c='tab:blue', linestyle='-')
ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax1.set_xlabel('Time (hr)')
ax1.set_ylabel('Pressure (Pa)')
ax1.set_xlim(0, 3)
ax1.set_ylim(bottom=0)
ax1.legend(loc="best")
ax1.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig1.savefig('ver-1kb_comparison_time.png', bbox_inches='tight', dpi=300)

# Subplot 2: Solubility and concentration ratios vs time
fig4 = plt.figure(figsize=[6, 5.5])
ax4 = fig4.add_subplot(111)
ax4.plot(TMAP8_time[1:] / 3600, concentration_ratio[1:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax4.plot(TMAP8_time[1:] / 3600, [1] * len(TMAP8_time[1:]), label=r"Solubility Ratio (Analytical)", color='tab:red', linestyle='--')
ax4.set_yticks(np.arange(0, 3, 1))
ax4.set_xlim(0,TMAP8_time.max() / 3600)
ax4.set_xlabel('Time (hr)')
ax4.set_ylabel(r"Concentrations ratio $C_{\text{encl1}} / C_{\text{encl2}}$")
ax4.legend(loc="best")
ax4.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig4.savefig('ver-1kb_concentration_ratio.png', bbox_inches='tight', dpi=300)

# Subplot 3: Mass Conservation Sum Encl 1 and 2 vs Time
fig3 = plt.figure(figsize=[6, 5.5])
ax3 = fig3.add_subplot(111)
ax3.plot(TMAP8_time / 3600, mass_conservation_sum_encl1_encl2, c='tab:blue')
ax3.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.3e}'.format(val)))
ax3.set_xlabel('Time (hr)')
ax3.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m$^3$)")
ax3.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig3.savefig('ver-1kb_mass_conservation.png', bbox_inches='tight', dpi=300)

# Repeat the same for K=10/RT
# Subplot 1 : Pressure vs time
fig1_k10 = plt.figure(figsize=[6, 5.5])
ax1_k10 = fig1_k10.add_subplot(111)
ax1_k10.plot(TMAP8_time_k10 / 3600, TMAP8_pressure_enclosure_1_k10, label=r"T$_2$ Enclosure 1", c='tab:red', linestyle='-')
ax1_k10.plot(TMAP8_time_k10 / 3600, TMAP8_pressure_enclosure_2_k10, label=r"T$_2$ Enclosure 2", c='tab:blue', linestyle='-')
ax1_k10.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax1_k10.set_xlabel('Time (hr)')
ax1_k10.set_ylabel('Pressure (Pa)')
ax1_k10.set_xlim(0, 3)
ax1_k10.set_ylim(bottom=0)
ax1_k10.legend(loc="best")
ax1_k10.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig1_k10.savefig('ver-1kb_comparison_time_k10.png', bbox_inches='tight', dpi=300)

# Subplot 2: Solubility and concentration ratios vs time
fig4_k10 = plt.figure(figsize=[6, 5.5])
ax4_k10 = fig4_k10.add_subplot(111)
ax4_k10.plot(TMAP8_time[1:] / 3600, concentration_ratio_k10[1:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax4_k10.plot(TMAP8_time[1:] / 3600, [10] * len(TMAP8_time[1:]), label=r"Solubility Ratio (Analytical)", color='tab:red', linestyle='--')
ax4_k10.set_yticks(np.arange(0, 21, 10))
ax4_k10.set_xlim(0,TMAP8_time.max() / 3600)
ax4_k10.set_xlabel('Time (hr)')
ax4_k10.set_ylabel(r"Concentrations ratio $C_{\text{encl1}} / C_{\text{encl2}}$")
ax4_k10.legend(loc="best")
ax4_k10.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig4_k10.savefig('ver-1kb_concentration_ratio_k10.png', bbox_inches='tight', dpi=300)

# Subplot 3 : Mass Conservation Sum Encl 1 and 2 vs Time
fig3_k10 = plt.figure(figsize=[6, 5.5])
ax3_k10 = fig3_k10.add_subplot(111)
ax3_k10.plot(TMAP8_time_k10 / 3600, mass_conservation_sum_encl1_encl2_k10, c='tab:blue')
ax3.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.3e}'.format(val)))
ax3_k10.set_xlabel('Time (hr)')
ax3_k10.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m$^3$)")
ax3_k10.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig3_k10.savefig('ver-1kb_mass_conservation_k10.png', bbox_inches='tight', dpi=300)

