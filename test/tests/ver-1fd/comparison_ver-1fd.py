import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os
import math
from scipy.special import erfc
from numpy import sqrt, exp

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

#===============================================================================
# Extract TMAP8 results
tmap8_sol = pd.read_csv("./gold/ver-1fd_out.csv")
tmap8_sol_t = tmap8_sol['time']
tmap8_sol_temperature = tmap8_sol['temperature_at_x']

#===============================================================================
# Calculate analytical solution
def get_analytical_solution(x,t_vect):
    """Returns the temperature as a function of the distance to the left side of the domain and time

    Args:
        x (float): distance in m
        t_vect (ndarray): time in s

    Returns:
        np.array: temperature in K at position x
    """
    T_initial = 100 # K
    T_infinity = 500 # K
    h = 200 # W/m^2/K)
    k = 401 # W/m/K
    rho_Cp = 3.439e6 # J/m^3/K
    alpha = k/rho_Cp # ~1.17e-4 m^2/s
    small_value = 1e-42 # to avoid division by 0

    temperature = T_initial + (T_infinity - T_initial) * (erfc(x/(2 * sqrt(t_vect * alpha) + small_value)) - exp(h*x/k + h*h*t_vect*alpha/k/k)*erfc(x/(2 * sqrt(t_vect * alpha) + small_value) + h*sqrt(t_vect * alpha)/k))
    return temperature

analytical_sol_temperature = get_analytical_solution(5e-2,tmap8_sol_t)

#===============================================================================
# Plot temperature evolution as a function of time (at x = 0.05 m)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_sol_t,tmap8_sol_temperature,label=r"TMAP8",c='tab:gray')
ax.plot(tmap8_sol_t,analytical_sol_temperature,label=r"Analytical",c='k', linestyle='--')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Temperature (K)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_t))
ax.set_ylim(bottom=100)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# Root Mean Square Percentage Error calculations
RMSE = np.sqrt(np.mean((tmap8_sol_temperature-analytical_sol_temperature)**2))
err_percent = RMSE*100/np.mean(analytical_sol_temperature)
ax.text(900, 155, 'RMSPE = %.2f '%err_percent+'%',fontweight='bold')
plt.savefig('ver-1fd_comparison_convective_heating.png', bbox_inches='tight');
plt.close(fig)
