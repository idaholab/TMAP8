import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Physical constants
kb = 1.380649e-23  # J/K Boltzmann constant
R = 8.31446261815324 # J/mol/K Gas constant

def get_roots_TMAP4(L, alpha_max, step=0.0001):
    # https://stackoverflow.com/questions/28766692/how-to-find-the-intersection-of-two-graphs/28766902#28766902
    """Gets the roots of alpha = L / tan(alpha)

    Args:
        L (float): parameter L
        alpha_max (float): the maximum alpha to consider
        step (float, optional): the step discretizing alphas.
            The smaller the step, the more accurate the roots.
            Defaults to 0.0001.

    Returns:
        np.array: array of roots
    """
    alphas = np.arange(0, alpha_max, step=step)[1:]
    # Define graph as alphas
    f = alphas
    # Define graph as L / tan(alphas)
    g = L / np.tan(alphas)
    # Find intersections of the two graphs
    idx = np.argwhere(np.diff(np.sign(f - g))).flatten()
    # remove one every other idx
    idx = idx[::2]
    roots = alphas[idx]
    return roots

def analytical_expression_fractional_release_TMAP4(t,P_0, D, S, V, T, A, l):
    """
    Analytical expression for the fractional release given by TMAP4 report

    Taken from the TMAP4 V&V Report (https://doi.org/10.2172/10174725)

    Args:
        t (float, ndarray): time (s)
        P_0 (float): initial presure (Pa)
        D (float): diffusivity (m2/s)
        S (float): solubility (H/m3/Pa)
        V (float): enclosure volume (m3)
        T (float): temperature (K)
        A (float): enclosure surface area (m2)
        l (float): slab length (m)
    """
    source_concentration = P_0 / kb / T
    layer_concentration = S * P_0
    phi = source_concentration / layer_concentration
    L = l * A / (V * phi)
    roots = get_roots_TMAP4(L=L, alpha_max=2000, step=3e-4)
    roots = roots[:, np.newaxis]
    sec = 1 / np.cos(roots)
    summation = (2 * L * sec * np.exp(-(roots**2) * D * t / l**2)) / (L * (L + 1) + roots**2)
    summation = np.sum(summation, axis=0)
    fractional_release = 1 - summation
    return fractional_release

def get_roots_TMAP7(L, l, alpha_max, step=0.0001):
    # https://stackoverflow.com/questions/28766692/how-to-find-the-intersection-of-two-graphs/28766902#28766902
    """Gets the roots of alpha = L / tan(alpha * l)

    Args:
        L (float): parameter L
        l (float): parameter l
        alpha_max (float): the maximum alpha to consider
        step (float, optional): the step discretizing alphas.
            The smaller the step, the more accurate the roots.
            Defaults to 0.0001.

    Returns:
        np.array: array of roots
    """
    alphas = np.arange(0, alpha_max, step=step)[1:]
    # Define graph as alphas
    f = alphas
    # Define graph as L / tan(alphas*l)
    g = L / np.tan(alphas*l)
    # Find intersections of the two graphs
    idx = np.argwhere(np.diff(np.sign(f - g))).flatten()
    # remove one every other idx
    idx = idx[::2]
    roots = alphas[idx]
    return roots

def analytical_expression_fractional_release_TMAP7(t, P_0, D, S, V, T, A, l):
    """
    FR = 1 - P(t) / P_0
    where P(t) is the pressure at time t and P_0 is the initial pressure

    Taken from the TMAP7 V&V Report (https://doi.org/10.2172/952009)
    Equations 2, 3, 4, and 5

    Note: in the report, the expression of FR is given as P(T)/P_0, but it shown as 1 - P(t)/P_0 in the graph (Figure 1)
    Args:
        t (float, ndarray): time (s)
        P_0 (float): initial presure (Pa)
        D (float): diffusivity (m2/s)
        S (float): solubility (atoms/m3/Pa)
        V (float): enclosure volume (m3)
        T (float): temperature (K)
        A (float): enclosure surface area (m2)
        l (float): slab length (m)
    """
    L = S * T * A * kb / V
    roots = get_roots_TMAP7(L=L, l=l, alpha_max=1e7, step=1)
    roots = roots[:, np.newaxis]
    summation = np.exp(-(roots**2) * D * t) / (l * (roots**2 + L**2) + L)
    summation = np.sum(summation, axis=0)
    pressure = 2 * P_0 * L * summation
    fractional_release = 1 - pressure / P_0
    return fractional_release

