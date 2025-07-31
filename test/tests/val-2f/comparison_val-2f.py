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
    csv_folder_inf_recombination = "../../../../test/tests/val-2f/gold/val-2f_out_infinite_recombination.csv"
    csv_folder_pss = "../../../../test/tests/val-2f/gold/val-2f_pss.csv"
    csv_folder_exp = "../../../../test/tests/val-2f/gold/0.1_dpa.csv"
else:  # if in test folder
    csv_folder = "./gold/val-2f_out.csv"
    csv_folder_inf_recombination = "./gold/val-2f_out_infinite_recombination.csv"
    csv_folder_pss = "./gold/val-2f_pss.csv"
    csv_folder_exp = "./gold/0.1_dpa.csv"

def save_plot(fig, name):
    fig.tight_layout()
    fig.savefig(name, bbox_inches='tight', dpi=300)
    plt.close(fig)

# Time configuration
K_MIN, K_MAX = 300, 1000
HEATING_RATE = 3 / 60
CHARGE_TIME = 72 * 3600
COOLDOWN_TIME = 12 * 3600
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
    "pss": pd.read_csv(csv_folder_pss),
    "exp": pd.read_csv(csv_folder_exp),
}
experiment = tmap_data["exp"]
experiment_temperature = experiment['Temperature (K)']
experiment_flux = experiment['Deuterium Loss Rate (at/s)'] / (12e-3 * 15e-3)

# ==============================================================================
# Figure 1: Implantation distribution

fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])
sigma, R_p, flux = 0.5e-9, 0.7e-9, 5.79e19
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
                   ("inf", "val-2f_comparison_inf_recombination"),
                   ("pss", "val-2f_comparison_pss")]:
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
# Figure 3b: Combined TMAP8 vs Experimental (PSS + Infinite Recombination)

fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])

# Plot experimental data
ax.scatter(experiment_temperature, experiment_flux, label="Experiment", color='black', zorder=3)

# Plot PSS simulation
output_default = extract_tmap_data_desorption(tmap_data["pss"])
temp_default = output_default[1]
flux_default = output_default[4]
ax.plot(temp_default, flux_default, label="TMAP8 (5 traps)", color='tab:blue', linewidth=2)

# Compute RMSPE for PSS case
interp_flux_default = numerical_solution_on_experiment_input(experiment_temperature, temp_default, flux_default)
rmse = np.sqrt(np.mean((interp_flux_default - experiment_flux) ** 2))
rmspe = rmse * 100 / np.mean(experiment_flux)

# Plot infinite recombination simulation
output_inf = extract_tmap_data_desorption(tmap_data["inf"])
temp_inf = output_inf[1]
flux_inf = output_inf[4]
ax.plot(temp_inf, flux_inf, linestyle='--', alpha=0.3, color='blue',
        label="TMAP8 (infinite recombination)", linewidth=2)

interp_flux_inf = numerical_solution_on_experiment_input(experiment_temperature, temp_inf, flux_inf)
rmse_inf = np.sqrt(np.mean((interp_flux_inf - experiment_flux)**2))
rmspe_inf = rmse_inf * 100 / np.mean(experiment_flux)

# Annotate RMSPE
ax.text(750, 5e16, f'RMSPE = {rmspe_inf:.2f} %', fontweight='bold', color='blue', alpha=0.4)
ax.text(750, 5.5e16, f'RMSPE = {rmspe:.2f} %', fontweight='bold', color='tab:blue')
ax.text(750, 6e16, 'Damage = 0.1 dpa')

# Final plot settings
ax.set(
    xlabel='Temperature (K)',
    ylabel=r'Deuterium flux (at/m$^2$/s)',
    xlim=(min(temp_default), max(temp_default)),
    ylim=(0, None)
)
ax.legend()
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()

# Save the figure
save_plot(fig, "val-2f_comparison_overlay.png")

# ==============================================================================
# Figure 4: Deuterium evolution with curve lines, mobile + intrinsic trap added

cmap = plt.get_cmap('viridis')
colors = cmap(np.linspace(0, 1, 7))
intrinsic_color = 'gray'

