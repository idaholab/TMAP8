import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import os
import math

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

def newton_cool_down(initial_temperature, time_constant, environment_temperature, current_time, start_time=0.0):
    """Calculate current temperature of a pre-heated sample over time using Newton's law of cooling

    Args:
        initial_temperature (float): starting temperature of the sample (K)
        time_constant (float): time constant of heat transfer (s)
        environment_temperature (float): temperature of the environment, suitably far from the surface (K)
        start_time (float): time when source heating the sample is removed and cooling begins, defaulted to zero (s)
        current_time (float): current time (s)

    Returns:
        float: current temperature of the sample (K)
    """
    return environment_temperature + (initial_temperature - environment_temperature) \
                                   * math.exp(-(current_time - start_time) / time_constant)

time_series = []
cooling_data = []
for i in range(len(initial_temperature)):
    # Build complete time series for all phases
    time_series = list(range(0, TDS_end, 1))

    # Calculate temperature at each point in time
    temp = []
    for t in time_series:
        if t < hold_time[i]:
            # Constant heat source phase
            temp.append(initial_temperature[i])
        elif t < TDS_start:
            # Cooldown phase
            temp.append(newton_cool_down(initial_temperature[i], cooling_time_constant,
                                         temperature_room, t, hold_time[i]))
        elif t < TDS_ramp_end:
            # Ramp phase
            temp.append(temperature_ramp_rate * (t - TDS_start) + temperature_min)
        else:
            # Final hold phase
            temp.append(final_temperature)

    cooling_data.append(temp)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

for i in range(len(cooling_data)):
  label = "TMAP8 - " + str(initial_temperature[i]) + " K"
  ax.plot(time_series, cooling_data[i], linestyle='-', linewidth=4.0, label=label)

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

