import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import gridspec
from matplotlib.patches import Patch
from matplotlib import cm

# ==============================================================================
# Setup: Constants and Paths

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Extract TMAP8 predictions
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    csv_folder = "../../../../test/tests/val-2f/gold/val-2f_out.csv"
    csv_folder_inf_recombination = "../../../../test/tests/val-2f/gold/val-2f_out_inf_recombination.csv"
    csv_folder_exp = "../../../../test/tests/val-2f/gold/0.1_dpa.csv"
else:  # if in test folder
    csv_folder = "./gold/val-2f_out.csv"
    csv_folder_inf_recombination = "./gold/val-2f_out_inf_recombination.csv"
    csv_folder_exp = "./gold/0.1_dpa.csv"

def save_plot(fig, name):
    fig.tight_layout()
    fig.savefig(name, bbox_inches='tight', dpi=300)
    plt.close(fig)

# Time configuration
K_MIN, K_MAX = 300, 1000 # K
HEATING_RATE = 3 / 60 # K/s
CHARGE_TIME = 72 * 3600 # s
COOLDOWN_TIME = 12 * 3600 # s
START_TIME = CHARGE_TIME + COOLDOWN_TIME
DURATION = (K_MAX - K_MIN) / HEATING_RATE
END_TIME = START_TIME + DURATION

def numerical_solution_on_experiment_input(x_exp, x_sim, y_sim):
    return np.interp(x_exp, x_sim, y_sim)

def extract_tmap_data_desorption(df):
    t = df['time']
    temp = df['temperature']

    if 'scaled_flux_surface_left_sieverts' in df.columns and 'scaled_flux_surface_right_sieverts' in df.columns:
        flux_left = abs(df['scaled_flux_surface_left_sieverts'])
        flux_right = abs(df['scaled_flux_surface_right_sieverts'])
    elif 'scaled_flux_surface_left' in df.columns and 'scaled_flux_surface_right' in df.columns:
        flux_left = df['scaled_flux_surface_left']
        flux_right = df['scaled_flux_surface_right']

    flux_total = flux_left + flux_right
    implanted = df['scaled_implanted_deuterium']
    mobile = df['scaled_mobile_deuterium']
    traps = [
        df['scaled_trapped_deuterium_1'],
        df['scaled_trapped_deuterium_2'],
        df['scaled_trapped_deuterium_3'],
        df['scaled_trapped_deuterium_4'],
        df['scaled_trapped_deuterium_5'],
        df['scaled_trapped_deuterium_intrinsic'],
    ]
    total_trapped = sum(traps)
    mask = t >= START_TIME
    return [np.array(v)[mask] for v in [t, temp, flux_left, flux_right, flux_total, implanted, total_trapped, mobile] + traps]

# ==============================================================================
# Load Data

tmap_data = {
    "default": pd.read_csv(csv_folder),
    "inf": pd.read_csv(csv_folder_inf_recombination),
    "exp": pd.read_csv(csv_folder_exp),
}
experiment = tmap_data["exp"]
experiment_temperature = experiment['Temperature (K)']
experiment_flux = experiment['Deuterium Loss Rate (at/s)'] / (12e-3 * 15e-3)

# ==============================================================================
# Figure 1: Implantation distribution

fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])
sigma, R_p, flux = 0.5e-9, 0.7e-9, 5.79e19 # m, m, at/m^2/s
x = np.linspace(0, 6 * sigma, 1000)
gaussian = np.exp(-0.5 * ((x - R_p) / sigma)**2) / (sigma * np.sqrt(2 * np.pi))
source = flux * gaussian

ax.plot(x, source, label='Implantation distribution', color='b')
ax.axvline(R_p + 6 * sigma, color='r', linestyle='--', label=r'$R_p + 6\sigma$')
ax.set(xlabel='x (m)', ylabel=r"Deuterium source (at/m$^3$/s)", xlim=(0, None), ylim=(0, None))
ax.legend(loc='lower left')
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()
save_plot(fig, 'val-2f_implantation_distribution.png')

# ==============================================================================
# Figure 2: Temperature history

fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])
ax.plot(tmap_data["default"]['time']/3600, tmap_data["default"]['temperature'], '--', color='b', label='Temperature')
ax.set(xlabel='Time (h)', ylabel='Temperature (K)', xlim=(0, END_TIME/3600), ylim=(0, None))
ax.legend(loc='lower left')
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()
save_plot(fig, 'val-2f_temperature_history.png')

# ==============================================================================
# Figure 3: TMAP8 vs Experimental

for key, fname in [("default", "val-2f_comparison"),
                   ("inf", "val-2f_comparison_inf_recombination")]:
    _, temp, _, _, flux_total, *_ = extract_tmap_data_desorption(tmap_data[key])
    interp_flux = numerical_solution_on_experiment_input(experiment_temperature, temp, flux_total)
    rmse = np.sqrt(np.mean((interp_flux - experiment_flux)**2))
    rmspe = rmse * 100 / np.mean(experiment_flux)

    fig = plt.figure(figsize=[6.5, 5.5])
    ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])
    ax.plot(temp, flux_total, label="TMAP8 (5 traps)", color='tab:blue')
    ax.scatter(experiment_temperature, experiment_flux, label="Experiment", color='black')
    ax.text(750, 6e16, f'RMSPE = {rmspe:.2f} %', fontweight='bold')
    ax.text(750, 5.5e16, 'Damage = 0.1 dpa')
    ax.set(xlabel='Temperature (K)', ylabel=r"Deuterium flux (at/m$^2$/s)", xlim=(min(temp), max(temp)), ylim=(0, None))
    ax.legend()
    ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
    ax.minorticks_on()
    save_plot(fig, f"{fname}.png")

