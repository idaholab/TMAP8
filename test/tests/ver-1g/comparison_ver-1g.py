import csv
import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special


fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# ==============================================================================

#TMAP4 case
tmap_sol = pd.read_csv("./gold/diff_conc_TMAP4_out.csv")
tmap_time = tmap_sol['time']
tmap_concAB = tmap_sol['conc_ab']
ax.plot(tmap_time, tmap_concAB, linewidth = 1.5, label=r"TMAP8 (TMAP4 case)", c='tab:brown')

#TMAP7 case
tmap_sol = pd.read_csv("./gold/diff_conc_TMAP7_out.csv")
tmap_time = tmap_sol['time']
tmap_concAB = tmap_sol['conc_ab']
ax.plot(tmap_time, tmap_concAB, linewidth = 1.5, label=r"TMAP8 (TMAP7 case)", c='tab:gray')

def get_conc_from_pressure(P):
    R = 8.314462                # Gas constant (https://physics.nist.gov/cgi-bin/cuu/Value?r)
    T = 25+273.15               # Temperature (25 C -> K)
    Na = 6.02214076E23          # Avogadro's constant (https://physics.nist.gov/cgi-bin/cuu/Value?na)
    m3_to_microns3 = 1E18       # Convert m^3 to microns^3
    # Using ideal gas law
    return P*Na/(R*T*m3_to_microns3)

def get_concAB_diff(analytical_time,P_A0,P_B0):
    concA_o = get_conc_from_pressure(P_A0)  # atoms / microns^3
    concB_o = get_conc_from_pressure(P_B0)  # atoms / microns^3
    K = 4.14e3                              # molecule.m^3/atom^2/s
    exponential_term = np.exp(K * analytical_time *
                          (concB_o - concA_o))
    analytical_concAB = concB_o * \
        (1 - exponential_term) / (1 - (concB_o / concA_o) * exponential_term)
    return analytical_concAB

analytical_time = np.linspace(0.0, 40, 20)

#TMAP4
P_A0 = 1E-6                 # Pressure (Pa)
P_B0 = 1E-7                 # Pressure (Pa)

ax.plot(analytical_time, get_concAB_diff(analytical_time,P_A0,P_B0), 'b^',
           label=r"Analytical TMAP4")

#TMAP7
P_A0 = 1E-6                 # Pressure (Pa)
P_B0 = 5E-7                 # Pressure (Pa)

ax.plot(analytical_time, get_concAB_diff(analytical_time,P_A0,P_B0), 'ko',
           label=r"Analytical TMAP7")

ax.set_xlabel(u'Time (seconds)')
ax.set_ylabel(u"Concentration of AB (atoms / $\mu$m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major',
         color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1g_comparison_diff_conc.png', bbox_inches='tight')

plt.close(fig)

# ==============================================================================
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

tmap_sol = pd.read_csv("./gold/equal_conc_out.csv")
tmap_time = tmap_sol['time']
tmap_concAB = tmap_sol['conc_ab']
ax.plot(tmap_time, tmap_concAB, label=r"TMAP8", c='tab:gray')

def get_concAB_equal(analytical_time,P_A0):
    concA_o = get_conc_from_pressure(P_A0)  # atoms / microns^3
    K = 4.14e3                              # molecule.m^3/atom^2/s
    analytical_concAB = concA_o - 1 / (1/concA_o + K*analytical_time)
    return analytical_concAB

analytical_time = np.linspace(0.0, 40, 20)
P_A0 = 1E-6                 # Pressure (Pa) (which is equal to P_B0)

ax.plot(analytical_time, get_concAB_equal(analytical_time,P_A0), 'ko',
           label=r"Analytical")

ax.set_xlabel(u'Time (seconds)')
ax.set_ylabel(u"Concentration of AB (atoms / $\mu$m$^3$)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major',
         color='0.65', linestyle='--', alpha=0.3)

ax.minorticks_on()
plt.savefig('ver-1g_comparison_equal_conc.png', bbox_inches='tight')

plt.close(fig)