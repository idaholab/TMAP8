import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os
import math


script_folder = os.path.dirname(__file__)
# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1hb/gold/ver-1hb_out.csv"
else:  # if in test folder
    csv_folder = "./gold/ver-1hb_out.csv"

# ===============================================================================
# Extract TMAP8 results
tmap8_sol = pd.read_csv(csv_folder)
tmap8_sol_time = tmap8_sol["time"]
tmap8_sol_P1_T = tmap8_sol["P1_T_value"]
tmap8_sol_P2_T = tmap8_sol["P2_T_value"]
tmap8_sol_P1_D = tmap8_sol["P1_D_value"]
tmap8_sol_P2_D = tmap8_sol["P2_D_value"]


# ===============================================================================
# Calculate analytical solution
def get_analytical_solution(t_vect):
    """Returns the pressure and concentration for the 2nd and 3d enclosures as a function of time
    Args:
        t_vect (ndarray): time in s
    Returns:
        P1_T (np.array): pressure of T2 in the 1st enclosure in Pa
        P2_T (np.array): pressure of T2 in the 2nd enclosure in Pa
        P1_D (np.array): concentration of D2 in the 1st enclosure in atoms/m^3
        P2_D (np.array): concentration of D2 in the 2nd enclosure in atoms/m^3
    """
    # Initial pressures of Tritium and Deuterium in the 1st and 2nd enclosures
    P1_T = 1.0  # Pa
    P2_T = 0.0  # Pa
    P1_D = 0.0  # Pa
    P2_D = 1.0  # Pa
    Q = 0.1  # m^3/s
    V = 1  # m^3

    P_ST = (P1_T + P2_T) / 2  # Pa
    P_1T = P_ST + (P1_T - P_ST) * np.exp(-2 * Q * t_vect / V)
    P_2T = P_ST + (P2_T - P_ST) * np.exp(-2 * Q * t_vect / V)

    P_SD = (P1_D + P2_D) / 2  # Pa
    P_1D = P_SD + (P1_D - P_ST) * np.exp(-2 * Q * t_vect / V)
    P_2D = P_SD + (P2_D - P_ST) * np.exp(-2 * Q * t_vect / V)

    return (P_1T, P_2T, P_1D, P_2D)


P_1T, P_2T, P_1D, P_2D = get_analytical_solution(tmap8_sol_time)
# ===============================================================================
# Plot Tritium (T) pressure evolution as a function of time
# Recreates TMAP7 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(
    tmap8_sol_time, tmap8_sol_P1_T, label=r"$P_1T$ TMAP8", c="tab:pink", alpha=alpha
)
ax.plot(
    tmap8_sol_time, tmap8_sol_P2_T, label=r"$P_2T$ TMAP8", c="tab:blue", alpha=alpha
)
ax.plot(tmap8_sol_time, P_1T, label=r"$P_1T$ Analytical", c="m", linestyle="--")
ax.plot(tmap8_sol_time, P_2T, label=r"$P_2T$ Analytical", c="b", linestyle="--")

ax.set_xlabel("Time (s)")
ax.set_ylabel(r"Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_time))
ax.set_ylim(bottom=0)
plt.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_P_1T = np.linalg.norm(tmap8_sol_P1_T - P_1T)
err_percent_P_1T = RMSE_P_1T * 100 / np.mean(P_1T)
ax.text(
    10,
    0.625,
    "($P_1T$) RMSPE = %.2f " % err_percent_P_1T + "%",
    fontweight="bold",
    color="tab:pink",
)
RMSE_P_2T = np.linalg.norm(tmap8_sol_P2_T - P_2T)
err_percent_P_2T = RMSE_P_2T * 100 / np.mean(P_2T)
ax.text(
    10,
    0.375,
    "($P_2T$) RMSPE = %.2f " % err_percent_P_2T + "%",
    fontweight="bold",
    color="tab:blue",
)

plt.savefig("ver-1hb_comparison_pressure_tritium.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# ===============================================================================
# Plot Deuterium (D) pressure evolution as a function of time
# Recreates TMAP7 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(
    tmap8_sol_time, tmap8_sol_P1_D, label=r"$P_1D$ TMAP8", c="tab:pink", alpha=alpha
)
ax.plot(
    tmap8_sol_time, tmap8_sol_P2_D, label=r"$P_2D$ TMAP8", c="tab:blue", alpha=alpha
)
ax.plot(tmap8_sol_time, P_1D, label=r"$P_1D$ Analytical", c="m", linestyle="--")
ax.plot(tmap8_sol_time, P_2D, label=r"$P_2D$ Analytical", c="b", linestyle="--")

ax.set_xlabel("Time (s)")
ax.set_ylabel(r"Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_time))
ax.set_ylim(bottom=0)
plt.grid(which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_P_1D = np.linalg.norm(tmap8_sol_P1_D - P_1D)
err_percent_P_1D = RMSE_P_1D * 100 / np.mean(P_1D)
ax.text(
    10,
    0.375,
    "($P_1D$) RMSPE = %.2f " % err_percent_P_1D + "%",
    fontweight="bold",
    color="tab:pink",
)
RMSE_P_2D = np.linalg.norm(tmap8_sol_P2_D - P_2D)
err_percent_P_2D = RMSE_P_2D * 100 / np.mean(P_2D)
ax.text(
    10,
    0.625,
    "($P_2D$) RMSPE = %.2f " % err_percent_P_2D + "%",
    fontweight="bold",
    color="tab:blue",
)

plt.savefig("ver-1hb_comparison_pressure_deuterium.png", bbox_inches="tight", dpi=300)
plt.close(fig)
