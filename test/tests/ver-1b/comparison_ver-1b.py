import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#========= Comparison of concentration as a function of time ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1b/gold/ver-1b_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1b_csv.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_time = tmap_sol['time']
tmap_conc = tmap_sol['conc_point1']
idx = np.where(tmap_time >= 10.0)[0][0]

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
RMSE = np.sqrt(np.mean((tmap_conc-analytical_conc)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc[idx:])
ax.text(5,0.9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1b_comparison_time.png', bbox_inches='tight')
plt.close(fig)


#============ Comparison of concentration as a function of distance ============

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1b/gold/ver-1b_vector_postproc_line_0250.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1b_vector_postproc_line_0250.csv"
tmap_sol = pd.read_csv(csv_folder)
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
RMSE = np.sqrt(np.mean((tmap_conc-analytical_conc)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc[idx:])
ax.text(10,0.4, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1b_comparison_dist.png', bbox_inches='tight')
plt.close(fig)
#================== Comparison of flux as a function of time ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1b/gold/ver-1b_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1b_csv.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_time = tmap_sol['time']
tmap_flux = tmap_sol['flux_point2']

analytical_time = tmap_time
x = 0.5
C_o = 1
D = 1
analytical_flux = C_o * np.sqrt(D/(np.pi * analytical_time)) * \
                  np.exp( x / (2 * np.sqrt(D * analytical_time)))
ax.plot(tmap_time[1:],tmap_flux[1:],label=r"TMAP8",c='tab:gray')
ax.plot(analytical_time[1:],analytical_flux[1:],label=r"Analytical",c='k', linestyle='--')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Diffusive flux")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=45)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap_flux-analytical_flux)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_flux[idx:])
ax.text(10,0.25, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1b_comparison_flux.png', bbox_inches='tight')
plt.close(fig)
