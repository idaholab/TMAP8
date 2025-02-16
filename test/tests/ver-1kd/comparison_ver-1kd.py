import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Load experimental data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder_k10 = "../../../../test/tests/ver-1kd/gold/ver-1kd_out_k10.csv"
else:                                  # if in test folder
    csv_folder_k10 = "./gold/ver-1kd_out_k10.csv"
expt_data_k10 = pd.read_csv(csv_folder_k10)
TMAP8_time_k10 = expt_data_k10['time']
TMAP8_pressure_H2_enclosure_1_k10 = expt_data_k10['pressure_H2_enclosure_1']
TMAP8_pressure_H2_enclosure_2_k10 = expt_data_k10['pressure_H2_enclosure_2']
TMAP8_pressure_T2_enclosure_1_k10 = expt_data_k10['pressure_T2_enclosure_1']
TMAP8_pressure_T2_enclosure_2_k10 = expt_data_k10['pressure_T2_enclosure_2']
TMAP8_pressure_HT_enclosure_1_k10 = expt_data_k10['pressure_HT_enclosure_1']
TMAP8_pressure_HT_enclosure_2_k10 = expt_data_k10['pressure_HT_enclosure_2']
mass_conservation_sum_encl1_encl2_k10 = expt_data_k10['mass_conservation_sum_encl1_encl2']
concentration_ratio_H2_k10 = expt_data_k10['concentration_ratio_H2']
concentration_ratio_T2_k10 = expt_data_k10['concentration_ratio_T2']
concentration_ratio_HT_k10 = expt_data_k10['concentration_ratio_HT']
equilibrium_constant_encl_1 = expt_data_k10['equilibrium_constant_encl_1']
equilibrium_constant_encl_2 = expt_data_k10['equilibrium_constant_encl_2']


# Subplot 1 : Pressure vs time

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

# Plot for Enclosure 1
line1 = ax.plot(TMAP8_time_k10, TMAP8_pressure_H2_enclosure_1_k10, label=r"H$_2$ Enclosure 1", c='tab:red', linestyle='-')
line2 = ax.plot(TMAP8_time_k10, TMAP8_pressure_T2_enclosure_1_k10, label=r"T$_2$ Enclosure 1", c='tab:orange', linestyle='--')
line3 = ax.plot(TMAP8_time_k10, TMAP8_pressure_HT_enclosure_1_k10, label=r"HT Enclosure 1", c='tab:purple', linestyle='-')

ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax.set_xlabel('Time (s)')
ax.set_ylabel('Pressure Enclosure 1 (Pa)')
ax.set_ylim(bottom=0)
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)

# Plot for Enclosure 2
ax2 = ax.twinx()
line4 = ax2.plot(TMAP8_time_k10, TMAP8_pressure_H2_enclosure_2_k10, label=r"H$_2$ Enclosure 2", c='tab:blue', linestyle='-')
line5 = ax2.plot(TMAP8_time_k10, TMAP8_pressure_T2_enclosure_2_k10, label=r"T$_2$ Enclosure 2", c='tab:green', linestyle='--')
line6 = ax2.plot(TMAP8_time_k10, TMAP8_pressure_HT_enclosure_2_k10, label=r"HT Enclosure 2", c='tab:cyan', linestyle='-')

ax2.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax2.set_ylabel('Pressure Enclosure 2 (Pa)')
ax2.set_ylim(bottom=0)
ax.set_xlim(0,TMAP8_time_k10.max())

# Combine legends
lines_left  = line1 + line2 + line3
lines_right = line4 + line5 + line6
all_lines = lines_left + lines_right
all_labels = [l.get_label() for l in all_lines]

ax.legend(all_lines, all_labels, loc='upper left')
fig.savefig('ver-1kd_comparison_time_k10.png', bbox_inches='tight', dpi=300)

# Subplot 2: Solubility and concentration ratios vs time

## Subplot 2.1: for H2
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

