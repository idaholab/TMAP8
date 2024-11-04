import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Calculate analytical solution

def get_analytical_solution(x):
    """Returns the temperature as a function of the distance to the left side of the domain

    Args:
        x (ndarray): distance in m

    Returns:
        np.array: temperature in K at position x
    """
    Ts = 300  # K
    k = 10    # W/m/K
    L = 1.6   # m
    Q = 10000 # W/m^3
    # calculate temperature
    temperature = Ts + Q*L**2 * (1- x**2/L**2) / (2*k)

    return temperature

#===============================================================================
# Extract TMAP8 results

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1fa/gold/ver-1fa_csv_line_0011.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1fa_csv_line_0011.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_x = tmap_sol['id']
tmap_temp = tmap_sol['temp']

#===============================================================================
# Calculate analytical solution

analytical_temp = get_analytical_solution(tmap_x)

#===============================================================================
# Plot temperature profile

fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap_x,tmap_temp,label=r"TMAP8",c='tab:gray')
ax.plot(tmap_x,analytical_temp,linestyle='--',label=r"Analytical",c='k')

ax.set_xlabel(u'Distance along slab (m)')
ax.set_ylabel(u"Temperature (K)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap_temp-analytical_temp)**2) )
RMSPE = RMSE*100/np.mean(analytical_temp)
ax.text(0.5,1000, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1fa_comparison_temperature.png', bbox_inches='tight', dpi=300);
plt.close(fig)
