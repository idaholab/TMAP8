# Import Required Libraries
# Import the necessary libraries, including pandas.

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from mpl_toolkits.mplot3d import Axes3D
import os
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# ================================================================================ #
# Constants
molar_mass_Zr2Fe = 2 * 91.22 + 55.85  # = 238.29 g/mol
molar_mass_H = 1.008  # g/mol

# User-defined inputs
temperature_list = [325, 350, 375]  # Celsius


colors = ['blue', 'green', 'red', 'purple']

#NEED TO FIX THIS
# Extract data from experiments
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    folderPath = "../../../../../test/tests/Zr2Fe_hydrogen_system/"
else:                                  # if in test folder
    folderPath = ""
folderNameExpData = 'PCT_data/'



# ============================================================================== #
# Load and process data
data_matrix = []
list_expData = []

fig1, ax1 = plt.subplots()

for i, temp_c in enumerate(temperature_list):
    temp_k = temp_c + 273.15
    file_path = os.path.join(folderPath, folderNameExpData, f"{int(temp_c)}.csv")

    try:
        df = pd.read_csv(file_path)

        if {'Atom Ratio', 'Partial Pressure'}.issubset(df.columns):
            wt_H = df['Atom Ratio'].values
            partial_pressure_pa = df['Partial Pressure'].values * 1e5  # bar to Pa

            atom_ratio = (wt_H / molar_mass_H) / ((100 - wt_H) / molar_mass_Zr2Fe)

            data_matrix.append({
                'Temperature': temp_k,
                'AtomRatio': atom_ratio,
                'PartialPressure': partial_pressure_pa
            })

            df_exp = pd.DataFrame({
                'Temperature (K)': [temp_k] * len(atom_ratio),
                'Atom Ratio': atom_ratio,
                'Partial Pressure (Pa)': partial_pressure_pa
            })
            list_expData.append(df_exp)

            ax1.plot(atom_ratio, partial_pressure_pa, '-', color=colors[i],
                     label=f"{temp_k:.2f} K", linewidth=1.5)
            ax1.scatter(atom_ratio, partial_pressure_pa, color=colors[i], s=30, edgecolor='black')
        else:
            print(f"Missing required columns in {file_path}")

    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

# Finalize first plot
ax1.set_xlabel("Atomic Ratio H/Zr₂Fe (-)")
ax1.set_ylabel("Partial Pressure (Pa)")
ax1.set_yscale("log")
ax1.set_title("Atomic Ratio vs Partial Pressure at Different Temperatures")
ax1.legend()
ax1.grid(True)
plt.savefig('Zr2FeHx_PCT.png', bbox_inches='tight', dpi=300)
plt.close(fig1)

# ============================================================================= #
# Define theoretical pressure limit function
def p0_lim_func(temperature):
    temperature = np.array(temperature)
    return np.exp(-4.12265+ 1.0288e-02 * temperature)

# Convert temperature_list from °C to K
temperature_list_K = np.array([t + 273.15 for t in temperature_list])
p0_lim = p0_lim_func(temperature_list_K)

# ============================================================================= #
# Extract filtered pressures and temperatures based on atom ratio threshold
atom_ratio_threshold = 0.5
selected_temps = []
selected_pressures = []

for data in list_expData:
    atom_ratio = data['Atom Ratio'].values
    pressure = data['Partial Pressure (Pa)'].values
    temperature = data['Temperature (K)'].iloc[0]

    idx = np.where(atom_ratio > atom_ratio_threshold)[0]
    if len(idx) > 0:
        selected_temps.append(temperature)
        selected_pressures.append(pressure[idx[0]])
    else:
        print(f'No atom ratio > {atom_ratio_threshold} found for {temperature:.2f} K')

selected_temps = np.array(selected_temps)
selected_pressures = np.array(selected_pressures)

# ============================================================================= #
# Plot the fit and the filtered plateau pressures
fig2, ax2 = plt.subplots(figsize=(5, 5))
ax2.plot(temperature_list_K, p0_lim, label='Fit', linestyle='--')
ax2.scatter(selected_temps, selected_pressures, color='red', label='Pressures')
ax2.set_xlabel('Temperature (K)')
ax2.set_ylabel('log(Pressure) (Pa)')
ax2.legend()
ax2.grid(True)
fig2.tight_layout()
plt.savefig('Zr2FeHx_PCT_pressure_limiter_fit.png', bbox_inches='tight', dpi=300)
plt.close(fig2)

# ============================================================================= #

# Define pressure isotherm model function
def atom_ratio_eq_upper_func(temperature, pressure):
    """
    Calculates the equilibrium atomic ratio at high pressures for a given temperature and pressure.
    """
    temperature = np.array(temperature)
    pressure = np.array(pressure)
    p0 = p0_lim_func(temperature)

    # Ensure log argument is positive
    safe_log_arg = np.maximum(pressure - p0, 1e-10)

    exponent = (
        5.4074
        - 1.3571e-2 * temperature
        + (0.23190 + 1.5078e-4 * temperature) * np.log(safe_log_arg)
    )

    return 4.30 - 1.8103 / (0.5 + np.exp(exponent))


# ============================================================================ #
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../../test/tests/Zr2Fe_hydrogen_system/gold/"
else:                                  # if in test folder
    csv_folder = "./gold/"

TMAP8_prediction_T648_P1e05 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T648_P1e05_out.csv")
TMAP8_prediction_T648_P1e02 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T648_P1e02_out.csv")

