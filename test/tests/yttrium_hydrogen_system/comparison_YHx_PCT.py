# Import Required Libraries
# Import the necessary libraries, including pandas.

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from mpl_toolkits.mplot3d import Axes3D
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#============================================================================= #
# General parameters
mmHg_to_Pa = 133.322 # 1 mmHg = 133.322 Pa
C_to_K = 273.15 # 0 C = 273.15 K
temperature_list = [900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300, 1350] # C
temperature_list = [x + 273.15 for x in temperature_list] # K

# ============================================================================ #
# Extract data from experiments
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    folderPath = "../../../../test/tests/yttrium_hydrogen_system/"
else:                                  # if in test folder
    folderPath = ""
folderNameExpData = 'PTC_curves_Data'
list_expData = []
for temperature in temperature_list:
    # Read the CSV file into a DataFrame
    expData = pd.read_csv(folderPath + folderNameExpData + '/' + str(int(temperature-C_to_K)) + '.csv')
    # Update units from mm HG to Pa
    expData['Partial Pressure (Pa)'] = expData['Partial Pressure (mm Hg)'] * mmHg_to_Pa
    # Delete column with pressure in mm Hg
    expData = expData.drop(columns=['Partial Pressure (mm Hg)'])
    # Add a column for temperature
    expData['Temperature (K)'] = temperature
    # Organize by increasing order of atom ratio
    expData = expData.sort_values(by='Atom Ratio (-)')
    print(expData)
    list_expData.append(expData)

# ============================================================================ #
# Identify plateau region

# Method to calculate the numerical derivative
def calculate_derivative(expData, x_col, y_col):
  x = expData.iloc[:, x_col]
  y = expData.iloc[:, y_col]
  dy_dx = np.gradient(y, x)
  return dy_dx

# List to store plateau positions for each temperature
plateau_positions = {}

# Loop through each temperature and calculate the derivative
for i, temperature in enumerate(temperature_list):
  x_col = 0 # atom ratio
  y_col = 1 # pressure
  dy_dx = calculate_derivative(list_expData[i], x_col, y_col) # derivative
  dy_dx_y = dy_dx/list_expData[i].iloc[:, y_col]

  # Identify the range of derivatives that correspond to the plateau region
  plateau_threshold = 1  # Define a threshold for the plateau region
  plateau_edges = np.where(dy_dx_y < plateau_threshold)[0]

  # Find the start and end indices of the plateau region
  if len(plateau_edges) > 0:
    start_index = plateau_edges[0]
    end_index = plateau_edges[-1]
  else:
    start_index = end_index = None

  # Store the plateau edges
  plateau_positions[temperature] = {
    'start_index': int(start_index) if start_index is not None else None,
    'start': list_expData[i].iloc[start_index, [x_col, y_col]] if start_index is not None else None,
    'end_index': int(end_index) if end_index is not None else None,
    'end': list_expData[i].iloc[end_index, [x_col, y_col]] if end_index is not None else None
  }

# ============================================================================ #
# Fit the plateau pressure as a function of temperature

# Calculate the average pressure on the plateau for each temperature
average_plateau_pressures = [
  list_expData[i].iloc[plateau_positions[temperature]['start_index']:plateau_positions[temperature]['end_index'] + 1, 1].mean()
  if plateau_positions[temperature]['start_index'] is not None and plateau_positions[temperature]['end_index'] is not None
  else None
  for i, temperature in enumerate(temperature_list)
]

# Define fitting function
def p0_lim_func(temperature):
  return np.exp(-26.1+3.88*10**(-2)*np.array(temperature)-9.7*10**(-6)*np.square(temperature))

p0_lim = p0_lim_func(temperature_list)

# Plot the fit along with the data from the plateau pressure as a function of temperature
# Extract the plateau pressures for each temperature
plateau_pressures = average_plateau_pressures
# Filter out None values
filtered_temperatures = [temperature for temperature, pressure in zip(temperature_list, plateau_pressures) if pressure is not None]
filtered_pressures = [pressure for pressure in plateau_pressures if pressure is not None]

