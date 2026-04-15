import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load CSV data
data_steel_only = pd.read_csv('steel_only_out.csv') # CHANGE BELOW TOO
data = pd.read_csv('gas_steel_out.csv')
SRNL_data = pd.read_csv('gold/SRNL_data.csv')

# interface_location = 35.941 # mm

# Pull necessary columns
t = data['time']
absorbed_dose = t*65.21904/365.25 # Roughly 50 MGy/year absorbed does for Cobalt 60 irraditator
num_time_steps = len(t)
H_partial_pressure_interface = data['H_partial_pressure_interface'] # Pa
cylinder_total_mass_steel = data['cylinder_total_mass_steel']
cylinder_total_mass_gas = data['cylinder_total_mass_gas']
circle_concentration = data['circle_concentration']
circle_time_integrated_flux = data['circle_time_integrated_flux']
circle_time_integrated_generation = data['circle_time_integrated_generation']
cylinder_total_mass = data['cylinder_total_mass']
cylinder_time_integrated_flux = data['cylinder_time_integrated_flux']
cylinder_time_integrated_generation = data['cylinder_time_integrated_generation']

# SRNL data for validation
SRNL_absorbed_dose = SRNL_data['Dose (MGy)']
SRNL_total_mass_gas = 2 * SRNL_data['Cum. H2 yield (μmol)'] # atomic H

# Pressure in Pa accounting for percentage change
SRNL_partial_pressure = 1e3* SRNL_data["Gas pressure (kPa)"]*SRNL_data["H2 gas fraction (%)"]/100

# Steel-only model data for comparison
steel_only_cylinder_total_mass_steel = data_steel_only['3d_mass_in_domain']
# t_steel = data_steel_only['time']

def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output): # Linear Mapping of simulation data to experimental data
    """Get new numerical solution based on the experimental input data points

    Args:
        experiment_input (float, ndarray): experimental input data points
        tmap_input (float, ndarray): numerical input data points
        tmap_output (float, ndarray): numerical output data points

    Returns:
        float, ndarray: updated tmap_output based on the data points in experiment_input
    """
    new_tmap_output = np.zeros(len(experiment_input))
    for i in range(len(experiment_input)):
        left_limit = np.argwhere((np.diff(tmap_input < experiment_input[i])))[0][0]
        right_limit = left_limit + 1
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (tmap_input[right_limit] - tmap_input[left_limit]) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[left_limit]
    return new_tmap_output