for key, fname in [("default", "val-2f_deuterium_desorption"),
                   ("inf", "val-2f_deuterium_desorption_inf_recombination"),
                   ("pss", "val-2f_deuterium_desorption_pss")]:
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
    ax2.set_ylim(300,1000)

    rmspe = np.sqrt(np.mean((combined - initial)**2)) * 100 / initial
    ax1.text(0.4, 0.85, f'RMSPE = {rmspe:.2f} %', transform=ax1.transAxes, fontsize=12, fontweight='bold')

    mobile_label = "Mobile (small)" if key in ["default", "inf", "pss"] else "Mobile"
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

kb = 1.380649e-23
eV_to_J = 1.602176634e-19
kb_eV = kb / eV_to_J
phi = 8.9e-5
T = 800

K_vals = [9e26, 4.2e26, 2.5e26, 5e26, 1e26]
nmax_vals = [6.9e25, 7e25, 6e25, 4.7e25, 2e25]
A0_vals = [6.18e-3]*4 + [0]
Ea_vals = [0.24, 0.24, 0.30, 0.30, 0]
trap_density_0_1_dpa = [4.8e25, 3.8e25, 2.6e25, 3.6e25, 1.1e25]

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

# ==============================================================================
# Figure 5b: Trap-induced density vs DPA for PSS

# Constants
kb = 1.380649e-23
eV_to_J = 1.602176634e-19
kb_eV = kb / eV_to_J
phi = 8.9e-5
T = 800  # K

# Temperature-dependent desorption rates
def trap_density(dpa, phi, K, nmax, A):
    S = phi * K
    r = S / nmax + A
    t = dpa / phi
    return -S / r * np.exp(-r * t) + S / r

# Original analytical parameters
K_vals = [9e26, 4.2e26, 2.5e26, 5e26, 1e26]
nmax_vals = [6.9e25, 7e25, 6e25, 4.7e25, 2e25]
A0_vals = [6.18e-3]*4 + [0]
Ea_vals = [0.24, 0.24, 0.30, 0.30, 0]
trap_density_0_1_dpa = [4.8e25, 3.8e25, 2.6e25, 3.6e25, 1.1e25]

# Calibrated (fitted) parameters at 0.1 dpa
A0 = 0.007073350413571204

K_fit = [
    9.548411975971741e+26,
    4.811263150722378e+26,
    3.089447371593305e+26,
    5.4704858848137864e+26,
    1.03063746428795e+26,
]
nmax_fit = [
    8.204302675705086e+25,
    6.798859344532439e+25,
    6.60314877597923e+25,
    4.42302937902921e+25,
    2.0042492263646006e+25,
]
Ea_fit = [
    0.25429367544547277,
    0.25580415037680826,
    0.3123052222774063,
    0.29500664335218957,
    0.0,
]
trap_density_fitted = [  # computed below
    None, None, None, None, 25268.129890326665  # intrinsic trap is fixed
]

# X-axis values (dpa)
dpa_vals = np.linspace(0, 3, 1000)

# Create figure
fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])

# Plot original analytical trap densities
for i in range(5):
    A = A0_vals[i] * np.exp(-Ea_vals[i] / (kb_eV * T))
    d = trap_density(dpa_vals, phi, K_vals[i], nmax_vals[i], A)
    line, = ax.plot(dpa_vals, d, label=f'Trap {i+1}', alpha=0.7)
    ax.scatter(0.1, trap_density_0_1_dpa[i], color=line.get_color(), alpha=0.65, zorder=4)

# Plot calibrated trap densities at 0.1 dpa
for i in range(5):
    A_fit_T = A0 * np.exp(-Ea_fit[i] / (kb_eV * T)) if i < 4 else 0.0
    d_fit = trap_density(0.1, phi, K_fit[i], nmax_fit[i], A_fit_T)
    trap_density_fitted[i] = d_fit
    ax.scatter(0.1, d_fit, color=ax.lines[i].get_color(), alpha=1.0, zorder=5)

# Vertical line and annotation
ax.axvline(0.1, color='gray', linestyle='--')
ax.text(0.15, 0.05 * max(trap_density_0_1_dpa), '0.1 dpa', color='gray')

# Axis formatting
ax.set(
    xlabel='Damage (dpa)',
    ylabel=r"Trap density (m$^{-3}$)",
    xlim=(0, 3),
    ylim=(0, None)
)
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.legend()

save_plot(fig, 'val-2f_trap_induced_density_PSS.png')

# ==============================================================================
# Figure 6: Diffusion coefficients plot

