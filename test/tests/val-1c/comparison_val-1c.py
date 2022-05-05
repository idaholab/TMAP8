import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from    scipy import special

#========= Comparison of concentration as a function of time ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./gold/val-1c_csv.csv")
tmap_time = tmap_sol['time']
tmap_conc0 = tmap_sol['point0']
tmap_conc10 = tmap_sol['point10']
tmap_conc12 = tmap_sol['point12']

analytical_sol = pd.read_csv("./analytical.csv")
analytical_time = analytical_sol['time']
analytical_conc0 = analytical_sol['point0']
analytical_conc10 = analytical_sol['point10']
analytical_conc12 = analytical_sol['point12']

ax.plot(tmap_time,tmap_conc0,label=r"TMAP8 x=0",c='tab:blue')
ax.plot(analytical_time,analytical_conc0,label=r"Analytical x=0",c='tab:blue', linestyle='--')
ax.plot(tmap_time,tmap_conc10,label=r"TMAP8 x=10",c='tab:red')
ax.plot(analytical_time,analytical_conc10,label=r"Analytical x=10",c='tab:red', linestyle='--')
ax.plot(tmap_time,tmap_conc12,label=r"TMAP8 x=12",c='k')
ax.plot(analytical_time,analytical_conc12,label=r"Analytical x=12",c='k', linestyle='--')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Normalized specie concentration")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(b=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('val-1c_comparison_time.png', bbox_inches='tight');
plt.close(fig)
