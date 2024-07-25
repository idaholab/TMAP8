import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os
import git
from numpy import sin,tan,sqrt,exp

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

# ===============================================================================
# Extract TMAP8 predictions
tmap8_solution = pd.read_csv("./gold/ver-1ja_out.csv")
tmap8_time = tmap8_solution['time']
tmap8_tritium = tmap8_solution['tritium_concentration']
tmap8_helium = tmap8_solution['helium_concentration']

#  ===============================================================================
# Calculate the analytical solution
tritium_concentration_initial = 1.5e5 # atoms/m3
half_life = 12.3232 # years
conversion_years_to_s = 365.25*24*60*60
half_life_s = half_life*conversion_years_to_s # s
decay_rate_constant = 0.693/half_life_s # 1/s

analytical_tritium = tritium_concentration_initial * np.exp(- decay_rate_constant * tmap8_time)
analytical_helium = tritium_concentration_initial * ( 1. - np.exp(- decay_rate_constant * tmap8_time))

#  ===============================================================================
# Plot figure for verification of tritium decay
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
tmap8_time_years = [t/conversion_years_to_s for t in tmap8_time]
ax.plot(tmap8_time_years,tmap8_tritium,label=r"$C_T$ - TMAP8",c='tab:blue', alpha=0.5)
ax.plot(tmap8_time_years,analytical_tritium,label=r"$C_T$ - Analytical",c='b', linestyle='--')
ax.plot(tmap8_time_years,tmap8_helium,label=r"$C_{He}$ - TMAP8",c='tab:red', alpha=0.5)
ax.plot(tmap8_time_years,analytical_helium,label=r"$C_{He}$ - Analytical",c='r', linestyle='--')
ax.set_xlabel(u'Time (years)')
ax.set_ylabel(r"Concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1ja_comparison_analytical.png', bbox_inches='tight', dpi=300);
plt.close(fig)