# Temperature range (K)
T = np.linspace(295, 2600, 500)
inv_T = 1000 / T  # scaled to match axis label (1/T * 10^3)

# Define envelope parameters
D0_lower = 9.33e-9
Ea_lower = 0.4126
D0_upper = 4.1e-7
Ea_upper = 0.193

# Envelope curves
D_lower = D0_lower * np.exp(-Ea_lower / (kb_eV * T))
D_upper = D0_upper * np.exp(-Ea_upper / (kb_eV * T))

# Experimental diffusion models with personalized T ranges
diffusion_models = {
    "Deuterium, Boda et al. (2020)": {"D0": 1.86e-7, "Ea": 0.193, "T_range": (200, 2000)},
    "Hydrogen, Frauenfelder (1969)": {"D0": 4.1e-7, "Ea": 0.39, "T_range": (1000, 2600)},
    "Deuterium, Holzner et al. (2020)": {"D0": 1.6e-7, "Ea": 0.28, "T_range": (1600, 2600)},
    "Deuterium, Ahlgren et al. (2016)": {"D0": 1.12e-7, "Ea": 0.25, "T_range": (300, 1500)},
    "Deuterium, Heinola et al. (2010)": {"D0": 0.48e-7, "Ea": 0.26, "T_range": (138, 2600)},
    "Deuterium, Grigorev et al. (2015)": {"D0": 9.33e-9, "Ea": 0.23, "T_range": (300, 1500)},
    "Deuterium, Ikeda (2017)": {"D0": 3.8e-7, "Ea": 0.4126, "T_range": (308, 343)},
    "Deuterium, Alimov et al. (2022)": {"D0": 2.5e-3, "Ea": 1.12, "T_range": (323, 813)},
}

# Calibrated model parameters
D0_this_work = 1.6 * 10 ** (-6.953974921409119)  # m^2/s
Ea_this_work = 0.4241494795717058                # eV

# Plotting
fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])

# Plot upper envelope
ax.plot(inv_T, D_upper, ':', label='Upper envelope', color='black', alpha=1)

# Plot each experimental model in its own T range (with alpha=0.5)
for label, params in diffusion_models.items():
    T_local = np.linspace(params["T_range"][0], params["T_range"][1], 300)
    inv_T_local = 1000 / T_local
    D = params["D0"] * np.exp(-params["Ea"] / (kb_eV * T_local))
    ax.plot(inv_T_local, D, label=label, alpha=1)

# Plot lower envelope
ax.plot(inv_T, D_lower, '--', label='Lower envelope', color='black', alpha=1)

# Axis formatting
ax.set_xlabel(r'1/T (1/$K$ $\times$ 10$^3$)', fontsize=14)
ax.set_ylabel('Diffusion coefficient (m$^2$/s)', fontsize=14)
ax.set_yscale("log")

def one_over(x):
    """Vectorized 1/x, treating x==0 manually"""
    x = np.array(x).astype(float)
    near_zero = np.isclose(x, 0)
    x[near_zero] = 1e21
    x[~near_zero] = 1 / x[~near_zero] * 1e3
    return x

# Add top axis for Temperature (K)
inverse = one_over
ax2 = ax.secondary_xaxis('top', functions=(one_over, inverse))
ax2.set_xlabel('Temperature (K)', fontsize=14)
ax2.set_xticks([2600, 1500, 1000, 800, 700, 600, 500, 400, 295])

# Final formatting
ax.set_xlim(inv_T[0], inv_T[-1])
ax.invert_xaxis()
ax.legend(fontsize=9.5)
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()

# Save
save_plot(fig, 'val-2f_deuterium_diffusion_literature.png')

# ==============================================================================
# Figure 6b: Diffusion coefficients plot for PSS

# Temperature range (K)
T = np.linspace(295, 2600, 500)
inv_T = 1000 / T  # scaled to match axis label (1/T * 10^3)

# Define envelope parameters
D0_lower = 9.33e-9
Ea_lower = 0.4126
D0_upper = 4.1e-7
Ea_upper = 0.193

# Envelope curves
D_lower = D0_lower * np.exp(-Ea_lower / (kb_eV * T))
D_upper = D0_upper * np.exp(-Ea_upper / (kb_eV * T))

