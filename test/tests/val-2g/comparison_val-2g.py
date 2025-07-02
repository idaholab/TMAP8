import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Load experimental data
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/gold/val-2g_823K_1210Pa_out.csv"
else:                                       # if in test folder
    csv_folder = "./gold/val-2g_823K_1210Pa_out.csv"
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    data_folder = "../../../../test/tests/val-2g/gold/"
else:                                       # if in test folder
    data_folder = "./gold/"
data_by_temperature = {}
expt_data = pd.read_csv(csv_folder)
TMAP8_time = expt_data['time']
concentration_ratio = expt_data['concentration_ratio_tritium']
concentration_ratio_tritium = expt_data['concentration_ratio_tritium']
sieverts_ratio_tritium = expt_data['sieverts_ratio_tritium']
average_flux_left = - expt_data['average_flux_left']
average_flux_Ni_FLiBe_interface = expt_data['average_flux_Ni_FLiBe_interface']
average_flux_right = expt_data['average_flux_right']

#===============================================================================
# General parameters

R = 8.31446261815324 # J/mol/K ideal gas constant from PhysicalConstants.h
temperature = 823 # K
n_sieverts = 0.5 # Sieverts' law

#===============================================================================
# Flux conservation
start_time = 2000 # characteristic time for convergence
flux_conservation = average_flux_left/average_flux_Ni_FLiBe_interface
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ratio = [1] * len(TMAP8_time[1:])
ax.plot(TMAP8_time[start_time:], flux_conservation[start_time:], label=r"Flux Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time[start_time:], ratio[start_time-1:], label=r'Analytical Flux Ratio', color='tab:red', linestyle='--')
ax.set_xlim(TMAP8_time[start_time],TMAP8_time[start_time:].max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Flux conservation")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((flux_conservation[start_time:]-ratio[start_time-1:])**2))
RMSPE = RMSE*100/np.mean(ratio[start_time-1:])
print("RMSPE for flux conservation: ", RMSPE)
x_pos = TMAP8_time[start_time:].max()*0.65
y_pos = flux_conservation[start_time].max()
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('val-2g_flux_conservation.png', bbox_inches='tight', dpi=300)

#===============================================================================
# Sieverts' law conservation enclosure-Ni
start_time = 1 # characteristic time for convergence
K_s_Ni_prefactor = 564e-3 # mol/m^3/Pa^0.5
K_s_Ni_energy = 15.8e3 # J/mol
K_s_Ni = K_s_Ni_prefactor * np.exp(- K_s_Ni_energy / (R*temperature)) # mol/m^3/Pa^0.5
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.yaxis.set_major_formatter(ScalarFormatter(useOffset=False))
solubility_ratio = [K_s_Ni] * len(TMAP8_time[1:])
ax.plot(TMAP8_time[start_time:], sieverts_ratio_tritium[start_time:], label=r"Sieverts' Law Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time[start_time:], solubility_ratio[start_time-1:], label=r"Analytical Sieverts' Law Ratio", color='tab:red', linestyle='--')
ax.set_xlim(TMAP8_time[start_time],TMAP8_time[start_time:].max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Sieverts' law ratio $C_{\text{Ni}} / \sqrt{P_{T_2}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((sieverts_ratio_tritium[start_time:]-solubility_ratio[start_time-1:])**2))
RMSPE = RMSE*100/np.mean(solubility_ratio[start_time-1:])
print("RMSPE for sorption law enclosure-Ni: ", RMSPE)
x_range = ax.get_xlim()[1] - ax.get_xlim()[0]
x_pos = ax.get_xlim()[1] - 0.02 * x_range
y_range = ax.get_ylim()[1] - ax.get_ylim()[0]
y_pos = ax.get_ylim()[0] + 0.02 * y_range
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold', ha='right', va='bottom')
fig.savefig('val-2g_concentration_ratio_enclosure-Ni.png', bbox_inches='tight', dpi=300)

#===============================================================================
# Conservation Ni-FLiBe
start_time = 168 # characteristic time for convergence
K_s_FLiBe_prefactor = 7.9e-2 # mol/m^3/Pa
K_s_FLiBe_energy = 35e3 # J/mol
K_s_FLiBe = K_s_FLiBe_prefactor * np.exp(- K_s_FLiBe_energy / (R*temperature)) # mol/m^3/Pa
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ax.yaxis.set_major_formatter(ScalarFormatter(useOffset=False))
solubility_ratio = [K_s_FLiBe / (K_s_Ni)**2] * len(TMAP8_time[1:])
ax.plot(TMAP8_time[start_time:], concentration_ratio_tritium[start_time:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.plot(TMAP8_time[start_time:], solubility_ratio[start_time-1:], label=r'Analytical Concentration Ratio', color='tab:red', linestyle='--')
ax.set_xlim(TMAP8_time[start_time],TMAP8_time[start_time:].max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{FLiBe}} / C_{\text{Ni}}^2$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((concentration_ratio_tritium[start_time:]-solubility_ratio[start_time-1:])**2))
RMSPE = RMSE*100/np.mean(solubility_ratio[start_time-1:])
print("RMSPE for sorption law Ni-FLiBe: ", RMSPE)
x_range = ax.get_xlim()[1] - ax.get_xlim()[0]
x_pos = ax.get_xlim()[1] - 0.02 * x_range
y_range = ax.get_ylim()[1] - ax.get_ylim()[0]
y_pos = ax.get_ylim()[0] + 0.02 * y_range
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold', ha='right', va='bottom')
fig.savefig('val-2g_concentration_ratio_Ni-FLiBe.png', bbox_inches='tight', dpi=300)

#===============================================================================
# Tritium permeation flux as a function of tritium partial pressure
# for a range of temperatures and initial pressures

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

for filename in os.listdir(data_folder):
    if filename.endswith(".csv") and filename.startswith("val-2g_"):
        parts = filename.replace(".csv", "").split("_")
        if len(parts) == 4 and parts[1].endswith("K") and parts[2].endswith("Pa"):
            try:
                T = int(parts[1][:-1])  # Remove 'K'
                P = int(parts[2][:-2])  # Remove 'Pa'
                df = pd.read_csv(os.path.join(data_folder, filename))
                average_flux = df["average_flux_right"].iloc[-1]
                data_by_temperature.setdefault(T, []).append((P, average_flux))
            except Exception as e:
                print(f"Skipping {filename}: {e}")

# Define consistent color and marker maps based on temperature in Celsius
temperatures_C = [550, 600, 650, 700]
temperature_color_map = {T: f"C{i}" for i, T in enumerate(temperatures_C)}
temperature_marker_map = {550: 'o', 600: 's', 650: 'D', 700: '^'}

# Experimental data
exp_data = pd.DataFrame({
    "pressure": [170, 316, 316, 538, 538, 538, 1210, 1210, 1210, 1210],
    "flux": np.array([
        1.0684039087947879,
        1.0423452768729637,
        2.0325732899022793,
        1.1465798045602602,
        1.745928338762214,
        2.866449511400651,
        3.6351791530944624,
        2.5146579804560254,
        1.7068403908794778,
        1.1596091205211714
    ]) * 1e-7,
    "temperature": [700, 650, 700, 600, 650, 700, 700, 650, 600, 550]
})

for T_C in reversed(sorted(exp_data["temperature"].unique())):
    subset = exp_data[exp_data["temperature"] == T_C]
    ax.scatter(
        subset["pressure"],
        subset["flux"],
        marker=temperature_marker_map[T_C],
        facecolors='none',
        edgecolors=temperature_color_map[T_C],
        label=f"{T_C} °C exp"
    )

# Plot TMAP8 data
for T in reversed(sorted(data_by_temperature.keys())):
    T_C = T - 273
    values = sorted(data_by_temperature[T])
    pressures, fluxes = zip(*values)
    ax.scatter(
        pressures,
        fluxes,
        marker=temperature_marker_map.get(T_C, 'x'),
        color=temperature_color_map.get(T_C, 'k'),
        label=f"{T_C} °C (TMAP8)"
    )

# Styling
ax.set_xlabel(r"$T_2$ partial pressure (Pa)")
ax.set_ylabel(r"Tritium molar flux (mol/m$^2$/s)")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig.savefig('val-2g_tritium_flux.png', bbox_inches='tight', dpi=300)
