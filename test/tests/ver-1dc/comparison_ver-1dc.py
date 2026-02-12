import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ============ Comparison of permeation as a function of time =================
# ========================== Multiple Trapps ==================================
num_summation_terms = 1000

# Reference 1:
# Verification and Validation of Tritium Transport code TMAP7
# Glen Longhurst & James Ambrosek, Fusion Science & Technology 2017

# The parameters based on reference 1.
N_o = 3.1622e22  # For convenience lattice density chosen as 3.1622e22 atom/m^3
lambdaa = 3.1622e-8  # lattice parameter (m) || lambda is a python keyword
nu = 1e13  # Debye frequency (1/s)
rho_1 = 0.1  # trapping site fraction for first trap
rho_2 = 0.15  # trapping site fraction for second trap
rho_3 = 0.2  # trapping site fraction for third trap
D_o = 1  # diffusivity pre-exponential (m^2/s)
Ed = 0  # diffusion activation energy

k = 1.38064852e-23  # Boltzmann's constant (m^2 kg / sec^2 / K)
T = 1000  # temperature (K)
epsilon_k_ratio_1 = 100  # epsilon_k_ratio for trap 1 (K)
epsilon_k_ratio_2 = 500  # epsilon_k_ratio for trap 2 (K)
epsilon_k_ratio_3 = 800  # epsilon_k_ratio for trap 3 (K)
epsilon_1 = k * epsilon_k_ratio_1  # epsilon: trap energy for trap 1 (m^2 kg / sec^2)
epsilon_2 = k * epsilon_k_ratio_2  # epsilon: trap energy for trap 2 (m^2 kg / sec^2)
epsilon_3 = k * epsilon_k_ratio_3  # epsilon: trap energy for trap 3 (m^2 kg / sec^2)
c = 0.0001  # dissolved gas atom fraction (-)
zeta_1 = ((lambdaa**2) * nu * np.exp((Ed - epsilon_1) / (k * T)) / (rho_1 * D_o)) + (
    c / rho_1
)
zeta_2 = ((lambdaa**2) * nu * np.exp((Ed - epsilon_2) / (k * T)) / (rho_2 * D_o)) + (
    c / rho_2
)
zeta_3 = ((lambdaa**2) * nu * np.exp((Ed - epsilon_3) / (k * T)) / (rho_3 * D_o)) + (
    c / rho_3
)

D = 1.0  # diffusivity (m^2/s)
D_eff = D / (
    1 + (1 / zeta_1 + 1 / zeta_2 + 1 / zeta_3)
)  # Effective diffusivity (m^2/s)
l = 1  # slab thickness (m)
c_o = c
tau_be = l**2 / (2 * (np.pi) ** 2 * D_eff)

# analytical results
output_line = (
    f"The trapping parameters for three traps are {zeta_1/(c/rho_1):.2f} c/rho "
    f"{zeta_2/(c/rho_2):.2f} c/rho, and {zeta_3/(c/rho_3):.2f} c/rho \n"
    f"The effective diffusivity is {D_eff:.4f} m^2/s \n"
    f"The breakthrough time from analytical solution is {tau_be:.2f} s"
)
print(output_line)


def summation_term(num_terms, time):
    sum = 0.0
    for m in range(1, num_terms):
        sum += (-1) ** m * np.exp(-1 * m**2 * time / (2 * tau_be))
    return sum


# Extract data from 'gold' TMAP8 run
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1dc/gold/ver-1dc_out.csv"
else:  # if in test folder
    csv_folder = "./gold/ver-1dc_out.csv"
tmap_sol = pd.read_csv(csv_folder)
tmap_time = np.array(tmap_sol["time"])
tmap_prediction = np.array(tmap_sol["scaled_outflux"])
idx = np.where(tmap_time >= 3)[0][0]

# Calculate the breakthrough time from the numerical solution
tmap_slope = (tmap_prediction[idx + 1 :] - tmap_prediction[idx:-1]) / (
    tmap_time[idx + 1 :] - tmap_time[idx:-1]
)
tmap_intercept = tmap_time[np.argmax(tmap_slope) + idx] - (
    tmap_prediction[int(np.argmax(tmap_slope) + idx)]
) / np.max(tmap_slope)
output_line = (
    f"The breakthrough time from the numerical solution is {tmap_intercept:.2f} s"
)
print(output_line)

# Calculate the analytical solution
Jp = N_o * (c_o * D / l) * (1 + 2 * summation_term(num_summation_terms, tmap_time))

# Plot figure for verification
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

analytical_permeation = Jp  # analytical solution
ax.plot(tmap_time, analytical_permeation, label=r"Analytical", c="k", linestyle="--")
ax.plot(tmap_time, tmap_prediction, label=r"TMAP8", c="tab:gray")  # numerical solution
ax.plot(
    [tau_be, tau_be],
    [0, 3.15e18],
    label=r"Analytical breakthrough time",
    c="tab:brown",
    linestyle="--",
)
ax.plot(
    [tmap_intercept, 17.5],
    [0, (17.5 - tmap_intercept) * np.max(tmap_slope)],
    label=r"Numerical breakthrough time",
    c="tab:brown",
)
ax.set_xlabel("Time (s)")
ax.set_ylabel("Flux (atom/m$^2$s)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
RMSE = np.sqrt(np.mean((tmap_prediction - analytical_permeation)[idx:] ** 2))
RMSPE = RMSE * 100 / np.mean(analytical_permeation[idx:])
ax.text(20, 2.2e18, "RMSPE = %.2f " % RMSPE + "%", fontweight="bold")
ax.text(
    6.0,
    0.05e18,
    "Numerical breakthrough time = %.2f " % tmap_intercept + "s",
    fontweight="bold",
)
ax.text(
    6.1,
    0.18e18,
    "Analytical breakthrough time = %.2f " % tau_be + "s",
    fontweight="bold",
)
ax.minorticks_on()
plt.savefig("ver-1dc_comparison_diffusion.png", bbox_inches="tight", dpi=300)
plt.close(fig)
