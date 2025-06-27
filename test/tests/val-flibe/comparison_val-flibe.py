import numpy as np
import pandas as pd
import os
from matplotlib import gridspec
import matplotlib.pyplot as plt
import glob
import re
import matplotlib.ticker as ticker

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Load experimental data
if "/tmap8/doc/" in script_folder.lower():  # if in documentation folder
    csv_folder = "../../../../test/tests/val-2g/gold/val-flibe_823K_1210Pa_out.csv"
else:                                       # if in test folder
    csv_folder = "./gold/val-flibe_823K_1210Pa_out.csv"
expt_data = pd.read_csv(csv_folder)
TMAP8_time = expt_data['time']
concentration_ratio = expt_data['concentration_ratio_tritium']
concentration_ratio_tritium = expt_data['concentration_ratio_tritium']
sieverts_ratio_tritium = expt_data['sieverts_ratio_tritium']
average_flux_left = - expt_data['average_flux_left']
average_flux_Ni_FLiBe = expt_data['average_flux_Ni_FLiBe']

#===============================================================================
# Flux conservation
begin = 2000
flux_conservation = average_flux_left/average_flux_right
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
ratio = [1] * len(TMAP8_time[1:])
ax.plot(TMAP8_time[begin:], flux_conservation[begin:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.set_xlim(TMAP8_time[begin],TMAP8_time[begin:].max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Flux conservation")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((flux_conservation[begin:]-ratio[begin-1:])**2))
RMSPE = RMSE*100/np.mean(ratio[begin-1:])
print("RMSPE for flux conservation: ", RMSPE)
x_pos = TMAP8_time[begin:].max()*0.75
y_pos = flux_conservation[begin].max()
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('val-flibe_flux_conservation.png', bbox_inches='tight', dpi=300)

#===============================================================================
# Sieverts' law conservation enclosure-Ni
begin = 100
n_sorption = 0.5 # Sieverts' law
R = 8.31446261815324 # J/mol/K ideal gas constant from PhysicalConstants.h
temperature = 823 # K
K_s_Ni_prefactor = 564e-3 # mol/m^3/Pa^0.5
K_s_Ni_energy = 15.8e3 # J/mol
K_s_Ni = K_s_Ni_prefactor * np.exp(- K_s_Ni_energy / (R*temperature)) # mol/m^3/Pa^0.5
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
solubility_ratio = [K_s_Ni] * len(TMAP8_time[1:])
ax.plot(TMAP8_time[begin:], sieverts_ratio_tritium[begin:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.set_xlim(TMAP8_time[begin],TMAP8_time[begin:].max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{Ni}} / \sqrt{P_{T_2}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((sieverts_ratio_tritium[begin:]-solubility_ratio[begin-1:])**2))
RMSPE = RMSE*100/np.mean(solubility_ratio[begin-1:])
print("RMSPE for sorption law enclosure-Ni: ", RMSPE)
x_pos = TMAP8_time[begin:].max() / 50
y_pos = sieverts_ratio_tritium[begin].max()*1.005
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('val-flibe_concentration_ratio_enclosure-Ni.png', bbox_inches='tight', dpi=300)

#===============================================================================
# Henry's law conservation Ni-FLiBe
begin = 200
n_sorption = 1 # Henry's law
R = 8.31446261815324 # J/mol/K ideal gas constant from PhysicalConstants.h
temperature = 823 # K
K_s_FLiBe_prefactor = 7.9e-2 # mol/m^3/Pa
K_s_FLiBe_energy = 35e3 # J/mol
K_s_FLiBe = K_s_FLiBe_prefactor * np.exp(- K_s_FLiBe_energy / (R*temperature)) # mol/m^3/Pa
fig = plt.figure(figsize=[6.5,5.5])
gs = gridspec.GridSpec(1,1)
ax = fig.add_subplot(gs[0])
solubility_ratio = [K_s_FLiBe*(R*temperature)**n_sorption] * len(TMAP8_time[1:])
ax.ticklabel_format(useOffset=False, style='plain', axis='y')
ax.get_yaxis().get_offset_text().set_visible(False)
ax.plot(TMAP8_time[begin:], concentration_ratio_tritium[begin:], label=r"Concentration Ratio (TMAP8)", color='tab:blue', linestyle='-')
ax.set_xlim(TMAP8_time[begin],TMAP8_time[begin:].max())
ax.set_xlabel('Time (s)')
ax.set_ylabel(r"Concentrations ratio $C_{\text{Ni}} / C_{\text{FLiBe}}$")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
RMSE = np.sqrt(np.mean((concentration_ratio_tritium[begin:]-solubility_ratio[begin-1:])**2))
RMSPE = RMSE*100/np.mean(solubility_ratio[begin-1:])
print("RMSPE for sorption law Ni-FLiBe: ", RMSPE)
x_pos = TMAP8_time[begin:].max()/10
y_pos = concentration_ratio_tritium[begin:].max()
ax.text(x_pos, y_pos, 'RMSPE = %.3f ' % RMSPE + '%', fontweight='bold')
fig.savefig('val-flibe_concentration_ratio_Ni-FLiBe.png', bbox_inches='tight', dpi=300)

#===============================================================================
# Tritium permeation flux as a function of tritium partial pressure
# for a range of temperatures and initial pressures

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

data_folder = "./gold/"
data_by_temperature = {}
pattern = re.compile(r"val-flibe_(\d+)K_(\d+)Pa_out\.csv")

for file_path in glob.glob(os.path.join(data_folder, "val-flibe_*K_*Pa_out.csv")):
    match = pattern.search(os.path.basename(file_path))
    if match:
        T = int(match.group(1))
        P = int(match.group(2))
        df = pd.read_csv(file_path)
        average_flux = df["average_flux_right"].iloc[-1]
        data_by_temperature.setdefault(T, []).append((P, average_flux))

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
for T in sorted(data_by_temperature.keys()):
    T_C = T - 273
    values = sorted(data_by_temperature[T])
    pressures, fluxes = zip(*values)
    ax.scatter(
        pressures,
        fluxes,
        marker=temperature_marker_map[T_C],
        color=temperature_color_map[T_C],
        label=f"{T_C} °C (TMAP8)"
    )

# Styling
ax.set_xlabel(r"$T_2$ partial pressure (Pa)")
ax.set_ylabel(r"Tritium molar flux (mol/m$^2$/s)")
ax.legend(loc="best")
ax.grid(which='major', color='0.65', linestyle='--', alpha=0.3)
fig.savefig('val-flibe_flux.png', bbox_inches='tight', dpi=300)
