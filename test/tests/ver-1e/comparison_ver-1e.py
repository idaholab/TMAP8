import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
from numpy import sin,tan,sqrt,exp
import os
import git

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

# ========= Comparison of concentration as a function of time ===================

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol_tmap4 = pd.read_csv(os.path.join(git.Repo('.',search_parent_directories=True).working_tree_dir, "test/tests/ver-1e/gold/TMAP4.csv"))
tmap_sol_tmap7 = pd.read_csv(os.path.join(git.Repo('.',search_parent_directories=True).working_tree_dir, "test/tests/ver-1e/gold/TMAP7.csv"))

tmap_time_tmap4 = tmap_sol_tmap4['time']
tmap_conc_tmap4 = tmap_sol_tmap4['conc_at_x']
tmap_time_tmap7 = tmap_sol_tmap7['time']
tmap_conc_tmap7 = tmap_sol_tmap7['conc_at_x']

ax.plot(tmap_time_tmap4, tmap_conc_tmap4, label=r"TMAP8 (TMAP4 case)", c='tab:gray')
ax.plot(tmap_time_tmap7, tmap_conc_tmap7, label=r"TMAP8 (TMAP7 case)", c='tab:brown')

def get_lambdas(k,l,a):
    # Calculate lambda values for analytical solution
        lambda_range = np.arange(1e-12,1e4,1e-4)
        f = 1/tan(lambda_range*a)
        g = 1/tan(k*l*lambda_range)/k
        idx = np.where(np.diff(np.sign(f+g)))
        lambdas = np.expand_dims(lambda_range[idx][::2],axis=0)
        return lambdas

t0 = 0.2
# TMAP 4 Analytical solution
c0 = 50.7079            # concentration at the PyC free surface (moles/m^3)
a  = 33e-6              # thickness of the PyC layer (m)
l  = 63e-6              # thickness of the SiC layer (m)
D_PyC = 1.274e-7        # diffusivity in PyC (m^2/s)
D_SiC = 2.622e-11       # diffusivity in SiC (m^2/s)
k = sqrt(D_PyC/D_SiC)

lambdas = get_lambdas(k,l,a)

t = np.expand_dims(tmap_time_tmap4,axis=0)
x = 8e-6                # depth into SiC layer from IPyC/SiC interface
                        # where we compare analytical and numerical model concentration predictions (m)
summation = (sin(a*lambdas)*sin(k*l*lambdas)*sin(k*(l-x)*lambdas)/(lambdas*( a*sin(k*l*lambdas)*sin(k*l*lambdas) + l*sin(a*lambdas)*sin(a*lambdas) ) ) )*exp(-D_PyC*np.power(lambdas,2)*t.transpose() )
sums = np.sum(summation,axis=1)

analytical_conc_tmap4 = c0*(D_PyC*(l-x)/(l*D_PyC + a*D_SiC)  - 2*sums)*np.ones(sums.shape)

idx = np.where(tmap_time_tmap4>=t0)[0]
RMSE = np.sqrt(np.mean((tmap_conc_tmap4[idx]-analytical_conc_tmap4[idx])**2))
err_percent = RMSE*100/np.mean(analytical_conc_tmap4[idx])
ax.text(5,40, 'RMSPE = %.2f '%err_percent+'% \n(TMAP4)',fontweight='bold')

ax.plot(tmap_time_tmap4, analytical_conc_tmap4,
        label=r"Analytical (TMAP4 case)", c='k', linestyle='--', dashes=(5,5))

# TMAP 7 Analytical solution
c0 = 50.7079            # concentration at the PyC free surface (moles/m^3)
a  = 33e-6              # thickness of the PyC layer (m)
l  = 66e-6              # thickness of the SiC layer (m)
D_PyC = 1.274e-7        # diffusivity in PyC (m^2/s)
D_SiC = 2.622e-11       # diffusivity in SiC (m^2/s)
k = sqrt(D_PyC/D_SiC)

lambdas = get_lambdas(k,l,a)

t = np.expand_dims(tmap_time_tmap7,axis=0)
x = 15.75e-6            # depth into SiC layer from IPyC/SiC interface
                        # where we compare analytical and numerical model concentration predictions (m)
summation = (sin(a*lambdas)*sin(k*l*lambdas)*sin(k*(l-x)*lambdas)/(lambdas*( a*sin(k*l*lambdas)*sin(k*l*lambdas) + l*sin(a*lambdas)*sin(a*lambdas) ) ) )*exp(-D_PyC*np.power(lambdas,2)*t.transpose() )
sums = np.sum(summation,axis=1)

analytical_conc_tmap7 = c0*(D_PyC*(l-x)/(l*D_PyC + a*D_SiC)  - 2*sums)*np.ones(sums.shape)

idx = np.where(tmap_time_tmap7>=t0)[0]
RMSE = np.sqrt(np.mean((tmap_conc_tmap7[idx]-analytical_conc_tmap7[idx])**2))
err_percent = RMSE*100/np.mean(analytical_conc_tmap7[idx])
ax.text(15, 25, 'RMSPE = %.2f '%err_percent+'% \n(TMAP7)',fontweight='bold')

