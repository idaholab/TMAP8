import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ===============================================================================
# Physical constants
kb = 1.380649e-23  # J/K Boltzmann constant
eV_to_J = 1.60218e-19  # J/eV
amu_to_kg = 1.6605390666e-27  # kg/amu

# ===============================================================================
# Extract TMAP8 results
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1id/gold/ver-1id_out.csv"
else:  # if in test folder
    csv_folder = "./gold/ver-1id_out.csv"
tmap8_solution = pd.read_csv(csv_folder)
tmap8_solution_time = tmap8_solution["time"]
tmap8_solution_B2 = tmap8_solution["pressure_B2"]
tmap8_solution_A2 = tmap8_solution["pressure_A2"]
tmap8_solution_AB = tmap8_solution["pressure_AB"]


# ===============================================================================
# Calculate analytical solution
def get_analytical_solution(numerical_steps):

    T = 1000  # K Temperature
    V = 1.0  # m^3 Volume
    S = 0.0025  # m^2 Area
    p0_A2 = 1e4  # Pa Initial pressure for A2
    p0_B2 = 1e4  # Pa Initial pressure for B2
    M = 2 * amu_to_kg  # kg mass of species molecules
    E_x = 0.20 * eV_to_J  # J deposition energy
    E_c = -0.01 * eV_to_J  # J release energy
    E_b = 0.00 * eV_to_J  # J dissociation energy
    nu = 8.4e12  # m/s Debye frequency
    K_d = (
        1.0 / np.sqrt(2 * np.pi * M * kb * T) * np.exp(-E_x / kb / T)
    )  # s/kg/m deposition coefficient
    K_r = nu * np.exp((E_c - E_x) / kb / T)  # m/s release coefficient
    K_b = nu * np.exp(-E_b / kb / T)  # m/s dissociation coefficient

    tau = V / S / kb / T * (K_r + K_b) / K_d / K_b
    p_AB_analytical = (
        2 * p0_A2 * p0_B2 / (p0_A2 + p0_B2) * (1 - np.exp(-numerical_steps / tau))
    )
    return p_AB_analytical


p_AB_analytical = get_analytical_solution(tmap8_solution_time)

# ===============================================================================
# Plot concentration evolution as a function of time
# Recreates TMAP4 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(
    tmap8_solution_time,
    tmap8_solution_A2,
    label=r"$A_2$ TMAP8",
    c="tab:brown",
    alpha=alpha,
)
ax.plot(
    tmap8_solution_time,
    tmap8_solution_B2,
    label=r"$B_2$ TMAP8",
    c="tab:cyan",
    alpha=alpha,
    linestyle="--",
)
ax.plot(
    tmap8_solution_time,
    tmap8_solution_AB,
    label=r"$AB$ TMAP8",
    c="tab:gray",
    linestyle="-",
)
ax.plot(
    tmap8_solution_time,
    p_AB_analytical,
    label=r"$AB$ Analytical",
    c="k",
    linestyle="--",
)

ax.set_xlabel("Time (s)")
ax.set_ylabel(r"Partial Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_solution_time))
ax.set_ylim(bottom=0)
plt.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_AB = np.linalg.norm(tmap8_solution_AB - p_AB_analytical)
RMSPE_AB = RMSE_AB * 100 / np.mean(p_AB_analytical)
ax.text(5.5, 0.85e4, f"(AB) RMSPE = {RMSPE_AB:.2f} %", fontweight="bold", color="k")

plt.savefig("ver-1id_comparison_pressure.png", bbox_inches="tight", dpi=300)
plt.close(fig)
