import pandas as pd
import numpy as np
import scipy.constants as scc
import matplotlib.pyplot as plt
df = pd.read_csv('../../../../test/tests/fuel-cycle/fuel_cycle_out.csv')
bz_pts = np.genfromtxt('abdou2021bz.csv')
tes_pts = np.genfromtxt('abdou2021tes.csv')
sto_pts = np.genfromtxt('abdou2021sto.csv')
iss_pts = np.genfromtxt('abdou2021iss.csv')
x_keys = [x for x in df.keys() if 'T_' in x]
df['time']/=scc.day
fig,ax = plt.subplots()

ax.set_xscale('log')
ax.set_yscale('log')

#ax.pcolormesh(X,Y,d2.copy(),norm='log',cmap='Greys_r')
linestyles = {'T_02_TES':'--',
              'T_01_BZ':':',
              'T_11_storage':'-',
              'T_09_ISS':'-.'}
x_keys = [x for x in x_keys if x in ['T_11_storage','T_01_BZ','T_09_ISS','T_02_TES']]
y_keys = [y for y in df.keys() if 'T_' in y and y not in x_keys]
for i, x_key in enumerate(x_keys):
    df.plot("time",x_key ,ax=ax,c='C{:d}'.format(i%10),label=x_key ,ls=linestyles[x_key])
ax.set_yscale('log')
ax.set_xscale('log')
ax.set_xlim(1e-1,1e4)
ax.set_ylim(1e-3,1e4)
ax.set_xlabel('Time (Days)')
ax.scatter(*bz_pts.T,s=1,alpha=0.1)
ax.scatter(*tes_pts.T,s=1,c='C1',alpha=0.1)
ax.scatter(*iss_pts.T,s=1,c='C2',alpha=0.1)
ax.scatter(*sto_pts.T,s=1,c='C3',alpha=0.1)
ax.legend(ncols=3)
ax.set_ylabel('Tritium inventory [kg]')
fig.savefig('../figures/fuel_cycle_abdou_03.png',dpi=300)