# ==============================================================================
# Figure 4: Deuterium evolution with curve lines, mobile + intrinsic trap added

cmap = plt.get_cmap('viridis')
colors = cmap(np.linspace(0, 1, 7))
intrinsic_color = 'gray'

for key, fname in [("default", "val-2f_deuterium_desorption"),
                   ("inf", "val-2f_deuterium_desorption_inf_recombination")]:
    (time, temp, _, _, flux_total,
     _, trapped, mobile,
     t1, t2, t3, t4, t5, t_intr) = extract_tmap_data_desorption(tmap_data[key])

    time -= time[0]
    hours = time / 3600
    dt = np.diff(time)
    escaping = np.zeros_like(flux_total)
    for i in range(1, len(flux_total)):
        escaping[i] = escaping[i-1] + 0.5 * (flux_total[i] + flux_total[i-1]) * dt[i-1]
    combined = mobile + escaping + trapped
    initial = mobile[0] + trapped[0]

    fig = plt.figure(figsize=[6.5, 5.5])
    ax1 = fig.add_subplot(gridspec.GridSpec(1, 1)[0])

    traps = [t5, t4, t3, t2, t_intr, t1, mobile]
    bottom = np.zeros_like(trapped)
    for i, t in enumerate(traps):
        ax1.fill_between(hours, bottom, bottom + t, color=colors[i], alpha=0.3)
        ax1.plot(hours, bottom + t, color=colors[i], linewidth=1)
        bottom += t

    # Plot total and initial
    ax1.plot(hours, combined, c='tab:green', label='Total', linewidth=1.5)
    ax1.axhline(initial, linestyle=':', color='tab:red', label='Initial')

    ax1.set(xlabel='Time (h)', ylabel='Deuterium amount (atoms)',
            xlim=(0, hours[-1]), ylim=(0, None))
    ax1.grid(True, linestyle='--', color='0.65', alpha=0.3)

    ax2 = ax1.twinx()
    ax2.plot(hours, temp, color='tab:orange', label='Temperature', linewidth=1.5)
    ax2.set_ylabel('Temperature (K)')

    rmspe = np.sqrt(np.mean((combined - initial)**2)) * 100 / initial
    ax1.text(0.4, 0.85, f'RMSPE = {rmspe:.2f} %', transform=ax1.transAxes, fontsize=12, fontweight='bold')

    mobile_label = "Mobile (small)" if key in ["default", "inf"] else "Mobile"
    patches = [
        plt.Line2D([0], [0], color='tab:green', label='Total'),
        plt.Line2D([0], [0], color='tab:red', linestyle=':', label='Initial'),
        plt.Line2D([0], [0], color='tab:orange', label='Temperature'),
        Patch(color=colors[6], alpha=0.5, label=mobile_label),
        Patch(color=colors[5], alpha=0.5, label='Trap 1'),
        Patch(color=colors[4], alpha=0.5, label='Intrinsic Trap'),
        Patch(color=colors[3], alpha=0.5, label='Trap 2'),
        Patch(color=colors[2], alpha=0.5, label='Trap 3'),
        Patch(color=colors[1], alpha=0.5, label='Trap 4'),
        Patch(color=colors[0], alpha=0.5, label='Trap 5'),
]
    fig.legend(handles=patches, loc='center right', bbox_to_anchor=(0.85, 0.5), fontsize=8)
    save_plot(fig, f"{fname}.png")

# ==============================================================================
# Figure 5: Trap-induced density vs DPA

kb = 1.380649e-23 # J/K
eV_to_J = 1.602176634e-19 # J/eV
kb_eV = kb / eV_to_J # eV/K
phi = 8.9e-5 # dpa/s
T = 800 # K

K_vals = [9e26, 4.2e26, 2.5e26, 5e26, 1e26] # traps/m^3/dpa
nmax_vals = [6.9e25, 7e25, 6e25, 4.7e25, 2e25] # traps/m^3
A0_vals = [6.18e-3]*4 + [0] # 1/s
Ea_vals = [0.24, 0.24, 0.30, 0.30, 0] # eV
trap_density_0_1_dpa = [4.8e25, 3.8e25, 2.6e25, 3.6e25, 1.1e25] # traps/m^3

def trap_density(dpa, phi, K, nmax, A):
    S = phi * K
    r = S / nmax + A
    t = dpa / phi
    return -S / r * np.exp(-r * t) + S / r

dpa_vals = np.linspace(0, 3, 1000)
fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])

for i in range(5):
    A = A0_vals[i] * np.exp(-Ea_vals[i] / (kb_eV * T))
    d = trap_density(dpa_vals, phi, K_vals[i], nmax_vals[i], A)
    ax.plot(dpa_vals, d, label=f'Trap {i+1}')
    ax.scatter(0.1, trap_density_0_1_dpa[i])

ax.axvline(0.1, color='gray', linestyle='--')
ax.text(0.15, 0.05 * max(trap_density_0_1_dpa), '0.1 dpa', color='gray')
ax.set(xlabel='Damage (dpa)', ylabel=r"Trap density (m$^{-3}$)", xlim=(0, 3), ylim=(0, None))
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.legend()
save_plot(fig, 'val-2f_trap_induced_density.png')
