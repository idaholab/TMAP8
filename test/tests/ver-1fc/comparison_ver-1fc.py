import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
os.chdir(os.path.dirname(__file__))

#===============================================================================
# Extract TMAP8 results (both steady-state and transient)
tmap8_sol_steady_state = pd.read_csv("./gold/ver-1fc_vector_postproc_line_0063.csv")
tmap8_sol_steady_state_x = tmap8_sol_steady_state['id']
tmap8_sol_steady_state_temperature = tmap8_sol_steady_state['temperature']

tmap8_sol_transient = pd.read_csv("./gold/ver-1fc_vector_postproc_line_0032.csv")
tmap8_sol_transient_x = tmap8_sol_transient['id']
tmap8_sol_transient_temperature = tmap8_sol_transient['temperature']

tmap8_sol_transient = pd.read_csv("./gold/ver-1fc_temperature_at_x0.09.csv")
tmap8_sol_transient_t = tmap8_sol_transient['time']
tmap8_sol_transient_temperature_at_x = tmap8_sol_transient['temperature_at_x']


#===============================================================================
# Extract ABAQUS results (for transient only since the steady-state results were not provided)
abaqus_sol_transient = pd.read_csv("./ver-1fc_abaqus_TMAP7_results_over_distance.csv")
abaqus_sol_transient_x = abaqus_sol_transient['Distance']
abaqus_sol_transient_temperature_1 = abaqus_sol_transient['abaqus_or_TMAP7_temperature_transient_1']
abaqus_sol_transient_temperature_2 = abaqus_sol_transient['abaqus_or_TMAP7_temperature_transient_2']

abaqus_sol_transient = pd.read_csv("./ver-1fc_abaqus_TMAP7_results_over_time.csv")
abaqus_sol_transient_t = abaqus_sol_transient['time']
abaqus_sol_transient_temperature_at_x = abaqus_sol_transient['abaqus_temperature_transient']
tmap7_sol_transient_temperature_at_x = abaqus_sol_transient['TMAP7_temperature_transient']

#===============================================================================
# Calculate analytical solution (steady-state)

def get_analytical_solution_steady_state(x):
    """Returns the temperature as a function of the distance to the left side of the domain

    Args:
        x (ndarray): distance in m

    Returns:
        np.array: temperature in K at position x
    """
    T_SA = 600  # K
    T_SB = 0    # K
    L_A = 40e-2 # m
    L_B = 40e-2 # m
    k_A = 401   # W/m/K
    k_B = 80.2  # W/m/K
    # calculate interface temperature
    T_I = (T_SA*k_A/L_A + T_SB*k_B/L_B)/(k_A/L_A + k_B/L_B)

    # determine temperature at position x by linear interpolation (steady-state)
    temperature = []
    for i in range(len(x)):
        if x[i]<=L_A:
            temperature.append((T_I-T_SA)/L_A*x[i] + T_SA)
        else:
            temperature.append((T_SB-T_I)/L_B*(x[i]-L_A-L_B) + T_SB)

    return temperature

analytical_sol_steady_state_x = get_analytical_solution_steady_state(tmap8_sol_steady_state_x)

#===============================================================================
# Plot temperature profile for steady-state

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_sol_steady_state_x,tmap8_sol_steady_state_temperature,label=r"TMAP8",c='tab:gray')
ax.plot(tmap8_sol_steady_state_x,analytical_sol_steady_state_x,label=r"Analytical",c='k', linestyle='--')
ax.set_xlabel(u'Distance (m)')
ax.set_ylabel(r"Temperature (K)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_steady_state_x))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# Root Mean Square Percentage Error calculations
RMSE = np.linalg.norm(tmap8_sol_steady_state_temperature-analytical_sol_steady_state_x)
err_percent = RMSE*100/np.mean(analytical_sol_steady_state_x)
ax.text(0.55, 400, 'RMSPE = %.2f '%err_percent+'% \n',fontweight='bold')
plt.savefig('ver-1fc_comparison_temperature_steady_state.png', bbox_inches='tight');
plt.close(fig)

#===============================================================================
# Plot temperature profile as a function of distance for transient (at t = 150 s)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_sol_transient_x,tmap8_sol_transient_temperature,label=r"TMAP8",c='tab:gray')
ax.plot(abaqus_sol_transient_x,abaqus_sol_transient_temperature_1,'b^',label=r"ABAQUS or TMAP7 (1)",mfc='none')
ax.plot(abaqus_sol_transient_x,abaqus_sol_transient_temperature_2,'ro',label=r"ABAQUS or TMAP7 (2)",mfc='none')
ax.set_xlabel(u'Distance (m)')
ax.set_ylabel(r"Temperature (K)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_transient_x))
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1fc_comparison_temperature_transient_t150.png', bbox_inches='tight');
plt.close(fig)

#===============================================================================
# Plot temperature evolution as a function of time for transient (at x = 0.09 m)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_sol_transient_t,tmap8_sol_transient_temperature_at_x,label=r"TMAP8",c='tab:gray')
ax.plot(abaqus_sol_transient_t,abaqus_sol_transient_temperature_at_x,'b^',label=r"ABAQUS",mfc='none')
ax.plot(abaqus_sol_transient_t,tmap7_sol_transient_temperature_at_x,'ro',label=r"TMAP7",mfc='none')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Temperature (K)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=max(tmap8_sol_transient_t)/10)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('ver-1fc_comparison_temperature_transient_x0.09.png', bbox_inches='tight');
plt.close(fig)