ax.plot(tmap_time_tmap7, analytical_conc_tmap7,
        label=r"Analytical (TMAP7 case)", c='tab:cyan', linestyle='--', dashes=(5,5))


ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(0,50)
ax.set_ylim(0,45)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_time.png', bbox_inches='tight')
plt.close(fig)

# ============ Closeup of analytical solution ============
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_time_tmap4, tmap_conc_tmap4, label=r"TMAP8 (TMAP4 case)", c='tab:gray')
ax.plot(tmap_time_tmap7, tmap_conc_tmap7, label=r"TMAP8 (TMAP7 case)", c='tab:brown')

ax.plot(tmap_time_tmap4, analytical_conc_tmap4,
        label=r"Analytical (TMAP4 case)", c='k', linestyle='--', dashes=(5,5))

ax.plot(tmap_time_tmap7, analytical_conc_tmap7,
        label=r"Analytical (TMAP7 case)", c='tab:cyan', linestyle='--', dashes=(5,5))


ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(0,1.0)
ax.set_ylim(-1,20)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_time_closeup.png', bbox_inches='tight')
plt.close(fig)
# ============ Comparison of concentration as a function of distance ============

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv(os.path.join(git.Repo('.',search_parent_directories=True).working_tree_dir, "test/tests/ver-1e/gold/TMAP4_vector_postproc_line_0548.csv"))
tmap_distance_tmap4 = tmap_sol['x']
tmap_distance_tmap4_microns = tmap_distance_tmap4*1e6
tmap_conc_tmap4 = tmap_sol['u']
ax.plot(tmap_distance_tmap4_microns, tmap_conc_tmap4, label=r"TMAP8 (TMAP4 case)", c='tab:gray')

tmap_sol = pd.read_csv(os.path.join(git.Repo('.',search_parent_directories=True).working_tree_dir, "test/tests/ver-1e/gold/TMAP7_vector_postproc_line_0548.csv"))
tmap_distance_tmap7 = tmap_sol['x']
tmap_distance_tmap7_microns = tmap_distance_tmap7*1e6
tmap_conc_tmap7 = tmap_sol['u']
ax.plot(tmap_distance_tmap7_microns, tmap_conc_tmap7, label=r"TMAP8 (TMAP7 case)", c='tab:brown')

# TMAP 4 Analytical solution
c0 = 50.7079            # concentration at the PyC free surface (moles/m^3)
a  = 33e-6              # thickness of the PyC layer (m)
l  = 63e-6              # thickness of the SiC layer (m)
D_PyC = 1.274e-7        # diffusivity in PyC (m^2/s)
D_SiC = 2.622e-11       # diffusivity in SiC (m^2/s)

x = tmap_distance_tmap4
PyC_conc = c0*(1 + (x/l)*((a*D_PyC)/(a*D_PyC + l*D_SiC) - 1 ) )
SiC_conc = c0*(((a+l-x)/l)*(a*D_PyC)/(a*D_PyC + l*D_SiC) )
analytical_conc_tmap4 = (x<a)*PyC_conc+(x>=a)*SiC_conc

RMSE = np.sqrt(np.mean((tmap_conc_tmap4-analytical_conc_tmap4)**2))
err_percent = RMSE*100/np.mean(analytical_conc_tmap4)
ax.text(40, 15, 'RMSPE = %.2f '%err_percent+'% \n(TMAP4)',fontweight='bold')

# TMAP 7 Analytical solution
c0 = 50.7079            # concentration at the PyC free surface (moles/m^3)
a  = 33e-6              # thickness of the PyC layer (m)
l  = 66e-6              # thickness of the SiC layer (m)
D_PyC = 1.274e-7        # diffusivity in PyC (m^2/s)
D_SiC = 2.622e-11       # diffusivity in SiC (m^2/s)

x = tmap_distance_tmap7
PyC_conc = c0*(1 + (x/l)*((a*D_PyC)/(a*D_PyC + l*D_SiC) - 1 ) )
SiC_conc = c0*(((a+l-x)/l)*(a*D_PyC)/(a*D_PyC + l*D_SiC) )
analytical_conc_tmap7 = (x<a)*PyC_conc+(x>=a)*SiC_conc

RMSE = np.sqrt(np.mean((tmap_conc_tmap7-analytical_conc_tmap7)**2))
err_percent = RMSE*100/np.mean(analytical_conc_tmap7)
ax.text(70, 25, 'RMSPE = %.2f '%err_percent+'% \n(TMAP7)',fontweight='bold')

ax.plot(tmap_distance_tmap4_microns, analytical_conc_tmap4,
        label=r"Analytical (TMAP4 case)", c='k', linestyle='--', dashes=(5,5))
ax.plot(tmap_distance_tmap7_microns, analytical_conc_tmap7,
        label=r"Analytical (TMAP7 case)", c='tab:cyan', linestyle='--', dashes=(5,5))

ax.set_xlabel(u'Distance ($\mu$m)')
ax.set_ylabel(r"Concentration (moles/m$^3$)")
ax.legend(loc="best")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1e_comparison_dist.png', bbox_inches='tight')
plt.close(fig)
