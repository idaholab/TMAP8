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
# Physical constants
kb = 1.380649e-23  # J/K Boltzmann constant

# ===============================================================================
# Extract TMAP8 results
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1if/gold/ver-1if_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1if_out.csv"
tmap8_solution = pd.read_csv(csv_folder)
tmap8_solution_time = tmap8_solution['time']
tmap8_solution_B2 = tmap8_solution['pressure_B2']
tmap8_solution_A2 = tmap8_solution['pressure_A2']
tmap8_solution_AB = tmap8_solution['pressure_AB']

# Extract TMAP7 results
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1if/gold/simulation_data_TMAP7.csv"
else:                                  # if in test folder
    csv_folder = "./gold/simulation_data_TMAP7.csv"
tmap7_solution = pd.read_csv(csv_folder)
tmap7_solution_time = tmap7_solution['x']
tmap7_solution_AB = tmap7_solution['y']


# ===============================================================================
# Calculate analytical solution
def get_analytical_solution(numerical_steps):

    T = 1000 # K Temperature
    V = 1.0 # m^3 Volume
    S = 0.0025 # m^2 Area
    p0_A2 = 1e4 # Pa Initial pressure for A2
    p0_B2 = 1e5 # Pa Initial pressure for B2
    K_d = 1.858e24 / np.sqrt(T) # at.m^-2/s/pa dissociation rate for AB
    time_constant = 0.123

    p_AB_analytical_ratedep = 2 * p0_A2 * p0_B2 * (1 - np.exp(- S * K_d * kb * T * numerical_steps / V)) / (p0_A2 + p0_B2)
    p_AB_analytical_tao = 2 * p0_A2 * p0_B2 * (1 - np.exp(- numerical_steps / time_constant)) / (p0_A2 + p0_B2)
    return p_AB_analytical_tao, p_AB_analytical_ratedep


p_AB_analytical, p_AB_analytical_ratedep = get_analytical_solution(tmap8_solution_time)

# ===============================================================================
# Plot concentration evolution as a function of time
# Recreates TMAP4 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(tmap8_solution_time, tmap8_solution_A2,
        label=r"$A_2$ TMAP8", c='tab:brown', alpha=alpha)
ax.plot(tmap8_solution_time, tmap8_solution_B2,
        label=r"$B_2$ TMAP8", c='tab:cyan', alpha=alpha)
ax.plot(tmap8_solution_time, tmap8_solution_AB,
        label=r"$AB$ TMAP8", c='tab:gray', linestyle='-')
ax.plot(tmap7_solution_time, tmap7_solution_AB,
        label=r"$AB$ TMAP7", c='tab:orange', linestyle='--')
ax.plot(tmap8_solution_time, p_AB_analytical,
        label=r"$AB$ $\tau = 0.123$ fit", c='k', linestyle='--')
ax.plot(tmap8_solution_time, p_AB_analytical_ratedep,
        label=r"$AB$ in Ratedep Analytical", c='tab:blue', linestyle='--')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Partial Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_solution_time))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_AB = np.linalg.norm(tmap8_solution_AB-p_AB_analytical)
RMSPE_AB = RMSE_AB*100/np.mean(p_AB_analytical)
ax.text(1.5, 0.95e4, f'(AB) RMSPE = {RMSPE_AB:.2f} %', fontweight='bold', color='k')

plt.savefig('ver-1if_comparison_pressure.png', bbox_inches='tight', dpi=300)
plt.close(fig)

