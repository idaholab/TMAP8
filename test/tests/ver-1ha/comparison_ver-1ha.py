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
# Extract TMAP8 results
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1ha/gold/ver-1ha_out.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1ha_out.csv"
tmap8_sol = pd.read_csv(csv_folder)
tmap8_sol_time = tmap8_sol['time']
tmap8_sol_P2 = tmap8_sol['P2_value']
tmap8_sol_P3 = tmap8_sol['P3_value']
tmap8_sol_C2 = tmap8_sol['C2_value']
tmap8_sol_C3 = tmap8_sol['C3_value']


# ===============================================================================
# Calculate analytical solution
def get_analytical_solution(t_vect):
    """Returns the pressure and concentration for the 2nd and 3d enclosures as a function of time
    Args:
        t_vect (ndarray): time in s
    Returns:
        P2 (np.array): pressure of T2 in the 2nd enclosure in Pa
        P3 (np.array): pressure of T2 in the 3rd enclosure in Pa
        C2 (np.array): concentration of T2 in the 2nd enclosure in atoms/m^3
        C3 (np.array): concentration of T2 in the 3rd enclosure in atoms/m^3
    """
    P1 = 1.0  # Pa
    Q = 0.1  # m^3/s
    V2 = 1  # m^3
    V3 = 1  # m^3
    R = 8.31446261815324  # J/K/mol
    T = 303  # K
    N_a = 6.02214076e23  # at/mol

    P2 = P1*(1-np.exp(-Q*tmap8_sol_time/V2))
    if (V2 == V3):
        P3 = P1*(1 - (1 + Q*tmap8_sol_time/V2)*np.exp(-Q*tmap8_sol_time/V2))
    else:
        P3 = P1*(1 - (V2/(V2-V3))*np.exp(-Q*tmap8_sol_time/V2) +
                 (V2/(V2-V3))*np.exp(-Q*tmap8_sol_time/V3))

    # Convert pressures (Pa) to concentrations (atoms/m^3)
    # following ideal gas law
    C2 = P2*N_a/(R*T)
    C3 = P3*N_a/(R*T)
    return (P2, P3, C2, C3)


P2, P3, C2, C3 = get_analytical_solution(
    tmap8_sol_time)

# ===============================================================================
# Plot concentration evolution as a function of time
# Recreates TMAP4 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(tmap8_sol_time, tmap8_sol_C2,
        label=r"$C_2$ TMAP8", c='tab:pink', alpha=alpha)
ax.plot(tmap8_sol_time, tmap8_sol_C3,
        label=r"$C_3$ TMAP8", c='tab:blue', alpha=alpha)
ax.plot(tmap8_sol_time, C2,
        label=r"$C_2$ Analytical", c='m', linestyle='--')
ax.plot(tmap8_sol_time, C3,
        label=r"$C_3$ Analytical", c='b', linestyle='--')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (atoms/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_time))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_C2 = np.linalg.norm(tmap8_sol_C2-C2)
err_percent_C2 = RMSE_C2*100/np.mean(C2)
ax.text(13, 2.25e20, '(C2) RMSPE = %.2f ' %
        err_percent_C2+'%', fontweight='bold', color='tab:pink')
RMSE_C3 = np.linalg.norm(tmap8_sol_C3-C3)
err_percent_C3 = RMSE_C3*100/np.mean(C3)
ax.text(20, 1.125e20, '(C3) RMSPE = %.2f ' %
        err_percent_C3+'%', fontweight='bold', color='tab:blue')

plt.savefig('ver-1ha_comparison_conc.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ===============================================================================
# Plot pressure evolution as a function of time
# Recreates TMAP7 verification plot

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
alpha = 0.6
ax.plot(tmap8_sol_time, tmap8_sol_P2,
        label=r"$P_2$ TMAP8", c='tab:pink', alpha=alpha)
ax.plot(tmap8_sol_time, tmap8_sol_P3,
        label=r"$P_3$ TMAP8", c='tab:blue', alpha=alpha)
ax.plot(tmap8_sol_time, P2,
        label=r"$P_2$ Analytical", c='m', linestyle='--')
ax.plot(tmap8_sol_time, P3,
        label=r"$P_3$ Analytical", c='b', linestyle='--')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Pressure (Pa)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_time))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

# Root Mean Square Percentage Error calculations
RMSE_P2 = np.linalg.norm(tmap8_sol_P2-P2)
err_percent_P2 = RMSE_P2*100/np.mean(P2)
ax.text(13, 0.95, '(P2) RMSPE = %.2f ' %
        err_percent_P2+'%', fontweight='bold', color='tab:pink')
RMSE_P3 = np.linalg.norm(tmap8_sol_P3-P3)
err_percent_P3 = RMSE_P3*100/np.mean(P3)
ax.text(20, 0.55, '(P3) RMSPE = %.2f ' %
        err_percent_P3+'%', fontweight='bold', color='tab:blue')

plt.savefig('ver-1ha_comparison_pressure.png', bbox_inches='tight', dpi=300)
plt.close(fig)
