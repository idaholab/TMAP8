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
tmap8_solution_D2 = tmap8_solution['pressure_D2']
tmap8_solution_H2 = tmap8_solution['pressure_H2']
tmap8_solution_HD = tmap8_solution['pressure_HD']


# ===============================================================================
# Calculate analytical solution
def get_analytical_solution(numerical_steps):

    T = 1000 # K Temperature
    V = 1.0 # m^3 Volume
    S = 0.0025 # m^2 Area
    p0_H2 = 1e4 # Pa Initial pressure for H2
    p0_D2 = 1e5 # Pa Initial pressure for D2
    K_d = 1.858e24 / np.sqrt(T) # at.m^-2/s/pa dissociation rate for HD
    time_constant = 0.123

    p_AB_analytical_ratedep = 2 * p0_H2 * p0_D2 * (1 - np.exp(- S * K_d * kb * T * numerical_steps / V)) / (p0_H2 + p0_D2)
    p_AB_analytical_tao = 2 * p0_H2 * p0_D2 * (1 - np.exp(- numerical_steps / time_constant)) / (p0_H2 + p0_D2)
    # p_AB_analytical_lowPab = 2 * np.sqrt(p0_H2 * p0_D2) * (1 - np.exp(- S * K_d * kb * T * numerical_steps / V))
#     p_AB_analytical_special = 2 * p0_H2 * p0_D2 * (1 - np.exp(- 2 * S * K_d * kb * T * numerical_steps / V)) / (p0_H2 + p0_D2)
    return p_AB_analytical_tao, p_AB_analytical_ratedep


p_AB_analytical, p_AB_analytical_ratedep = get_analytical_solution(tmap8_solution_time)

# ===============================================================================
# Plot concentration evolution as a function of time
# Recreates TMAP4 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(tmap8_solution_time, tmap8_solution_H2,
        label=r"$H_2$ TMAP8", c='tab:brown', alpha=alpha)
ax.plot(tmap8_solution_time, tmap8_solution_D2,
        label=r"$D_2$ TMAP8", c='tab:cyan', alpha=alpha)
ax.plot(tmap8_solution_time, tmap8_solution_HD,
        label=r"$HD$ TMAP8", c='tab:gray', linestyle='-')
ax.plot(tmap8_solution_time, p_AB_analytical,
        label=r"$HD$ 0.123 $\times$ $\tau$ fit", c='k', linestyle='--')
ax.plot(tmap8_solution_time, p_AB_analytical_ratedep,
        label=r"$HD$ in Ratedep Analytical", c='tab:blue', linestyle='--')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Partial Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_solution_time))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_HD = np.linalg.norm(tmap8_solution_HD-p_AB_analytical)
RMSPE_HD = RMSE_HD*100/np.mean(p_AB_analytical)
ax.text(1.5, 0.95e4, f'(HD) RMSPE = {RMSPE_HD:.2f} %', fontweight='bold', color='k')

plt.savefig('ver-1if_comparison_pressure.png', bbox_inches='tight', dpi=300)
plt.close(fig)

