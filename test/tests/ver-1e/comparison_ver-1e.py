import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special

# ========= Comparison of concentration as a function of time ===================

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./ver-1e_csv.csv")
tmap_time = tmap_sol['time']
tmap_conc = tmap_sol['conc_point1']

analytical_sol = pd.read_csv("./analytical_time.csv")
analytical_time = analytical_sol['t']
analytical_conc = analytical_sol['u']
ax.plot(tmap_time, tmap_conc, label=r"TMAP8", c='tab:gray')
ax.plot(analytical_time, analytical_conc,
        label=r"Analytical", c='k', linestyle='--')


ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_time.png', bbox_inches='tight')
plt.close(fig)


# ============ Comparison of concentration as a function of distance ============

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./ver-1e_u_vs_x_steadyState.csv")
tmap_distance = tmap_sol['x']*1e6
tmap_conc = tmap_sol['u']

analytical_sol = pd.read_csv("./analytical_u_vs_x_steadyState.csv")
analytical_distance = analytical_sol['x']*1e6
analytical_conc = analytical_sol['u']

ax.plot(tmap_distance, tmap_conc, label=r"TMAP8", c='tab:gray')
ax.plot(analytical_distance, analytical_conc,
        label=r"Analytical", c='k', linestyle='--')

ax.set_xlabel(u'Distance ($\mu$m)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_dist.png', bbox_inches='tight')
plt.close(fig)
