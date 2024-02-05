import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd

#===============================================================================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap8_prediction = pd.read_csv("./ver-1a_csv.csv")
analytical_solution = pd.read_csv("./analytical.csv")
tmap_time = tmap8_prediction['time']
tmap_release_fraction = tmap8_prediction['released_fraction']
analytical_time = analytical_solution['time(s)']
analytical_release_fraction = analytical_solution['frac_rel']

ax.plot(tmap_time,tmap_release_fraction,label=r"TMAP8",c='tab:gray')
ax.plot(analytical_time,analytical_release_fraction,label=r"Analytical",c='k', linestyle='--')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Fractional release")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=45)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('comparison.png', bbox_inches='tight');
plt.close(fig)
