import pandas as pd
import scipy.constants as scc
import numpy as np
import matplotlib.pyplot as plt
import os
# Read the output of the test, or the gold file if the test has not been run
if os.path.exists('../../../../test/tests/fuel-cycle/fuel_cycle_out.csv'):
    model_file = '../../../../test/tests/fuel-cycle/fuel_cycle_out.csv'
elif os.path.exists('../../../../test/tests/fuel-cycle/gold/fuel_cycle_out.csv'):
    model_file = '../../../../test/tests/fuel-cycle/fuel_cycle_out.csv'
else:
    raise OSError('No model output in the expected locations. Try running the test first')
df = pd.read_csv(model_file)

# Read the data pertaining to Abdou 2021 Figure 3
bz_pts = np.genfromtxt('abdou2021bz.csv')
tes_pts = np.genfromtxt('abdou2021tes.csv')
sto_pts = np.genfromtxt('abdou2021sto.csv')
iss_pts = np.genfromtxt('abdou2021iss.csv')

# Make a list of all the keys we want from the keys in the model CSV file
x_keys = ['T_01_BZ','T_02_TES','T_09_ISS','T_11_storage']
df['time']/=scc.day

# Begin to make the figure
fig,ax = plt.subplots()
ax.set_xscale('log')
ax.set_yscale('log')

linestyles = {'T_02_TES':'--',
              'T_01_BZ':':',
              'T_11_storage':'-',
              'T_09_ISS':'-.'}
for i, x_key in enumerate(x_keys):
    df.plot("time",x_key ,ax=ax,c='C{:d}'.format(i%10),label=x_key ,ls=linestyles[x_key])

# Match the original figure bounds
ax.set_xlim(1e-1,1e4)
ax.set_ylim(1e-3,1e4)
ax.set_xlabel('Time (Days)')
# Make lighter shaded lines to reflect the original figure lines. Keep the color,
# but make them transparent
ax.plot(*bz_pts.T,alpha=0.5)
ax.plot(*tes_pts.T,c='C1',alpha=0.5)
ax.plot(*iss_pts.T,c='C2',alpha=0.5)
ax.plot(*sto_pts.T,c='C3',alpha=0.5)
ax.legend(ncols=3)
ax.set_ylabel('Tritium inventory [kg]')
fig.savefig('../figures/fuel_cycle_abdou_03.png',dpi=300)
