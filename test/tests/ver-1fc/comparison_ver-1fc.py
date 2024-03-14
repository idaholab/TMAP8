import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special


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


analytical_x = np.linspace(0.0, 4.0, 40)
To = 300
T1 = 400
alpha = 1.0
L = 4.0
time = [0.1, 0.5, 1.0, 5.0]

# analytical_temp = []
# for i in range(len(time)):
#     analytical_temp.append(To + (T1-To) * (1 - (analytical_x/L) - (2/L) *
#                            summation_terms(num_summation_terms, analytical_x, time[i], alpha)))

# ax.scatter(analytical_x,
#            analytical_temp[0], label=r"Analytical 0.1 seconds", c='k', marker='^')
# ax.scatter(analytical_x,
#            analytical_temp[1], label=r"Analytical 0.5 seconds", c='r', marker='^')
# ax.scatter(analytical_x,
#            analytical_temp[2], label=r"Analytical 1.0 seconds", c='b', marker='^')
# ax.scatter(analytical_x,
#            analytical_temp[3], label=r"Analytical 5.0 seconds", c='c', marker='^')

tmap_temp = []
tmap_sol = pd.read_csv("./ver-1fc_out_line_1500.csv")
tmap_x = tmap_sol['id']
tmap_temp.append(tmap_sol['temp'])
# tmap_sol = pd.read_csv("./ver-1fc_out_line_0015.csv")
# tmap_temp.append(tmap_sol['temp'])
# tmap_sol = pd.read_csv("./ver-1fc_out_line_0100.csv")
# tmap_temp.append(tmap_sol['temp'])
# tmap_sol = pd.read_csv("./ver-1fc_out_line_1500.csv")
# tmap_temp.append(tmap_sol['temp'])

ax.plot(tmap_x, tmap_temp[0], label=r"TMAP8 150 seconds", c='k')
# ax.plot(tmap_x, tmap_temp[1], label=r"TMAP8 150 seconds", c='r')
# ax.plot(tmap_x, tmap_temp[2], label=r"TMAP8 1000 seconds", c='b')
# ax.plot(tmap_x, tmap_temp[3], label=r"TMAP8 15000 seconds", c='c')


ax.set_xlabel(u'Distance along slab (m)')
ax.set_ylabel(u"Temperature (K)")
ax.legend(loc="best")
# ax.set_xlim(left=0)
# ax.set_ylim(bottom=300)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1fc_comparison_temperature.png', bbox_inches='tight')
plt.close(fig)