# Plot SRNL Partial Pressure measurements
plt.figure(figsize=(10, 6))
plt.plot(SRNL_absorbed_dose,SRNL_partial_pressure, 'ro', label = 'Experimental Data')
plt.plot(absorbed_dose,H_partial_pressure_interface, label = 'Full Simulation')
mapped_pressure = numerical_solution_on_experiment_input(SRNL_absorbed_dose, absorbed_dose, H_partial_pressure_interface)
RMSE = np.sqrt(np.mean((mapped_pressure - SRNL_partial_pressure)**2))
RMSPE = RMSE*100/np.mean(SRNL_partial_pressure)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(10,2000, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.ylabel(r'H_2 Partial Pressure (Pa)')
plt.xlabel('Absorbed Dose (MGy)')
plt.title(f'SRNL Partial Pressure vs. Simulated Partial Pressure at Interface ')
plt.xlim(0)
plt.legend()
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()

# Comparison of Concentration in Steel between two models
plt.figure(figsize=(10, 6))
plt.plot(t,steel_only_cylinder_total_mass_steel, label = 'Steel-Only Simulation')
plt.plot(t,cylinder_total_mass_steel, label = 'Full Simulation')
RMSE = np.sqrt(np.mean((steel_only_cylinder_total_mass_steel - cylinder_total_mass_steel)**2))
RMSPE = RMSE*100/np.mean(steel_only_cylinder_total_mass_steel)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(60,5,'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.ylabel(r'Cum. H Mass ($\mu$mol)')
plt.xlabel('Time (Days)')
plt.title(f'Total H Mass in the Steel: Steel-only Model vs. Full Model ')
plt.xlim(0)
plt.legend()
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()

# Total Hydrogen in the Gas compared to experimental data

simulation_mapped_total_mass_gas = numerical_solution_on_experiment_input(SRNL_absorbed_dose, absorbed_dose, cylinder_total_mass_gas) # Pulled from val 2a
plt.figure(figsize=(10, 6))
plt.plot(absorbed_dose,cylinder_total_mass_gas, label = 'Simulation')
plt.plot(SRNL_absorbed_dose,SRNL_total_mass_gas, 'ro', label = 'Experimental Data')
RMSE = np.sqrt(np.mean((simulation_mapped_total_mass_gas - SRNL_total_mass_gas)**2))
RMSPE = RMSE*100/np.mean(SRNL_total_mass_gas)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(10,1000, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.legend()
plt.ylabel(r'Atomic H Total Mass ($\mu$mol)')
plt.xlabel('Absorbed Dose (MGy)')
plt.title(f'Hydrogen in Gas Phase of Cylinder vs Absorbed Dose')
plt.xlim(0)
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()

# Yield and percentage of hydrogen in the steel
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot the first Y-axis data (absolute mass)
ax1.plot(t, cylinder_total_mass_steel, 'b-', label='H Mass in Steel')
ax1.set_ylabel(r'Atomic H Total Mass ($\mu$mol)', color='b')
ax1.set_xlabel('Time (days)')
ax1.set_title(f'Atomic Hydrogen in Steel of Cylinder vs Time')
ax1.set_xlim(0)
ax1.set_ylim(0)
ax1.tick_params(axis='y', labelcolor='b')
ax1.grid(True)

# Create a second Y-axis and plot percentage
ax2 = ax1.twinx()
percentage_in_steel = cylinder_total_mass_steel / cylinder_total_mass * 100
ax2.plot(t, percentage_in_steel, 'r--', alpha=0.7, label='% in Steel')
ax2.set_ylabel('% Total Hydrogen in Steel', color='r')
ax2.tick_params(axis='y', labelcolor='r')
ax2.set_ylim(0, percentage_in_steel.max() * 1.1)  # Add 10% headroom
plt.tight_layout()
plt.show()

# Measure and Plot Conservation of Mass in 2D (for axisymmetric coordinates)
plt.figure(figsize=(10, 6))
plt.plot(t, circle_time_integrated_flux + circle_time_integrated_generation, label = 'Accumulated Boundary Flux + Source')
plt.plot(t,circle_concentration, label = 'Total Concentration in Circle')
RMSE = np.sqrt(np.mean((circle_concentration - circle_time_integrated_flux - circle_time_integrated_generation)**2))
RMSPE = RMSE*100/np.mean(circle_concentration)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(50,5, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.xlabel('Time (days)')
plt.ylabel(r'$\mu$mol H/mm')
plt.title(f'Conservation of Mass: 2D Circle')
plt.xlim(0,t.max())
plt.ylim(0,max(circle_concentration.max(),circle_time_integrated_flux.max()+circle_time_integrated_generation.max()))
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

difference = abs(circle_time_integrated_flux + circle_time_integrated_generation-circle_concentration)
plt.figure(figsize=(10, 6))
plt.plot(t,difference)
plt.xlabel('Time (days)')
plt.ylabel(r'$\mu$mol H/mm')
plt.title(f'Conservation of Mass Difference: 2D Circle')
plt.xlim(0,t.max())
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()

# Measure and Plot Conservation of Mass in 3D (for axisymmetric coordinates)
plt.figure(figsize=(10, 6))
plt.plot(t, cylinder_time_integrated_flux + cylinder_time_integrated_generation, label = 'Accumulated Boundary Flux + Source')
plt.plot(t,cylinder_total_mass, label = 'Total Mass in Cylinder')
RMSE = np.sqrt(np.mean((cylinder_total_mass - cylinder_time_integrated_flux - cylinder_time_integrated_generation)**2))
RMSPE = RMSE*100/np.mean(cylinder_total_mass)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(50,1000, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.xlabel('Time (Days)')
plt.ylabel(r'$\mu$mol H')
plt.title(f'Conservation of Mass: 3D Cylinder')
plt.xlim(0,t.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

difference = abs(cylinder_time_integrated_flux + cylinder_time_integrated_generation - cylinder_total_mass)
plt.figure(figsize=(10, 6))
plt.plot(t,difference)
plt.xlabel('Time (Days)')
plt.ylabel(r'$\mu$mol H')
plt.title(f'Conservation of Mass Difference: 3D Cylinder')
plt.xlim(0,t.max())
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()