TMAP8_prediction_T598_P1e03 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T598_P1e03_out.csv")
TMAP8_prediction_T623_P1e04 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T623_P1e04_out.csv")

TMAP8_prediction_T648_P1e05_temperature = TMAP8_prediction_T648_P1e05['temperature'].iat[-1]
TMAP8_prediction_T648_P1e05_pressure = TMAP8_prediction_T648_P1e05['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T648_P1e05_atomic_fraction = TMAP8_prediction_T648_P1e05['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T648_P1e05_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T648_P1e05_temperature,TMAP8_prediction_T648_P1e05_pressure)

TMAP8_prediction_T648_P1e02_temperature = TMAP8_prediction_T648_P1e02['temperature'].iat[-1]
TMAP8_prediction_T648_P1e02_pressure = TMAP8_prediction_T648_P1e02['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T648_P1e02_atomic_fraction = TMAP8_prediction_T648_P1e02['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T648_P1e02_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T648_P1e02_temperature,TMAP8_prediction_T648_P1e02_pressure)

TMAP8_prediction_T598_P1e03_temperature = TMAP8_prediction_T598_P1e03['temperature'].iat[-1]
TMAP8_prediction_T598_P1e03_pressure = TMAP8_prediction_T598_P1e03['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T598_P1e03_atomic_fraction = TMAP8_prediction_T598_P1e03['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T598_P1e03_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T598_P1e03_temperature,TMAP8_prediction_T598_P1e03_pressure)

TMAP8_prediction_T623_P1e04_temperature = TMAP8_prediction_T623_P1e04['temperature'].iat[-1]
TMAP8_prediction_T623_P1e04_pressure = TMAP8_prediction_T623_P1e04['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T623_P1e04_atomic_fraction = TMAP8_prediction_T623_P1e04['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T623_P1e04_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T623_P1e04_temperature,TMAP8_prediction_T623_P1e04_pressure)


# ============================================================================ #

# Initialize a dictionary to store RMSE values for each temperature
RMSE_values = {}

# Plot the data points and the fit function for each temperature
fig = plt.figure(figsize=(12, 6))

print('temperature_list',temperature_list)

for i, temperature in enumerate(temperature_list):
  # Extract the data points for the current temperature
  expData = list_expData[i]
  pressures = expData['Partial Pressure (Pa)']
  atom_ratios = expData['Atom Ratio']

  idx = np.where(atom_ratios> 0.5)[0]



  if  idx is not None:
    # Select only the values that are above the transition region
    pressures_upper = pressures[idx]
    atom_ratios_upper = atom_ratios[idx]

    # Calculate the fit values using the function
    fit_values_upper = atom_ratio_eq_upper_func(temperature+273.15, pressures_upper)


    # Calculate the RMSE for the current temperature
    RMSE = np.sqrt(np.mean((np.array(atom_ratios_upper) - np.array(fit_values_upper))**2))
    RMSE_values[temperature] = RMSE



    plt.scatter(pressures_upper, atom_ratios_upper, label=f'{temperature+273.15} K Data')

    # Plot the fit function
    plt.plot(pressures_upper, fit_values_upper, label=f'{temperature+273.15} K Fit (RMSE: {RMSE:.2f})')

# plot the TMAP8 predictions
error = abs(TMAP8_prediction_T648_P1e05_atomic_fraction-analytical_equation_T648_P1e05_atomic_fraction)/analytical_equation_T648_P1e05_atomic_fraction*100
plt.scatter(TMAP8_prediction_T648_P1e05_pressure, TMAP8_prediction_T648_P1e05_atomic_fraction, label =f'{TMAP8_prediction_T648_P1e05_temperature} K and {TMAP8_prediction_T648_P1e05_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T648_P1e02_atomic_fraction-analytical_equation_T648_P1e02_atomic_fraction)/analytical_equation_T648_P1e02_atomic_fraction*100
plt.scatter(TMAP8_prediction_T648_P1e02_pressure, TMAP8_prediction_T648_P1e02_atomic_fraction, label =f'{TMAP8_prediction_T648_P1e02_temperature} K and {TMAP8_prediction_T648_P1e02_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T598_P1e03_atomic_fraction-analytical_equation_T598_P1e03_atomic_fraction)/analytical_equation_T598_P1e03_atomic_fraction*100
plt.scatter(TMAP8_prediction_T598_P1e03_pressure, TMAP8_prediction_T598_P1e03_atomic_fraction, label =f'{TMAP8_prediction_T598_P1e03_temperature} K and {TMAP8_prediction_T598_P1e03_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T623_P1e04_atomic_fraction-analytical_equation_T623_P1e04_atomic_fraction)/analytical_equation_T623_P1e04_atomic_fraction*100
plt.scatter(TMAP8_prediction_T623_P1e04_pressure, TMAP8_prediction_T623_P1e04_atomic_fraction, label =f'{TMAP8_prediction_T623_P1e04_temperature} K and {TMAP8_prediction_T623_P1e04_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)

plt.xlabel('Partial Pressure (Pa)')
plt.ylabel('Atom Ratio (-)')
plt.xscale('log')
plt.legend(bbox_to_anchor=(1.1, 1.05))
plt.grid(True)
plt.tight_layout()
plt.savefig('Zr2FeHx_PCT_fit_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# print the RMSE values for each temperature
print('temperatures (K) and RMSE values: ',RMSE_values)

# print the average RMSE value
average_rmse = np.mean(list(RMSE_values.values()))
print(f'Average RMSE: {average_rmse:.2f}')


