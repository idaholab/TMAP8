import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy.special import erf
from numpy import sqrt
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder4 = "../../../../test/tests/ver-1c/gold/ver-1c_tmap4.csv"
    csv_folder7 = "../../../../test/tests/ver-1c/gold/ver-1c_tmap7.csv"
else:                                  # if in test folder
    csv_folder4 = "./gold/ver-1c_tmap4.csv"
    csv_folder7 = "./gold/ver-1c_tmap7.csv"
tmap_sol_4 = pd.read_csv(csv_folder4)
tmap_sol_7 = pd.read_csv(csv_folder7)
tmap_time_4 = tmap_sol_4['time'][1:]
tmap_conc0_4 = tmap_sol_4['point0'][1:]
tmap_conc0_25_4 = tmap_sol_4['point0.25'][1:]
tmap_conc10_4 = tmap_sol_4['point10'][1:]
tmap_conc12_4 = tmap_sol_4['point12'][1:]
tmap_time_7 = tmap_sol_7['time'][1:]
tmap_conc0_7 = tmap_sol_7['point0'][1:]
tmap_conc0_25_7 = tmap_sol_7['point0.25'][1:]
tmap_conc10_7 = tmap_sol_7['point10'][1:]
tmap_conc12_b = tmap_sol_7['point12'][1:]

def get_c_analytical_4(x,t):
    c0 = 1 # atom/m^3
    h = 10 # m
    D = 1  # m^2/s
    erf_func1 =  erf((h-x)/(2*sqrt(D*t)) )
    erf_func2 =  erf((x+h)/(2*sqrt(D*t)) )
    output = (c0/2)*(erf_func1 + erf_func2 )
    return output
def get_c_analytical_7(x,t):
    c0 = 1 # atom/m^3
    h = 10 # m
    D = 1  # m^2/s
    erf_func0 =2*erf(  x  /(2*sqrt(D*t)))
    erf_func1 =  erf((x-h)/(2*sqrt(D*t)))
    erf_func2 =  erf((x+h)/(2*sqrt(D*t)))
    output = (c0/2)*(erf_func0 - erf_func1 - erf_func2)
    if hasattr(output, '__iter__'):
        output[(t==0) & (x< 0)] = 0
        output[(t==0) & (x< h) & (0 < x)] = c0
        output[(t==0) & (x> h)] = 0
    return output
idx = np.where(tmap_time >= 10.0)[0][0]

analytical_conc0_4 = get_c_analytical_4(0,tmap_time_4)
analytical_conc0_25_4 = get_c_analytical_4(0.25,tmap_time_4)
analytical_conc10_4 = get_c_analytical_4(x=10,t=tmap_time_4)
analytical_conc12_4 = get_c_analytical_4(x=12,t=tmap_time_4)

analytical_conc0_7 = get_c_analytical_7(0,tmap_time_7)
analytical_conc0_25_7 = get_c_analytical_7(0.25,tmap_time_7)
analytical_conc10_7 = get_c_analytical_7(x=10,t=tmap_time_7)
analytical_conc12_7 = get_c_analytical_7(x=12,t=tmap_time_7)
#========= Comparison of concentration as a function of time (TMAP4 case) ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_time,tmap_conc0,label=r"TMAP8 x=0 m",c='tab:blue')
ax.plot(tmap_time,analytical_conc0,label=r"Analytical x=0 m",c='tab:brown', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc0-analytical_conc0)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc0[idx:])
ax.text(20,get_c_analytical_4(0,20), 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time,tmap_conc10,label=r"TMAP8 x=10 m",c='tab:red')
ax.plot(tmap_time,analytical_conc10,label=r"Analytical x=10 m",c='tab:cyan', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc10-analytical_conc10)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc10[idx:])
ax.text(20,get_c_analytical_4(10,20), 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time,tmap_conc12,label=r"TMAP8 x=12 m",c='tab:grey')
ax.plot(tmap_time,analytical_conc12,label=r"Analytical x=12 m",c='k', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc12-analytical_conc12)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc12[idx:])
ax.text(20,get_c_analytical_4(12,20), 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',ha='left',va='top')


ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Species concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0,right=100)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1c_comparison_time_TMAP4.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#========= Comparison of concentration as a function of time (TMAP7 case) ===================

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_time_7,tmap_conc0_25_7,label=r"TMAP8 x=0.25 m",c='tab:blue')
ax.plot(tmap_time_7,analytical_conc0_25_7,label=r"Analytical x=0.25 m",c='tab:brown', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc0_25_7-analytical_conc0_25_7)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc0_25_7[idx:])
ax.text(20,get_c_analytical_7(0.25,20), 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time_7,tmap_conc10_7,label=r"TMAP8 x=10 m",c='tab:red')
ax.plot(tmap_time_7,analytical_conc10_7,label=r"Analytical x=10 m",c='tab:cyan', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc10_7-analytical_conc10_7)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc10_7[idx:])
ax.text(20,get_c_analytical_7(10,20), 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.plot(tmap_time_7,tmap_conc12_7,label=r"TMAP8 x=12 m",c='tab:grey')
ax.plot(tmap_time_7,analytical_conc12_7,label=r"Analytical x=12 m",c='k', linestyle='--', dashes=(5,5))
RMSE = np.sqrt(np.mean((tmap_conc12_7-analytical_conc12_7)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_conc12_7[idx:])
ax.text(20,get_c_analytical_7(12,20), 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')

ax.set_xlabel(u'Time(s)')
ax.set_ylabel(r"Species concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0,right=100)
ax.set_ylim(bottom=0,top=0.55)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1c_comparison_time_TMAP7.png', bbox_inches='tight', dpi=300)