# ============================================================================ #
# Plot the fit and the plateau pressures
fig = plt.figure(figsize=(10, 6))
plt.plot(temperature_list, p0_lim, label='Fit', linestyle='--')
plt.scatter(filtered_temperatures, filtered_pressures, color='red', label='Plateau Pressures')
plt.xlabel('Temperature (K)')
plt.ylabel('Pressure (Pa)')
plt.title('Fit transition region as a Pressures as a Function of Temperature')
plt.yscale('log')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('YHx_PCT_plateau_pressure_fit.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ============================================================================ #
# Fit the high pressures as a function of temperature
def atom_ratio_eq_upper_func(temperature,pressure):
    return 2-(1+np.exp(21.6 -0.0225*temperature + (-0.0445 + 7.18*10**(-4)*temperature)*(np.log(pressure - p0_lim_func(temperature)))))**(-1)
    # return 2-(1.3-3.5*10**(-2)*np.log(pressure)+np.exp(22.2 -0.0227*temperature + (-0.0445 + 7.18*10**(-4)*temperature)*(np.log(pressure - p0_lim_func(temperature)))))**(-1)

# Create a meshgrid for the fit surface
pressure_range = np.linspace((min(list_expData[0].iloc[:, 1])), (max(list_expData[0].iloc[:, 1])), 100)
temperature_range = np.linspace(min(temperature_list), max(temperature_list), 100)
pressure_mesh, temperature_mesh = np.meshgrid(pressure_range, temperature_range)

atom_ratio_eq_upper = atom_ratio_eq_upper_func(temperature_range,pressure_range)

# ============================================================================ #
# Compare simulation data against model
# Read simulation data
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../test/tests/yttrium_hydrogen_system/gold/"
else:                                  # if in test folder
    csv_folder = "./gold/"

TMAP8_prediction_T1473_P5e4 = pd.read_csv(csv_folder + "YHx_PCT_T1473_P5e4_out.csv")
TMAP8_prediction_T1173_P1e3 = pd.read_csv(csv_folder + "YHx_PCT_T1173_P1e3_out.csv")
TMAP8_prediction_T1173_P1e4 = pd.read_csv(csv_folder + "YHx_PCT_T1173_P1e4_out.csv")
TMAP8_prediction_T1173_P5e4 = pd.read_csv(csv_folder + "YHx_PCT_T1173_P5e4_out.csv")

TMAP8_prediction_T1473_P5e4_temperature = TMAP8_prediction_T1473_P5e4['temperature'].iat[-1]
TMAP8_prediction_T1473_P5e4_pressure = TMAP8_prediction_T1473_P5e4['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T1473_P5e4_atomic_fraction = TMAP8_prediction_T1473_P5e4['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T1473_P5e4_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T1473_P5e4_temperature,TMAP8_prediction_T1473_P5e4_pressure)

TMAP8_prediction_T1173_P1e3_temperature = TMAP8_prediction_T1173_P1e3['temperature'].iat[-1]
TMAP8_prediction_T1173_P1e3_pressure = TMAP8_prediction_T1173_P1e3['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T1173_P1e3_atomic_fraction = TMAP8_prediction_T1173_P1e3['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T1173_P1e3_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T1173_P1e3_temperature,TMAP8_prediction_T1173_P1e3_pressure)

TMAP8_prediction_T1173_P1e4_temperature = TMAP8_prediction_T1173_P1e4['temperature'].iat[-1]
TMAP8_prediction_T1173_P1e4_pressure = TMAP8_prediction_T1173_P1e4['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T1173_P1e4_atomic_fraction = TMAP8_prediction_T1173_P1e4['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T1173_P1e4_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T1173_P1e4_temperature,TMAP8_prediction_T1173_P1e4_pressure)

TMAP8_prediction_T1173_P5e4_temperature = TMAP8_prediction_T1173_P5e4['temperature'].iat[-1]
TMAP8_prediction_T1173_P5e4_pressure = TMAP8_prediction_T1173_P5e4['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T1173_P5e4_atomic_fraction = TMAP8_prediction_T1173_P5e4['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T1173_P5e4_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T1173_P5e4_temperature,TMAP8_prediction_T1173_P5e4_pressure)


# ============================================================================ #
# Plot the experimental data, the fit, and the TMAP8 results
fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111, projection='3d')

# Plot all the data points
for expData in list_expData:
  ax.scatter(expData['Partial Pressure (Pa)'], expData['Temperature (K)'], expData['Atom Ratio (-)'], label=f'{expData["Temperature (K)"].iloc[0]} K')

# Initialize atom_ratio_mesh with the correct dimensions
atom_ratio_eq_upper_mesh = np.zeros_like(pressure_mesh)

# Create a surface for the fit
for i, pressure in enumerate(pressure_range):
  for j, temperature in enumerate(temperature_range):
    atom_ratio_eq_upper_mesh[j, i] = atom_ratio_eq_upper_func(temperature,pressure) if pressure > p0_lim_func(temperature) else 0

# Plot the fit surface
ax.plot_surface(pressure_mesh, temperature_mesh, atom_ratio_eq_upper_mesh, color='blue', alpha=0.3)

