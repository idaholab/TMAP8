import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output):
    """Get new numerical solution based on the experimental input data points

    Args:
        experiment_input (float, ndarray): experimental input data points
        tmap_input (float, ndarray): numerical input data points
        tmap_output (float, ndarray): numerical output data points

    Returns:
        float, ndarray: updated tmap_output based on the data points in experiment_input
    """
    new_tmap_output = np.zeros(len(experiment_input))
    for i in range(len(experiment_input)):
        left_limit = np.argwhere((np.diff(tmap_input < experiment_input[i])))[0][0]
        right_limit = left_limit + 1
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (tmap_input[right_limit] - tmap_input[left_limit]) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[left_limit]
    return new_tmap_output

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2b/gold/experimental_data.csv"
else:                                  # if in test folder
    csv_folder = "./gold/experimental_data.csv"
expt_data = pd.read_csv(csv_folder)
expt_temp = expt_data['temp']
expt_flux = expt_data['flux']*1e15

ax.scatter(expt_temp, expt_flux,
           label=r"Experiment", c='k', marker='^')

# tmap_sol = pd.read_csv("./val-2b_out.csv") # if you want to plot for the current run
# you should manually remove all the rows in the ./val-2b_out.csv starting from the second
# all the way up the row with temperature around 673K (during temperature ramp up, not cool down).
# We should update this script in future so that the script can itself leave out those rows.

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2b/gold/val-2b_out_short_timeSteps.csv"
else:                                  # if in test folder
    csv_folder = "./gold/val-2b_out_short_timeSteps.csv"
tmap_sol = pd.read_csv(csv_folder)
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
tmap_flux_for_rmspe = numerical_solution_on_experiment_input(expt_temp, tmap_temp, tmap_flux)
RMSE = np.sqrt(np.mean((tmap_flux_for_rmspe-expt_flux)**2) )
RMSPE = RMSE*100/np.mean(expt_flux)
ax.text(870,3e16, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('val-2b_comparison.png', bbox_inches='tight')
plt.close(fig)
