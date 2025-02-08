import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ============ Comparison of permeation as a function of time =================
# ========================= Diffusion limited =================================
num_summation_terms = 1000

# Reference 1:
# Verification and Validation of Tritium Transport code TMAP7
# Glen Longhurst & James Ambrosek, Fusion Science & Technology 2017


# Reference 2:
# GR Longhurst, SL Harms, ES Marwil, and BG Miller. Verification and validation of
# tmap4. Technical Report, EG and G Idaho, Inc., Idaho Falls, ID (United States), 1992.

# For convenience lattice density chosen as 3.1622e22 atom/m^3 [Reference 1]
N_o = 3.1622e22

# Rest of the parameters based on reference 2.

lambdaa = 3.1622e-8     # lattice parameter (m) || lambda is a python keyword
nu = 1e13               # Debye frequency (1/s)
rho = 0.1               # trapping site fraction
D_o = 1                 # diffusivity pre-exponential (m^2/s)
Ed = 0                  # diffusion activation energy

k = 1.38064852e-23      # Boltzmann's constant(m^2-kg / sec^2-K)
T = 1000                # temperature (K)
epsilon_k_ratio = 100
epsilon = k * epsilon_k_ratio  # epsilon: trap energy
c = 0.0001              # dissolved gas atom fraction
zeta = ((lambdaa**2) * nu * np.exp((Ed - epsilon) /
        (k * T)) / (rho * D_o)) + (c / rho)

D = 1.0                 # diffusivity (m^2/s)
D_eff = D / (1 + (1/zeta))   # Effective diffusivity (m^2/s)
l = 1                   # slab thickness (m)
c_o = c
tau_be = l**2 / (2 * (np.pi)**2 * D_eff)


def summation_term(num_terms, time):
    sum = 0.0
    for m in range(1, num_terms):
        sum += (-1)**m * np.exp(-1 * m**2 * time / (2*tau_be))
    return sum

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1d/gold/ver-1d-diffusion_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1d-diffusion_out.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_time = tmap_sol['time']
tmap_perm = tmap_sol['scaled_outflux']
idx = np.where(tmap_time >= 0.4)[0][0]

c_o = c
analytical_time = tmap_time
Jp = N_o * (c_o * D / l) * \
    (1 + 2 * summation_term(num_summation_terms, analytical_time))

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

analytical_permeation = Jp
ax.plot(analytical_time, analytical_permeation,
        label=r"Analytical", c='k', linestyle='--')

ax.plot(tmap_time, tmap_perm, label=r"TMAP8", c='tab:gray')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(u"Permeation (atom/m$^2$s)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap_perm-analytical_permeation)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_permeation[idx:])
ax.text(1.0,0.5e18, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1d_comparison_diffusion.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ========================= Trapping limited ====================================
tau_bd = l**2 * rho / (2 * c_o * D)  # breakthrough time

analytical_time = [tau_bd, tau_bd]
# Adding numbers according to the range of axis
# to show the line for analytically calculated
# breakthrough time.
analytical_sol = [0, 3.2e18]

if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1d/gold//ver-1d-trapping_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold//ver-1d-trapping_out.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_time = tmap_sol['time']
tmap_perm = tmap_sol['scaled_outflux']
tmap_min_trapped = tmap_sol['min_trapped']

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap_time, tmap_perm, label=r"TMAP8", c='tab:gray')
ax.plot(analytical_time, analytical_sol,
        label=r"Analytical breakthrough time", c='k', linestyle='--')

print(tmap_time[np.argmin(np.abs(tmap_perm-3.1622e18))])

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(u"Permeation (atom/m$^2$s)")
ax.legend(loc="lower right")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1d_comparison_trapping.png', bbox_inches='tight', dpi=300)
plt.close(fig)
