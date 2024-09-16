import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy.special import erf
from numpy import sqrt
import os
import git

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

tmap_sol = pd.read_csv(os.path.join(git.Repo('.',search_parent_directories=True).working_tree_dir, "test/tests/ver-1c/gold/ver-1c_csv.csv"))
tmap_time = tmap_sol['time'][1:]
tmap_conc0 = tmap_sol['point0'][1:]
tmap_conc0_25 = tmap_sol['point0.25'][1:]
tmap_conc10 = tmap_sol['point10'][1:]
tmap_conc12 = tmap_sol['point12'][1:]

def get_c_analytical(x,t):
    c0 = 1 # atom/m^3
    h = 10 # m
    D = 1  # m^2/s

    erf_func1 = erf((h-x)/(2*sqrt(D*t)) )
    erf_func2 = erf((h+x)/(2*sqrt(D*t)) )
    return (c0/2)*( erf_func1 + erf_func2 )

idx = np.where(tmap_time >= 10.0)[0][0]

analytical_conc0 = get_c_analytical(0,tmap_time)
analytical_conc0_25 = get_c_analytical(0.25,tmap_time)
analytical_conc10 = get_c_analytical(x=10,t=tmap_time)
analytical_conc12 = get_c_analytical(x=12,t=tmap_time)


#========= Comparison of concentration as a function of time (TMAP4 case) ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_time,tmap_conc0,label=r"TMAP8 x=0 m",c='tab:blue')
ax.plot(tmap_time,analytical_conc0,label=r"Analytical x=0 m",c='tab:brown', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc0-analytical_conc0)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc0[idx:])
ax.text(20,0.9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time,tmap_conc10,label=r"TMAP8 x=10 m",c='tab:red')
ax.plot(tmap_time,analytical_conc10,label=r"Analytical x=10 m",c='tab:cyan', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc10-analytical_conc10)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc10[idx:])
ax.text(20,0.55, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time,tmap_conc12,label=r"TMAP8 x=12 m",c='tab:grey')
ax.plot(tmap_time,analytical_conc12,label=r"Analytical x=12 m",c='k', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc12-analytical_conc12)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc12[idx:])
ax.text(20,0.25, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Species concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0,right=100)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1c_comparison_time_TMAP4.png', bbox_inches='tight')
plt.close(fig)

#========= Comparison of concentration as a function of time (TMAP7 case) ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_time,tmap_conc0_25,label=r"TMAP8 x=0.25 m",c='tab:blue')
ax.plot(tmap_time,analytical_conc0_25,label=r"Analytical x=0.25 m",c='tab:brown', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc0_25-analytical_conc0_25)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc0_25[idx:])
ax.text(20,0.9, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time,tmap_conc10,label=r"TMAP8 x=10 m",c='tab:red')
ax.plot(tmap_time,analytical_conc10,label=r"Analytical x=10 m",c='tab:cyan', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc10-analytical_conc10)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc10[idx:])
ax.text(20,0.55, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time,tmap_conc12,label=r"TMAP8 x=12 m",c='tab:grey')
ax.plot(tmap_time,analytical_conc12,label=r"Analytical x=12 m",c='k', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc12-analytical_conc12)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc12[idx:])
ax.text(20,0.25, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Species concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0,right=100)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1c_comparison_time_TMAP7.png', bbox_inches='tight')
