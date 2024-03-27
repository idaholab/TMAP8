import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special

#========= Comparison of concentration as a function of time ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("ver-1b_csv.csv")
tmap_time = tmap_sol['time']
tmap_conc = tmap_sol['conc_point1']

analytical_time = tmap_time
x = 0.2
C_o = 1
D = 1
analytical_conc = C_o * special.erfc( x / (2 * np.sqrt(D*analytical_time)))
ax.plot(tmap_time,tmap_conc,label=r"TMAP8",c='tab:gray')
ax.plot(analytical_time,analytical_conc,label=r"Analytical",c='k', linestyle='--')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Normalized specie concentration")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=45)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1b_comparison_time.png', bbox_inches='tight');
plt.close(fig)


#============ Comparison of concentration as a function of distance ============

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("ver-1b_vector_postproc_line_0250.csv")
tmap_distance = tmap_sol['x']
tmap_conc = tmap_sol['u']

analytical_distance = tmap_distance
time = 25
C_o = 1
D = 1
analytical_conc = C_o * special.erfc( analytical_distance / (2 * np.sqrt(D * time)))

ax.plot(tmap_distance,tmap_conc,label=r"TMAP8",c='tab:gray')
ax.plot(analytical_distance,analytical_conc,label=r"Analytical",c='k', linestyle='--')

ax.set_xlabel(u'Distance (m)')
ax.set_ylabel(r"Normalized specie concentration")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=50)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1b_comparison_dist.png', bbox_inches='tight');
plt.close(fig)
#================== Comparison of flux as a function of time ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("ver-1b_csv.csv")
tmap_time = tmap_sol['time']
tmap_flux = tmap_sol['flux_point2']

analytical_time = tmap_time
x = 0.5
C_o = 1
D = 1
analytical_flux = C_o * np.sqrt(D/(np.pi * analytical_time)) * \
                  np.exp( x / (2 * np.sqrt(D * analytical_time)))
ax.plot(tmap_time,tmap_flux,label=r"TMAP8",c='tab:gray')
ax.plot(analytical_time,analytical_flux,label=r"Analytical",c='k', linestyle='--')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Diffusive flux")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=45)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1b_comparison_flux.png', bbox_inches='tight');
plt.close(fig)