# update the orientation of the figure
# ax.view_init(30, 30)
ax.set_xlabel('Partial Pressure (Pa)')
ax.set_ylabel('Temperature (K)')
ax.set_zlabel('Atom Ratio (-)')
ax.set_title('3D Plot of Partial Pressure, Temperature, and Atom Ratio with Fit Surface')
ax.set_zlim(0, 2)
ax.legend(loc='upper center', ncols=5)
plt.tight_layout()
ax.set_box_aspect(None, zoom=0.95)
plt.savefig('YHx_PCT_fit_3D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# Initialize a dictionary to store RMSE values for each temperature
RMSE_values = {}

# Plot the data points and the fit function for each temperature
fig = plt.figure(figsize=(15, 6))

print('temperature_list',temperature_list)

for i, temperature in enumerate(temperature_list):
  # Extract the data points for the current temperature
  expData = list_expData[i]
  pressures = expData['Partial Pressure (Pa)']
  atom_ratios = expData['Atom Ratio (-)']

  index_limit = plateau_positions[temperature]['end_index']
  if index_limit is not None:
    # Select only the values that are above the transition region
    pressures_upper = pressures[index_limit:]
    atom_ratios_upper = atom_ratios[index_limit:]

    # Calculate the fit values using the function
    fit_values_upper = atom_ratio_eq_upper_func(temperature, pressures_upper)

    # remove nan values from fit_values_upper and the corresponding index from atom_ratios_upper and pressures_upper
    index_not_nan = ~np.isnan(fit_values_upper)
    fit_values_upper = fit_values_upper[index_not_nan]
    atom_ratios_upper = atom_ratios_upper[index_not_nan]
    pressures_upper = pressures_upper[index_not_nan]

    # Calculate the RMSE for the current temperature
    RMSE = np.sqrt(np.mean((np.array(atom_ratios_upper) - np.array(fit_values_upper))**2))
    RMSE_values[temperature] = RMSE

    # Plot the data points
    plt.scatter(pressures_upper, atom_ratios_upper, label=f'{temperature} K Data')

    # Plot the fit function
    plt.plot(pressures_upper, fit_values_upper, label=f'{temperature} K Fit (RMSE: {RMSE:.2f})')

# plot the TMAP8 predictions
error = abs(TMAP8_prediction_T1473_P5e4_atomic_fraction-analytical_equation_T1473_P5e4_atomic_fraction)/analytical_equation_T1473_P5e4_atomic_fraction*100
plt.scatter(TMAP8_prediction_T1473_P5e4_pressure, TMAP8_prediction_T1473_P5e4_atomic_fraction, label =f'{TMAP8_prediction_T1473_P5e4_temperature} K and {TMAP8_prediction_T1473_P5e4_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T1173_P1e3_atomic_fraction-analytical_equation_T1173_P1e3_atomic_fraction)/analytical_equation_T1173_P1e3_atomic_fraction*100
plt.scatter(TMAP8_prediction_T1173_P1e3_pressure, TMAP8_prediction_T1173_P1e3_atomic_fraction, label =f'{TMAP8_prediction_T1173_P1e3_temperature} K and {TMAP8_prediction_T1173_P1e3_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T1173_P1e4_atomic_fraction-analytical_equation_T1173_P1e4_atomic_fraction)/analytical_equation_T1173_P1e4_atomic_fraction*100
plt.scatter(TMAP8_prediction_T1173_P1e4_pressure, TMAP8_prediction_T1173_P1e4_atomic_fraction, label =f'{TMAP8_prediction_T1173_P1e4_temperature} K and {TMAP8_prediction_T1173_P1e4_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T1173_P5e4_atomic_fraction-analytical_equation_T1173_P5e4_atomic_fraction)/analytical_equation_T1173_P5e4_atomic_fraction*100
plt.scatter(TMAP8_prediction_T1173_P5e4_pressure, TMAP8_prediction_T1173_P5e4_atomic_fraction, label =f'{TMAP8_prediction_T1173_P5e4_temperature} K and {TMAP8_prediction_T1173_P5e4_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)

plt.xlabel('Partial Pressure (Pa)')
plt.ylabel('Atom Ratio (-)')
plt.title('Atom Ratio vs Partial Pressure with Fit Curves')
plt.xscale('log')
plt.legend(bbox_to_anchor=(1.1, 1.05))
plt.grid(True)
plt.tight_layout()
plt.savefig('YHx_PCT_fit_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# print the RMSE values for each temperature
print('temperatures (K) and RMSE values: ',RMSE_values)

# print the average RMSE value
average_rmse = np.mean(list(RMSE_values.values()))
print(f'Average RMSE: {average_rmse:.2f}')


