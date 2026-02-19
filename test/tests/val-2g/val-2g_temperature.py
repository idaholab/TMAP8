import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import os
import math
import pandas as pd

# This file recreates Figure 3 from M. Shimada, et al., Fus. Eng. Des., 136, 1161 (2018)
# Caption:
#     "Temperature profiles used in the modeling for 673, 873, and 973 K. The time constant of 1200 s
#      was used to simulate the cool-down process after the TPE plasma exposure. Thermal desorption
#      was simulated with the ramp rate (10 K/min) from 293 K to 1173 K and the temperature hold at
#      1173 K for 0.5 h from t = 12000 s to 19190 s."
# Deviations, adjustments, and definitions:
#     - Explicit hold times were not given in the figure, or the body text. Only, "slightly different
#       plasma exposure time was used to obtain the similar D ion fluence of 5.0 \times 10^25 m^{-2}
#       with the different ion flux densities in W53A, W55A, and W26A." So, assuming a constant TPE
#       exposure flux, the exposure time was determined by taking the fluence and dividing by the flux
#       from Table 1 in the article. This gave a very reasonable approximation to the Figure 3 data.
#     - Cool-down period in article figure seems to end at around 300 K, not 293 K. There is a visible dip
#       from the cool-down period into the ramp-up. Assuming 293 K is the ambient room temperature
#       for the purposes of Newton's law of cooling, and the cool-down period was really stopped at
#       around 300 K (as it seems to do), then we'll set the ramp up period to start at 300 K in order
#       to keep the function relatively smooth at the end of the cool-down period into the ramp up.
#     - Given the 10 K/min ramp rate and the time alloted above for the ramp up, the ramp up temperature
#       actually overshoots 1173 K (this is regardless of the starting temperature adjustment above).
#       In order to keep the temperature hold period consistent at 0.5 h in the model, the ramp end
#       time was set to 17238 s and the final end time set to 19038 s.

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Necessary parameters
initial_temperature = [673, 873, 973] # K
hold_time = [7183, 6341, 5952] # s
cooling_time_constant = 1200 # s
temperature_room = 293 # K
temperature_min = 300 # K
TDS_start = 12000 # s
TDS_ramp_end = 17238 # s
TDS_end = 19038 # s
final_temperature = 1173 # K
temperature_ramp_rate = 10/60 # K/s

file_base = 'val-2g_temperature'

time_series = []
cooling_data = []

# Read TMAP8 simulation data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/gold/val-2g_673_out.csv"
else:                                  # if in test folder
    csv_folder = "./val-2g_673_out.csv"
simulation_673_data = pd.read_csv(csv_folder)
simulation_time_673 = simulation_673_data['time']
simulation_temperature_673 = simulation_673_data['temperature']
time_series.append(simulation_time_673)
cooling_data.append(simulation_temperature_673)

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/gold/val-2g_873_out.csv"
else:                                  # if in test folder
    csv_folder = "./val-2g_873_out.csv"
simulation_873_data = pd.read_csv(csv_folder)
simulation_time_873 = simulation_873_data['time']
simulation_temperature_873 = simulation_873_data['temperature']
time_series.append(simulation_time_873)
cooling_data.append(simulation_temperature_873)

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/gold/val-2g_973_out.csv"
else:                                  # if in test folder
    csv_folder = "./val-2g_973_out.csv"
simulation_973_data = pd.read_csv(csv_folder)
simulation_time_973 = simulation_973_data['time']
simulation_temperature_973 = simulation_973_data['temperature']
time_series.append(simulation_time_973)
cooling_data.append(simulation_temperature_973)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

for i in range(len(cooling_data)):
  label = "TMAP8 - " + str(initial_temperature[i]) + " K"
  ax.plot(time_series[i], cooling_data[i], linestyle='-', linewidth=4.0, label=label)

# Font sizes for labels and axes
SMALL_SIZE = 12
MEDIUM_SIZE = 14
BIGGER_SIZE = 16

ax.set_xlabel(u'Time [s]', weight='bold', fontsize=BIGGER_SIZE)
ax.set_ylabel(u'Temperature [K]', weight='bold', fontsize=BIGGER_SIZE)
ax.legend(loc="best", fontsize=SMALL_SIZE)
ax.set_xlim(left=0, right=20001)
start, end = ax.get_xlim()
ax.xaxis.set_ticks(np.arange(start, end, 5000))
ax.set_ylim(bottom=290, top=1200)
ax.minorticks_on()
ax.tick_params(axis='both', which='both', direction='out', bottom=True, top=True, left=True,
               right=True, labelsize=MEDIUM_SIZE)
plt.savefig(f'{file_base}.png', bbox_inches='tight', dpi=300)
plt.close(fig)

