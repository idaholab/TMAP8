import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
from numpy import sin,tan,sqrt,exp

# ========= Comparison of concentration as a function of time ===================

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./gold/u_vs_t.csv")
tmap_time = tmap_sol['time']
tmap_conc = tmap_sol['conc_point1']

analytical_sol = pd.read_csv("./analytical_time.csv")
analytical_time = np.arange(0,5000,2)
analytical_conc = analytical_sol['u']
t = np.expand_dims(analytical_time,axis=0)
x = 15.75e-6
c0 = 50.7079            # concentration at the PyC free surface (moles/um^3)
a  = 33e-6              # thickness of the PyC layer (um)
l  = 66e-6              # thickness of the SiC layer (um)
D_PyC = 1.274e-7        # diffusivity in PyC (m^2/s)
D_SiC = 2.622e-11       # diffusivity in SiC (m^2/s)

k = sqrt(D_PyC/D_SiC)
lambda_range = np.arange(1e-12,1e6,1e-3)
f = 1/tan(lambda_range*a)
g = 1/tan(k*l*lambda_range)/k
idx = np.where(np.diff(np.sign(f+g)))
lambdas = np.expand_dims(lambda_range[idx],axis=0)
summation = (sin(a*lambdas)*sin(k*l*lambdas)*sin(k*(l-x)*lambdas)/(lambdas*( a*sin(k*l*lambdas)*sin(k*l*lambdas) + l*sin(a*lambdas)*sin(a*lambdas) ) ) )*exp(-D_PyC*np.power(lambdas,2)*t.transpose() )
sums = np.sum(summation,axis=1)

analytical_conc = c0*(D_PyC*(l-x)/(l*D_PyC + a*D_SiC)  - 2*sums)*np.ones(sums.shape)


ax.plot(tmap_time, tmap_conc, label=r"TMAP8", c='tab:gray')
ax.plot(analytical_time, analytical_conc,
        label=r"Analytical", c='k', linestyle='--')


ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(-10,50)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_time.png', bbox_inches='tight')
plt.close(fig)


# ============ Comparison of concentration as a function of distance ============

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./gold/steady_state_u_vs_x.csv")
tmap_distance = tmap_sol['x']
tmap_distance_microns = tmap_distance*1e6
tmap_conc = tmap_sol['u']

x = tmap_distance
PyC_conc = c0*(1 + (x/l)*((a*D_PyC)/(a*D_PyC + l*D_SiC) - 1 ) )
SiC_conc = c0*(((a+l-x)/l)*(a*D_PyC)/(a*D_PyC + l*D_SiC) )
analytical_conc = (x<a)*PyC_conc+(x>=a)*SiC_conc

ax.plot(tmap_distance_microns, tmap_conc, label=r"TMAP8", c='tab:gray')
ax.plot(tmap_distance_microns, analytical_conc,
        label=r"Analytical", c='k', linestyle='--')

ax.set_xlabel(u'Distance ($\mu$m)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_dist.png', bbox_inches='tight')
plt.close(fig)