# Experimental diffusion models with personalized T ranges
diffusion_models = {
    "Deuterium, Boda et al. (2020)": {"D0": 1.86e-7, "Ea": 0.193, "T_range": (200, 2000)},
    "Hydrogen, Frauenfelder (1969)": {"D0": 4.1e-7, "Ea": 0.39, "T_range": (1000, 2600)},
    "Deuterium, Holzner et al. (2020)": {"D0": 1.6e-7, "Ea": 0.28, "T_range": (1600, 2600)},
    "Deuterium, Ahlgren et al. (2016)": {"D0": 1.12e-7, "Ea": 0.25, "T_range": (300, 1500)},
    "Deuterium, Heinola et al. (2010)": {"D0": 0.48e-7, "Ea": 0.26, "T_range": (138, 2600)},
    "Deuterium, Grigorev et al. (2015)": {"D0": 9.33e-9, "Ea": 0.23, "T_range": (300, 1500)},
    "Deuterium, Ikeda (2017)": {"D0": 3.8e-7, "Ea": 0.4126, "T_range": (308, 343)},
    "Deuterium, Alimov et al. (2022)": {"D0": 2.5e-3, "Ea": 1.12, "T_range": (323, 813)},
}

# Calibrated model parameters
D0_this_work = 1.6 * 10 ** (-6.953974921409119)  # m^2/s
Ea_this_work = 0.4241494795717058                # eV

# Plotting
fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])

# Plot upper envelope
ax.plot(inv_T, D_upper, ':', label='Upper envelope', color='black', alpha=1)

# Plot each experimental model in its own T range (with alpha=0.5)
for label, params in diffusion_models.items():
    T_local = np.linspace(params["T_range"][0], params["T_range"][1], 300)
    inv_T_local = 1000 / T_local
    D = params["D0"] * np.exp(-params["Ea"] / (kb_eV * T_local))
    ax.plot(inv_T_local, D, label=label, alpha=0.3)

# Plot lower envelope
ax.plot(inv_T, D_lower, '--', label='Lower envelope', color='black', alpha=1)

# Plot the calibrated diffusion
D_this_work = D0_this_work * np.exp(-Ea_this_work / (kb_eV * T))
ax.plot(inv_T, D_this_work, label='Calibrated diffusion coefficient', color='tab:red', linewidth=2, alpha=1.0)

# Axis formatting
ax.set_xlabel(r'1/T (1/$K$ $\times$ 10$^3$)', fontsize=14)
ax.set_ylabel('Diffusion coefficient (m$^2$/s)', fontsize=14)
ax.set_yscale("log")

def one_over(x):
    """Vectorized 1/x, treating x==0 manually"""
    x = np.array(x).astype(float)
    near_zero = np.isclose(x, 0)
    x[near_zero] = 1e21
    x[~near_zero] = 1 / x[~near_zero] * 1e3
    return x

# Add top axis for Temperature (K)
inverse = one_over
ax2 = ax.secondary_xaxis('top', functions=(one_over, inverse))
ax2.set_xlabel('Temperature (K)', fontsize=14)
ax2.set_xticks([2600, 1500, 1000, 800, 700, 600, 500, 400, 295])

# Final formatting
ax.set_xlim(inv_T[0], inv_T[-1])
ax.invert_xaxis()
ax.legend(fontsize=9.5)
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()

# Save
save_plot(fig, 'val-2f_deuterium_diffusion_literature_PSS.png')

# ==============================================================================
# Figure 7: Recombination coefficients plot

# Define temperature range for envelope curves
T = np.linspace(426, 1176, 500)
inv_T = 1000 / T  # scaled to match axis label (1/T * 10^3)

# Envelope parameters for lower and upper bounds
k0_lower = 6.9e-27  # Pick & Sonnenberg
Ea_lower = 0.9

k0_upper = 1e-16  # Lee et al.
Ea_upper = -1.12

# Envelope curves
K_lower = k0_lower * np.exp(-Ea_lower / (kb_eV * T))
K_upper = k0_upper * np.exp(-Ea_upper / (kb_eV * T))

