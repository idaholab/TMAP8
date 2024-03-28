import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special


# ==============================================================================
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# analytical_time = np.linspace(0.0, 40, 40)
# concA_o = 2.43e-4
# concB_o = 2.43001e-4  # Added 0.00001e-4 to actual value to avoid divide-by-zero
# # error in the analytical solution
# concAB_o = 0
# K = 4.14e3

# exponential_term = np.exp(K * analytical_time *
#                           (concB_o - concA_o))
# analytical_concAB = concB_o * \
#     (1 - exponential_term) / (1 - (concB_o / concA_o) * exponential_term)

# ax.scatter(analytical_time, analytical_concAB,
#            label=r"Analytical", c='k', marker='^')

tmap_sol = pd.read_csv("./ver-1fd_out.csv")
tmap_time = tmap_sol['time']
tmap_temp = tmap_sol['5cm_node_temp']
ax.plot(tmap_time, tmap_temp, label=r"TMAP8", c='tab:blue')

ax.set_xlabel(u'Time (seconds)')
ax.set_ylabel(u"Temperature (K)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=100)
plt.grid(visible=True, which='major',
         color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1fd_comparison.png', bbox_inches='tight')

plt.close(fig)
