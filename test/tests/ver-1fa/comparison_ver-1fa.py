import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special



fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

analytical_x = np.linspace(0.0, 1.6, 40)
Ts = 300
k = 10
L = 1.6
Q = 10000
analytical_temp = Ts + Q*L**2 * (1- analytical_x**2/L**2) / (2*k)
ax.scatter(analytical_x,analytical_temp,label=r"Analytical",c='k', marker='^')

tmap_sol = pd.read_csv("./gold/ver-1fa_csv_line_0011.csv")
tmap_x = tmap_sol['id']
tmap_temp = tmap_sol['temp']
ax.plot(tmap_x,tmap_temp,label=r"TMAP8",c='tab:gray')

ax.set_xlabel(u'Distance along slab (m)')
ax.set_ylabel(u"Temperature (K)")
ax.legend(loc="best")
#ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1fa_comparison_temperature.png', bbox_inches='tight');
plt.close(fig)