# Recombination coefficient models
recombination_models = {
    "Pick & Sonnenberg (1985)": {"k0": 6.9e-27, "Ea": -1.12, "T_range": (800, 1000), "custom": False},
    "Lee et al. (2011)": {"k0": 1e-16, "Ea": 0.9, "T_range": (800, 909), "custom": False},
    "Anderl et al. (1992)": {"k0": 3.2e-15, "Ea": 1.16, "T_range": (625, 833), "custom": False},
    "Wilson (1992)": {"k0": 6.9e-26, "Ea": -0.54, "T_range": (800, 1000), "custom": False},
    "Zhao et al. (2020), pristine": {"k0": 3.8e-26, "Ea": 0.15, "T_range": (741, 1176), "custom": False},
    "Zhao et al. (2020), clean": {"k0": 3.8e-26, "Ea": 0.34, "T_range": (741, 1176), "custom": False},
    "Takagi et al. (2011)": {"k0": 4.5e-25, "Ea": 0.78, "T_range": (426, 654), "custom": False},
    "Ogorodnikova (2019)": {"k0": 3e-25, "Ea": -2.06, "T_range": (455, 1111), "custom": True},
}

# Calibrated model parameters
k0_this_work = 3.8 * 10 ** (-23.70358721819463)  # m^4/s
Ea_this_work = -0.05646715836429029  # eV

# Create plot
fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])
plot_handles = []
plot_labels = []

# Plot upper envelope
ax.plot(inv_T, K_upper, ':', label='Upper envelope', color='black')

# Plot each experimental model with alpha=0.5
for label, params in recombination_models.items():
    T_min, T_max = params["T_range"]
    T_vals = np.linspace(T_min, T_max, 300)
    x_vals = 1000 / T_vals

    if params["custom"]:
        k_vals = params["k0"] / np.sqrt(T_vals) * np.exp(-params["Ea"] / (kb_eV * T_vals))
    else:
        k_vals = params["k0"] * np.exp(-params["Ea"] / (kb_eV * T_vals))

    handle, = ax.plot(x_vals, k_vals, label=label)
    plot_handles.append(handle)
    plot_labels.append(label)

# Plot lower envelope
ax.plot(inv_T, K_lower, '--', label='Lower envelope', color='black')

# Format axis
ax.set_yscale('log')
ax.set_xlim(1000 / 1176, 1000 / 426)
ax.set_xlabel(r'1/T (1/$K$ $\times$ 10$^3$)', fontsize=14)
ax.set_ylabel(r'Recombination coefficient (m$^4$/s)', fontsize=12)

# Top axis for temperature
def one_over(x):
    x = np.array(x).astype(float)
    near_zero = np.isclose(x, 0)
    x[near_zero] = 1e21
    x[~near_zero] = 1 / x[~near_zero] * 1e3
    return x

inverse = one_over
ax2 = ax.secondary_xaxis('top', functions=(one_over, inverse))
ax2.set_xlabel('Temperature ($K$)', fontsize=14)
ax2.set_xticks([1176, 1000, 900, 800, 700, 600, 500, 426])

# Legend in desired order
custom_order = [
    "Ogorodnikova (2019)",
    "Pick & Sonnenberg (1985)",
    "Lee et al. (2011)",
    "Anderl et al. (1992)",
    "Wilson (1992)",
    "Zhao et al. (2020), pristine",
    "Zhao et al. (2020), clean",
    "Takagi et al. (2011)",
    "Calibrated recombination coefficient"
]

sorted_items = sorted(zip(plot_handles, plot_labels), key=lambda hl: custom_order.index(hl[1]))
sorted_handles, sorted_labels = zip(*sorted_items)
ax.legend(sorted_handles, sorted_labels, fontsize=9, loc='upper right')

# Final formatting
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()
save_plot(fig, 'val-2f_recombination_literature.png')

# ==============================================================================
# Figure 7b: Recombination coefficients plot for PSS

# Define temperature range for envelope curves
T = np.linspace(426, 1176, 500)
inv_T = 1000 / T  # scaled to match axis label (1/T * 10^3)

# Envelope parameters for lower and upper bounds
k0_lower = 6.9e-27  # Pick & Sonnenberg
Ea_lower = 0.9

k0_upper = 1e-16  # Lee et al.
Ea_upper = -1.12

# Envelope curves
K_lower = k0_lower * np.exp(-Ea_lower / (kb_eV * T))
K_upper = k0_upper * np.exp(-Ea_upper / (kb_eV * T))