solubility_ratio = [10] * len(TMAP8_time_k10[1:])
ax.plot(TMAP8_time_k10[1:], concentration_ratio_H2_k10[1:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time_k10[1:], solubility_ratio, label=r"Solubility Ratio (Analytical)", color='tab:red', linestyle='--')
ax.set_yticks(np.arange(0, 21, 10))
ax.set_xlim(0,TMAP8_time_k10.max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{encl1}} / \sqrt{C_{\text{encl2}}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((concentration_ratio_H2_k10[1:]-solubility_ratio)**2))
RMSPE = RMSE*100/np.mean(solubility_ratio)
x_pos = TMAP8_time_k10.max() / 7200
y_pos = 0.9 * ax.get_ylim()[1]
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('ver-1kd_concentration_ratio_H2_k10.png', bbox_inches='tight', dpi=300)

## Subplot 2.2: for T2
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

solubility_ratio = [10] * len(TMAP8_time_k10[1:])
ax.plot(TMAP8_time_k10[1:], concentration_ratio_T2_k10[1:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time_k10[1:], solubility_ratio, label=r"Solubility Ratio (Analytical)", color='tab:red', linestyle='--')
ax.set_yticks(np.arange(0, 21, 10))
ax.set_xlim(0,TMAP8_time_k10.max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{encl1}} / \sqrt{C_{\text{encl2}}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((concentration_ratio_T2_k10[1:]-solubility_ratio)**2))
RMSPE = RMSE*100/np.mean(solubility_ratio)
x_pos = TMAP8_time_k10.max() / 7200
y_pos = 0.9 * ax.get_ylim()[1]
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('ver-1kd_concentration_ratio_T2_k10.png', bbox_inches='tight', dpi=300)

## Subplot 2.3: for HT
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

solubility_ratio = [10] * len(TMAP8_time_k10[1:])
ax.plot(TMAP8_time_k10[1:], concentration_ratio_HT_k10[1:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time_k10[1:], solubility_ratio, label=r"Solubility Ratio (Analytical)", color='tab:red', linestyle='--')
ax.set_yticks(np.arange(0, 21, 10))
ax.set_xlim(0,TMAP8_time_k10.max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{encl1}} / \sqrt{C_{\text{encl2}}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((concentration_ratio_HT_k10[1:]-solubility_ratio)**2))
RMSPE = RMSE*100/np.mean(solubility_ratio)
x_pos = TMAP8_time_k10.max() / 7200
y_pos = 0.9 * ax.get_ylim()[1]
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('ver-1kd_concentration_ratio_HT_k10.png', bbox_inches='tight', dpi=300)


# Subplot 3 : Mass Conservation Sum Encl 1 and 2 vs Time

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(TMAP8_time_k10, mass_conservation_sum_encl1_encl2_k10, c='tab:blue')
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.3e}'.format(val)))
ax.set_xlabel('Time (s)')
ax.set_xlim(-TMAP8_time_k10.max()/100,TMAP8_time_k10.max())
ax.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m$^3$)")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
mass_variation_percentage = (np.max(mass_conservation_sum_encl1_encl2_k10)-np.min(mass_conservation_sum_encl1_encl2_k10))/np.max(mass_conservation_sum_encl1_encl2_k10)*100
print("Percentage of mass variation: ", mass_variation_percentage)
fig.savefig('ver-1kd_mass_conservation_k10.png', bbox_inches='tight', dpi=300)

# Subplot 4 : Equilibrium constant in enclosures 1 and 2 vs Time

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(TMAP8_time_k10, equilibrium_constant_encl_2, label = r"Enclosure 2", c='tab:red')
ax.plot(TMAP8_time_k10, equilibrium_constant_encl_1, label = r"Enclosure 1", c='tab:blue')
ax.axhline(y=2, color='tab:green', linestyle='--', label='TMAP7 Equilibrium Constant')
ax.set_xlabel('Time (s)')
ax.set_xlim(0,TMAP8_time_k10.max())
ax.set_ylabel(r"Equilibrium constant $P_{\text{HT}} / \sqrt{P_{\text{H}_2} P_{\text{T}_2}}$")
ax.set_ylim(bottom=0)
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
print("Relative variation to equilibrium constant in enclosure 1", abs(equilibrium_constant_encl_1[len(equilibrium_constant_encl_1)-1]-2)/2 * 100)
print("Relative variation to equilibrium constant in enclosure 2", abs(equilibrium_constant_encl_2[len(equilibrium_constant_encl_2)-1]-2)/2 * 100)
fig.savefig('ver-1kd_equilibrium_constant_k10.png', bbox_inches='tight', dpi=300)



