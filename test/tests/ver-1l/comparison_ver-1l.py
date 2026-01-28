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

def analytical_solution_concentration(time,
                                      location,
                                      temperature_gradient,
                                      concentration_initial,
                                      concentration_left,
                                      diffusivity,
                                      soret_coefficient):
    """
    Analytical solution for diffusion with Soret effect.

    Solves transient diffusion equation with thermodiffusion for semi-infinite
    domain with constant temperature gradient.

    Args:
        time (float or array): Time(s) in seconds
        location (float or array): Position(s) in meters
        temperature_gradient (float): Temperature gradient (dT/dx) in K/m
        concentration_initial (float): Initial concentration in mol/m^3
        concentration_left (float): Left boundary concentration in mol/m^3
        diffusivity (float): Diffusion coefficient in m^2/s
        soret_coefficient (float): Soret coefficient in 1/K

    Returns:
        float or array: Concentration at given time(s) and location(s) in mol/m^3
    """
    # necessary constant
    two_sqrt_Dt = 2 * np.sqrt(diffusivity * time)

    #first term
    first_term = 0.5 * \
        special.erfc((temperature_gradient * diffusivity * soret_coefficient * time + location) / two_sqrt_Dt)
    # second term
    second_term = 0.5 * \
        np.exp(-temperature_gradient * soret_coefficient * location) * \
        special.erfc((-temperature_gradient * diffusivity * soret_coefficient * time + location) / two_sqrt_Dt)
    # final result
    concentration_result = (first_term + second_term) * (concentration_left - concentration_initial) + concentration_initial

    return concentration_result

# necessary parameters
thickness = 100 # m
concentration_initial = 0.1 # mol/m^3
diffusivity = 0.1 # m^2/s
soret_coefficient = 50 # 1/K
concentration_left = 100 # mol/m^3
temperature_left = 1 # K
temperature_right = 0 # K
temperature_gradient = (temperature_right - temperature_left) / thickness
analytical_time = np.arange(0, 100, 0.1) # s
analytical_location = np.linspace(0, thickness, 101) # m
node_number = 50

# TMAP8 data: Extract concentration at location data from 'gold' TMAP8 run
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1l/gold/ver-1l_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1l_csv.csv"
tmap8_at_10m_prediction = pd.read_csv(csv_folder)
tmap8_at_10m_time = tmap8_at_10m_prediction['time']
tmap8_at_10m_concentration = tmap8_at_10m_prediction['concentration_point']
# TMAP8 data: Extract concentration at time data from 'gold' TMAP8 run
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1l/gold/ver-1l_vector_postproc_line_0163.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1l_vector_postproc_line_0163.csv"
tmap8_at_100s_prediction = pd.read_csv(csv_folder)
tmap8_at_100s_location = tmap8_at_100s_prediction['x'][:node_number]
tmap8_at_100s_concentration = tmap8_at_100s_prediction['concentration'][:node_number]

# analytical solution: concentration at 10 m
concentration_at_10m = analytical_solution_concentration(
    tmap8_at_10m_time,
    10,
    temperature_gradient,
    concentration_initial,
    concentration_left,
    diffusivity,
    soret_coefficient
)
# analytical solution: concentration at 100 s
concentration_at_100s = analytical_solution_concentration(
    100,
    analytical_location,
    temperature_gradient,
    concentration_initial,
    concentration_left,
    diffusivity,
    soret_coefficient
)[:node_number]

# Plot comparison of TMAP8 vs analytical solution: concentration vs time at x = 10 m
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_at_10m_time, tmap8_at_10m_concentration, label=r"TMAP8",c='tab:gray')
ax.plot(tmap8_at_10m_time, concentration_at_10m, label=r"Analytical", c='k', linestyle='--')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Concentration (mol/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=100)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap8_at_10m_concentration - concentration_at_10m)**2) )
RMSPE = RMSE*100/np.mean(concentration_at_10m)
ax.text(20,5, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1l_comparison_analytical_concentration_location.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# Plot comparison of TMAP8 vs analytical solution: concentration profile at t = 100 s
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_at_100s_location, tmap8_at_100s_concentration, label=r"TMAP8",c='tab:gray')
ax.plot(analytical_location[:node_number], concentration_at_100s, label=r"Analytical", c='k', linestyle='--')
ax.set_xlabel(u'Location (m)')
ax.set_ylabel(r"Concentration (mol/m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=analytical_location[node_number])
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap8_at_100s_concentration - concentration_at_100s)**2) )
RMSPE = RMSE*100/np.mean(concentration_at_100s)
ax.text(20,20, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1l_comparison_analytical_concentration_time.png', bbox_inches='tight', dpi=300)
plt.close(fig)
