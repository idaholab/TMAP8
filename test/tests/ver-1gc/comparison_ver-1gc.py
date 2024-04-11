import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os
import math
from numpy import exp

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

#===============================================================================
# Extract TMAP8 results
tmap8_sol = pd.read_csv("./gold/ver-1gc_out.csv")
tmap8_sol_time = tmap8_sol['time']
tmap8_sol_concentration_A = tmap8_sol['concentration_A']
tmap8_sol_concentration_B = tmap8_sol['concentration_B']
tmap8_sol_concentration_C = tmap8_sol['concentration_C']

# conversion from atoms/microns^3 to atoms/m^3
tmap8_sol_concentration_A *= 1e18
tmap8_sol_concentration_B *= 1e18
tmap8_sol_concentration_C *= 1e18

#===============================================================================
# Calculate analytical solution
def get_analytical_solution(t_vect):
    """Returns the concentration of the A, B, and C species as a function of time
    Args:
        t_vect (ndarray): time in s
    Returns:
        concentration_A (np.array): concentration of species A in atoms/m^3
        concentration_B (np.array): concentration of species B in atoms/m^3
        concentration_C (np.array): concentration of species C in atoms/m^3
    """
    k_1 = 0.0125 # 1/s
    k_2 = 0.0025 # 1/s
    concentration_A_0 = 2.415e14 # atoms/m^3

    concentration_A = concentration_A_0 * exp(-k_1 * t_vect)
    concentration_B = k_1 * concentration_A_0 * (exp(-k_1 * t_vect) - exp(-k_2 * t_vect)) / (k_2-k_1)
    concentration_C = concentration_A_0 - concentration_A - concentration_B

    return concentration_A, concentration_B, concentration_C

#===============================================================================
# Plot concentration evolution as a function of time

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(tmap8_sol_time,tmap8_sol_concentration_A,label=r"$c_A$ TMAP8",c='tab:pink', alpha = alpha)
ax.plot(tmap8_sol_time,tmap8_sol_concentration_B,label=r"$c_B$ TMAP8",c='tab:blue', alpha = alpha)
ax.plot(tmap8_sol_time,tmap8_sol_concentration_C,label=r"$c_C$ TMAP8",c='tab:green', alpha = alpha)
concentration_A, concentration_B, concentration_C = get_analytical_solution(tmap8_sol_time)
ax.plot(tmap8_sol_time,concentration_A,label=r"$c_A$ Analytical",c='m', linestyle='--')
ax.plot(tmap8_sol_time,concentration_B,label=r"$c_B$ Analytical",c='b', linestyle='--')
ax.plot(tmap8_sol_time,concentration_C,label=r"$c_C$ Analytical",c='g', linestyle='--')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_time))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# Root Mean Square Percentage Error calculations
RMSE_A = np.sqrt(np.mean((tmap8_sol_concentration_A-concentration_A)**2))
err_percent_A = RMSE_A*100/np.mean(concentration_A)
ax.text(50, 2.05e14, '(A) RMSPE = %.2f '%err_percent_A+'%',fontweight='bold',color = 'tab:pink')
RMSE_B = np.sqrt(np.mean((tmap8_sol_concentration_B-concentration_B)**2))
err_percent_B = RMSE_B*100/np.mean(concentration_B)
ax.text(80, 1.70e14, '(B) RMSPE = %.2f '%err_percent_B+'%',fontweight='bold',color = 'tab:blue')
RMSE_C = np.sqrt(np.mean((tmap8_sol_concentration_C-concentration_C)**2))
err_percent_C = RMSE_C*100/np.mean(concentration_C)
ax.text(1010, 2.05e14, '(C) RMSPE = %.2f '%err_percent_C+'%',fontweight='bold',color = 'tab:green')
plt.savefig('ver-1gc_comparison_diff_conc.png', bbox_inches='tight');
plt.close(fig)