def analytical_expression_flux(t, P_0, D, S, V, T, A, l):
    """
    value of the flux at the external surface (not in contact with enclosure)
    J = -D * dc/dx

    Taken from the TMAP7 V&V Report (https://doi.org/10.2172/952009)
    Equations 3 and 7

    Args:
        t (float, ndarray): time (s)
        P_0 (float): initial presure (Pa)
        D (float): diffusivity (m2/s)
        S (float): solubility (H/m3/Pa)
        V (float): enclosure volume (m3)
        T (float): temperature (K)
        A (float): enclosure surface area (m2)
        l (float): slab length (m)
    """
    L = S * T * A * kb / V
    roots = get_roots_TMAP7(L=L, l=l, alpha_max=1e7, step=1)
    roots = roots[:, np.newaxis]
    summation = (np.exp(-(roots**2) * D * t) * roots) / (
        (l * (roots**2 + L**2) + L) * np.sin(roots * l)
    )
    last_term = summation[-1]
    summation = np.sum(summation, axis=0)
    flux = 2 * S * P_0 * L * D * summation
    return flux

# Extract data from 'gold' TMAP8 run
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/ver-1a/gold/ver-1a_csv.csv"
else:                                  # if in test folder
    csv_folder = "./gold/ver-1a_csv.csv"
tmap8_prediction = pd.read_csv(csv_folder)
tmap8_time = tmap8_prediction['time']
tmap8_release_fraction_right = tmap8_prediction['released_fraction_right']
tmap8_release_fraction_left = tmap8_prediction['released_fraction_left']
tmap8_flux_right = tmap8_prediction['flux_surface_right'] # at/microns^2/s
tmap8_flux_right = tmap8_flux_right*1e6*1e6 # at/m^2/s
idx = np.where(tmap8_time >= 1.0)[0][0]

# time_analytical = np.linspace(0, 140, 1000)
time_analytical = np.array(tmap8_time)
T=2373
P_0=1e6
D=1.58e-4*np.exp(-308000.0/(R*T))
S=7.244e22 / T
V=5.20e-11
A=2.16e-6
l=3.30e-5
analytical_release_fraction_TMAP4 = analytical_expression_fractional_release_TMAP4(
    t=time_analytical,
    P_0=P_0,
    D=D,
    S=S,
    V=V,
    T=T,
    A=A,
    l=l,
)
analytical_release_fraction_TMAP7 = analytical_expression_fractional_release_TMAP7(
    t=time_analytical,
    P_0=P_0,
    D=D,
    S=S,
    V=V,
    T=T,
    A=A,
    l=l,
)
analytical_flux_TMAP7 = analytical_expression_flux(
    t=time_analytical,
    P_0=P_0,
    D=D,
    S=S,
    V=V,
    T=T,
    A=A,
    l=l,
)

# Plot figure for verification of release fraction as determined in TMAP4 (SiC outer layer)
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_release_fraction_right,label=r"TMAP8",c='tab:gray')
ax.plot(time_analytical,analytical_release_fraction_TMAP4,label=r"Analytical (TMAP4)",c='k', linestyle='--')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Fractional release")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=140)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap8_release_fraction_right-analytical_release_fraction_TMAP4)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_release_fraction_TMAP4[idx:])
ax.text(60,0.6, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1a_comparison_analytical_TMAP4_release_fraction.png', bbox_inches='tight', dpi=300);
plt.close(fig)

# Plot figure for verification of release fraction as determined in TMAP7 (SiC inner layer)
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_release_fraction_left,label=r"TMAP8",c='tab:gray')
ax.plot(time_analytical,analytical_release_fraction_TMAP7,label=r"Analytical (TMAP7)",c='k', linestyle='--')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Fractional release")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=140)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap8_release_fraction_left-analytical_release_fraction_TMAP7)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_release_fraction_TMAP7[idx:])
ax.text(40,0.6, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1a_comparison_analytical_TMAP7_release_fraction.png', bbox_inches='tight', dpi=300);
plt.close(fig)

# Plot figure for verification of flux as determined in TMAP7 (SiC outer layer)
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.plot(tmap8_time,tmap8_flux_right,label=r"TMAP8",c='tab:gray')
ax.plot(time_analytical,analytical_flux_TMAP7,label=r"Analytical (TMAP7)",c='k', linestyle='--')
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(r"Flux at outer surface (atoms/m$^2$/s)")
ax.legend(loc="best")
ax.set_xlim(left=0)
ax.set_xlim(right=140)
ax.set_ylim(bottom=0)
plt.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((tmap8_flux_right-analytical_flux_TMAP7)[idx:]**2) )
RMSPE = RMSE*100/np.mean(analytical_flux_TMAP7 [idx:])
ax.text(60,0.6e19, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
ax.minorticks_on()
plt.savefig('ver-1a_comparison_analytical_TMAP7_flux.png', bbox_inches='tight', dpi=300);
plt.close(fig)
