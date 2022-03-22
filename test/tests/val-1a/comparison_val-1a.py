import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd

#===============================================================================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./val-1a_csv.csv")
analytical_sol = pd.read_csv("./analytical.csv")
tmap_time = tmap_sol['time']
tmap_fr = tmap_sol['rhs_release']
analytical_time = analytical_sol['time(s)']
analytical_fr = analytical_sol['frac_rel']

ax.plot(tmap_time,tmap_fr,label=r"TMAP8",c='tab:gray')
ax.plot(analytical_time,analytical_fr,label=r"Analytical",c='k', linestyle='--')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Fractional release")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=45)
ax.set_ylim(bottom=0)
plt.grid(b=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('comparison.png', bbox_inches='tight');
plt.close(fig)
