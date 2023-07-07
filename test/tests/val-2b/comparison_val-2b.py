import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special


fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

expt_data = pd.read_csv("./gold/experimental_data.csv")
expt_temp = expt_data['temp']
expt_flux = expt_data['flux']*1e15

ax.scatter(expt_temp, expt_flux,
           label=r"Experiment", c='k', marker='^')

# tmap_sol = pd.read_csv("./val-2b_out.csv") # if you want to plot for the current run
# you should manually remove all the rows in the ./val-2b_out.csv starting from the second
# all the way up the row with temperature around 673K (during temperature ramp up, not cool down).
# We should update this script in future so that the script can itself leave out those rows.

tmap_sol = pd.read_csv("./gold/val-2b_out_short_timeSteps.csv") # for documentation figure
tmap_temp = tmap_sol['Temp']

tmap_flux = tmap_sol['avg_flux_left']*2*1e20 # Factor of 2 because
# symmetry is assumed and only one-half of the specimen is modeled.
# Thus, the total flux coming out of the specimen (per unit area)
# is twice of flux calculated at the left side of the model. Factor
# of 1e20 because in the input file a scale value of 1e20 is used
# to scale down the value of concentration to help with convergence.

ax.plot(tmap_temp, tmap_flux, label=r"TMAP8", c='tab:gray')

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Deuterium flux (atom/m$^2$-s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('val-2b_comparison.png', bbox_inches='tight')
plt.close(fig)
