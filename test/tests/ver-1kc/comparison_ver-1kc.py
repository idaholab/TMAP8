import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Load experimental data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder_k10 = "../../../../test/tests/ver-1kc/gold/ver-1kc_out_k10.csv"
else:                                  # if in test folder
    csv_folder_k10 = "./gold/ver-1kc_out_k10.csv"
expt_data_k10 = pd.read_csv(csv_folder_k10)
TMAP8_time_k10 = expt_data_k10['time']
TMAP8_pressure_enclosure_1_k10 = expt_data_k10['pressure_enclosure_1']
TMAP8_pressure_enclosure_2_k10 = expt_data_k10['pressure_enclosure_2']
concentration_enclosure_1_at_interface_k10 = expt_data_k10['concentration_enclosure_1_at_interface']
pressure_enclosure_2_at_interface_k10 = expt_data_k10['pressure_enclosure_2_at_interface']
mass_conservation_sum_encl1_encl2_k10 = expt_data_k10['mass_conservation_sum_encl1_encl2'].values
concentration_ratio_k10 = expt_data_k10['concentration_ratio']

# Subplot 1 : Pressure vs time

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(TMAP8_time_k10, TMAP8_pressure_enclosure_1_k10, label=r"T$_2$ Enclosure 1", c='tab:red', linestyle='-')
ax.plot(TMAP8_time_k10, TMAP8_pressure_enclosure_2_k10, label=r"T$_2$ Enclosure 2", c='tab:blue', linestyle='-')
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.1e}'.format(val)))
ax.set_xlabel('Time (s)')
ax.set_ylabel('Pressure (Pa)')
ax.set_xlim(0, TMAP8_time_k10.max())
ax.set_ylim(bottom=0)
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig.savefig('ver-1kc_comparison_time_k10.png', bbox_inches='tight', dpi=300)

# Subplot 2: Solubility and concentration ratios vs time

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

solubility_ratio = [10] * len(TMAP8_time_k10[1:])
ax.plot(TMAP8_time_k10[1:], concentration_ratio_k10[1:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time_k10[1:], solubility_ratio, label=r"Solubility Ratio (Analytical)", color='tab:red', linestyle='--')
ax.set_yticks(np.arange(0, 21, 10))
ax.set_xlim(0,TMAP8_time_k10.max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{encl1}} / \sqrt{C_{\text{encl2}}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((concentration_ratio_k10[1:]-solubility_ratio)**2))
RMSPE = RMSE*100/np.mean(solubility_ratio)
x_pos = TMAP8_time_k10.max() / 7200
y_pos = 0.9 * ax.get_ylim()[1]
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('ver-1kc_concentration_ratio_k10.png', bbox_inches='tight', dpi=300)

# Subplot 3 : Mass Conservation Sum Encl 1 and 2 vs Time

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(TMAP8_time_k10, mass_conservation_sum_encl1_encl2_k10, c='tab:blue')
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda val, pos: '{:.3e}'.format(val)))
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Mass Conservation Sum Encl 1 and 2 (mol/m$^3$)")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
mass_variation_percentage = (np.max(mass_conservation_sum_encl1_encl2_k10)-np.min(mass_conservation_sum_encl1_encl2_k10))/np.min(mass_conservation_sum_encl1_encl2_k10)*100
print("Percentage of mass variation: ", mass_variation_percentage)
fig.savefig('ver-1kc_mass_conservation_k10.png', bbox_inches='tight', dpi=300)

