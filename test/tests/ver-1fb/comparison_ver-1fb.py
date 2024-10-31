import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

num_summation_terms = 10


def summation_terms(n, x, t, alph):
    sum = 0.0
    for m in range(1, n):
        lambdaa = m * np.pi / L
        sum += np.sin(lambdaa * x) * np.exp(-1 *
                                            alph * lambdaa**2 * t) / lambdaa
    return sum

tmap_temp = []
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1fb/gold/ver-1fb_u_vs_x_line_0010.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1fb_u_vs_x_line_0010.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_x = tmap_sol['id']
tmap_temp.append(tmap_sol['temp'])
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1fb/gold/ver-1fb_u_vs_x_line_0050.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1fb_u_vs_x_line_0050.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_temp.append(tmap_sol['temp'])
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1fb/gold/ver-1fb_u_vs_x_line_0100.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1fb_u_vs_x_line_0100.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_temp.append(tmap_sol['temp'])
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1fb/gold/ver-1fb_u_vs_x_line_0500.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1fb_u_vs_x_line_0500.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_temp.append(tmap_sol['temp'])

analytical_x = tmap_x
To = 300
T1 = 400
alpha = 1.0
L = 4.0
time = [0.1, 0.5, 1.0, 5.0]

analytical_temp = []
for i in range(len(time)):
    analytical_temp.append(To + (T1-To) * (1 - (analytical_x/L) - (2/L) *
                           summation_terms(num_summation_terms, analytical_x, time[i], alpha)))

ax.scatter(analytical_x,
           analytical_temp[0], label=r"Analytical 0.1 seconds", c='k', marker='^')
ax.scatter(analytical_x,
           analytical_temp[1], label=r"Analytical 0.5 seconds", c='r', marker='^')
ax.scatter(analytical_x,
           analytical_temp[2], label=r"Analytical 1.0 seconds", c='b', marker='^')
ax.scatter(analytical_x,
           analytical_temp[3], label=r"Analytical 5.0 seconds", c='c', marker='^')

ax.plot(tmap_x, tmap_temp[0], label=r"TMAP8 0.1 seconds", c='k')
ax.plot(tmap_x, tmap_temp[1], label=r"TMAP8 0.5 seconds", c='r')
ax.plot(tmap_x, tmap_temp[2], label=r"TMAP8 1.0 seconds", c='b')
ax.plot(tmap_x, tmap_temp[3], label=r"TMAP8 5.0 seconds", c='c')


ax.set_xlabel(u'Distance along slab (m)')
ax.set_ylabel(u"Temperature (K)")
ax.legend(loc="best")
# ax.set_xlim(left=0)
ax.set_ylim(bottom=300)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap_temp[0]-analytical_temp[0])**2) ) # 0.1 seconds
RMSPE = RMSE*100/np.mean(analytical_temp[0])
ax.text(2.75,355, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='k')
RMSE = np.sqrt(np.mean((tmap_temp[1]-analytical_temp[1])**2) ) # 0.5 seconds
RMSPE = RMSE*100/np.mean(analytical_temp[1])
ax.text(2.75,350, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='r')
RMSE = np.sqrt(np.mean((tmap_temp[2]-analytical_temp[2])**2) ) # 1.0 seconds
RMSPE = RMSE*100/np.mean(analytical_temp[2])
ax.text(2.75,345, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='b')
RMSE = np.sqrt(np.mean((tmap_temp[3]-analytical_temp[3])**2) ) # 5.0 seconds
RMSPE = RMSE*100/np.mean(analytical_temp[3])
ax.text(2.75,340, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c='c')
ax.minorticks_on()
plt.savefig('ver-1fb_comparison_temperature.png', bbox_inches='tight', dpi=300)
plt.close(fig)
