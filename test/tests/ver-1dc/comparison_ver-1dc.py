import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os
import git

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

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
rho_1 = 0.1               # trapping site fraction for first trap
rho_2 = 0.15              # trapping site fraction for second trap
rho_3 = 0.2               # trapping site fraction for third trap
D_o = 1                 # diffusivity pre-exponential (m^2/s)
Ed = 0                  # diffusion activation energy

k = 1.38064852e-23      # Boltzmann's constant(m^2-kg / sec^2-K)
T = 1000                # temperature (K)
epsilon_k_ratio_1 = 100
epsilon_k_ratio_2 = 500
epsilon_k_ratio_3 = 800
epsilon_1 = k * epsilon_k_ratio_1  # epsilon: trap energy
epsilon_2 = k * epsilon_k_ratio_2  # epsilon: trap energy
epsilon_3 = k * epsilon_k_ratio_3  # epsilon: trap energy
c = 0.0001              # dissolved gas atom fraction
zeta_1 = ((lambdaa**2) * nu * np.exp((Ed - epsilon_1) /
        (k * T)) / (rho_1 * D_o)) + (c / rho_1)
zeta_2 = ((lambdaa**2) * nu * np.exp((Ed - epsilon_2) /
        (k * T)) / (rho_2 * D_o)) + (c / rho_2)
zeta_3 = ((lambdaa**2) * nu * np.exp((Ed - epsilon_3) /
        (k * T)) / (rho_3 * D_o)) + (c / rho_3)

D = 1.0                 # diffusivity (m^2/s)
D_eff = D / (1 + (1/zeta_1 + 1/zeta_2 + 1/zeta_3))   # Effective diffusivity (m^2/s)
l = 1                   # slab thickness (m)
c_o = c
tau_be = l**2 / (2 * (np.pi)**2 * D_eff)

# analytical results
output_line = f"The trapping parameters for three traps are {zeta_1/(c/rho_1):.2f} c/rho " \
              f"{zeta_2/(c/rho_2):.2f} c/rho, and {zeta_3/(c/rho_3):.2f} c/rho \n" \
              f"The effective diffusivity is {D_eff:.4f} m^2/s \n" \
              f"The breakthrough time is {tau_be:.2f} s"
print(output_line)

def summation_term(num_terms, time):
    sum = 0.0
    for m in range(1, num_terms):
        sum += (-1)**m * np.exp(-1 * m**2 * time / (2*tau_be))
    return sum

# Extract data from 'gold' TMAP8 run
tmap_sol = pd.read_csv(os.path.join(git.Repo('.',search_parent_directories=True).working_tree_dir, "test/tests/ver-1dc/gold/ver-1dc_out.csv"))
tmap_time = tmap_sol['time']
tmap_perm = tmap_sol['scaled_outflux']
idx = np.where(tmap_time >= 3)[0][0]

# Calculate the analytical solution
c_o = c
Jp = N_o * (c_o * D / l) * \
    (1 + 2 * summation_term(num_summation_terms, tmap_time))

# Plot figure for verification
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

analytical_permeation = Jp # analytical solution
ax.plot(tmap_time, analytical_permeation,
        label=r"Analytical", c='k', linestyle='--')
ax.plot(tmap_time, tmap_perm, label=r"TMAP8", c='tab:gray') # numerical solution
ax.set_xlabel(u'Time(s)')
ax.set_ylabel(u"Permeation (atom/m$^2$s)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap_perm-analytical_permeation)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_permeation[idx:])
ax.text(20,2.2e18, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1dc_comparison_diffusion.png', bbox_inches='tight')
plt.close(fig)