# Recombination coefficient models
recombination_models = {
    "Pick & Sonnenberg (1985)": {"k0": 6.9e-27, "Ea": -1.12, "T_range": (800, 1000), "custom": False},
    "Lee et al. (2011)": {"k0": 1e-16, "Ea": 0.9, "T_range": (800, 909), "custom": False},
    "Anderl et al. (1992)": {"k0": 3.2e-15, "Ea": 1.16, "T_range": (625, 833), "custom": False},
    "Wilson (1992)": {"k0": 6.9e-26, "Ea": -0.54, "T_range": (800, 1000), "custom": False},
    "Zhao et al. (2020), pristine": {"k0": 3.8e-26, "Ea": 0.15, "T_range": (741, 1176), "custom": False},
    "Zhao et al. (2020), clean": {"k0": 3.8e-26, "Ea": 0.34, "T_range": (741, 1176), "custom": False},
    "Takagi et al. (2011)": {"k0": 4.5e-25, "Ea": 0.78, "T_range": (426, 654), "custom": False},
    "Ogorodnikova (2019)": {"k0": 3e-25, "Ea": -2.06, "T_range": (455, 1111), "custom": True},
}

# Calibrated model parameters
k0_this_work = 3.8 * 10 ** (-23.70358721819463)  # m^4/s
Ea_this_work = -0.05646715836429029  # eV

# Create plot
fig = plt.figure(figsize=[6.5, 5.5])
ax = fig.add_subplot(gridspec.GridSpec(1, 1)[0])
plot_handles = []
plot_labels = []

# Plot upper envelope
ax.plot(inv_T, K_upper, ':', label='Upper envelope', color='black', alpha=0.5)

# Plot each experimental model with alpha=0.5
for label, params in recombination_models.items():
    T_min, T_max = params["T_range"]
    T_vals = np.linspace(T_min, T_max, 300)
    x_vals = 1000 / T_vals

    if params["custom"]:
        k_vals = params["k0"] / np.sqrt(T_vals) * np.exp(-params["Ea"] / (kb_eV * T_vals))
    else:
        k_vals = params["k0"] * np.exp(-params["Ea"] / (kb_eV * T_vals))

    handle, = ax.plot(x_vals, k_vals, label=label, alpha=0.5)
    plot_handles.append(handle)
    plot_labels.append(label)

# Plot lower envelope
ax.plot(inv_T, K_lower, '--', label='Lower envelope', color='black', alpha=0.5)

# Plot the calibrated recombination
T_this = np.linspace(426, 1176, 300)
inv_T_this = 1000 / T_this
k_this = k0_this_work * np.exp(-Ea_this_work / (kb_eV * T_this))
ax.plot(inv_T_this, k_this, color='tab:red', linewidth=2, alpha=1.0)

# Format axis
ax.set_yscale('log')
ax.set_xlim(1000 / 1176, 1000 / 426)
ax.set_xlabel(r'1/T (1/$K$ $\times$ 10$^3$)', fontsize=14)
ax.set_ylabel(r'Recombination coefficient (m$^4$/s)', fontsize=12)

# Top axis for temperature
def one_over(x):
    x = np.array(x).astype(float)
    near_zero = np.isclose(x, 0)
    x[near_zero] = 1e21
    x[~near_zero] = 1 / x[~near_zero] * 1e3
    return x

inverse = one_over
ax2 = ax.secondary_xaxis('top', functions=(one_over, inverse))
ax2.set_xlabel('Temperature ($K$)', fontsize=14)
ax2.set_xticks([1176, 1000, 900, 800, 700, 600, 500, 426])

# Legend in desired order
custom_order = [
    "Ogorodnikova (2019)",
    "Pick & Sonnenberg (1985)",
    "Lee et al. (2011)",
    "Anderl et al. (1992)",
    "Wilson (1992)",
    "Zhao et al. (2020), pristine",
    "Zhao et al. (2020), clean",
    "Takagi et al. (2011)",
    "Calibrated recombination coefficient"
]
# Add the calibrated value to sorting
plot_handles.append(ax.lines[-1])
plot_labels.append("Calibrated recombination coefficient")
sorted_items = sorted(zip(plot_handles, plot_labels), key=lambda hl: custom_order.index(hl[1]))
sorted_handles, sorted_labels = zip(*sorted_items)
ax.legend(sorted_handles, sorted_labels, fontsize=9, loc='upper right')

# Final formatting
ax.grid(True, linestyle='--', color='0.65', alpha=0.3)
ax.minorticks_on()
save_plot(fig, 'val-2f_recombination_literature_PSS.png')
