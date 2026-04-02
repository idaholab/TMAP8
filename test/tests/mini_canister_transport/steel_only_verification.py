import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
# import glob

# Load CSV data
# data = pd.read_csv('csv_data_steel_only/verification.csv') # CHANGE BELOW TOO
data = pd.read_csv('csv_data_steel_only/verification_RZ.csv')
# parameter_study_data = pd.read_csv('peak_pressures.csv')

# interface_location = 35.941 # mm

# Pull necessary columns
t = data['time']
# absorbed_dose = t*65.21904/365.25 #124.7 Gy/min absorbed dose for Cobalt 60 irraditator
num_time_steps = len(t)
ring_flux = data['time_integrated_flux']
ring_concentration = data['mass_in_domain']
annulus_total_mass = data['3d_mass_in_domain']
annulus_flux = data['3d_time_integrated_flux']
exact_diffusion_length = data['exact_diffusion_length']
simulated_diffusion_length = data['simulated_diffusion_length']
assumed_gas_total_mass = 2*data['assumed_gas_total_mass'] # Count Atomic Hydrogen
assumed_total_mass = assumed_gas_total_mass + annulus_total_mass

# Total Mass and Percentage in Steel
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot the total mass data
ax1.plot(t, annulus_total_mass, label = 'Steel Total Mass H')
ax1.set_ylabel(r'H Total Mass ($\mu$mol)')
ax1.set_xlabel('Time (days)')
ax1.set_title(f'Atomic Hydrogen H in Steel of 3D Annulus vs Time')
ax1.set_xlim(0)
ax1.set_ylim(0)
ax1.grid(True)

# Plot Percentage data for assumed mass in gas-phase
ax2 = ax1.twinx()
ax2.set_ylabel('% Total H', color='k')
percentage = 100. * annulus_total_mass / assumed_total_mass
ax2.plot(t, percentage, color='tab:orange', linestyle='--', label='% in Steel')
ax2.set_ylim(0)

lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2)
plt.tight_layout()
plt.show()

# Check length of diffusion front
plt.figure(figsize=(10, 6))
plt.plot(t,exact_diffusion_length, label = 'Exact Diffusion Length sqrt(pi*D*t)')
plt.plot(t,simulated_diffusion_length, label =f'Simulated Diffusion Length')
RMSE = np.sqrt(np.mean((simulated_diffusion_length-exact_diffusion_length)**2) )
RMSPE = RMSE*100/np.mean(exact_diffusion_length)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(80,0.1, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.legend()
plt.ylabel('Length (mm)')
plt.xlabel('Time (days)')
plt.title(f'Hydrogen Canister Simulation: 1D Diffusion Front Length')
plt.xlim(0)
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()

# Plot Difference

plt.figure(figsize=(10, 6))
plt.plot(t,abs(exact_diffusion_length - simulated_diffusion_length))
plt.ylabel('Difference in Length (mm)')
plt.xlabel('Time (days)')
plt.title(f'Hydrogen Canister Simulation: 1D Diffusion Front Length Difference')
plt.xlim(0)
plt.ylim(0)
plt.grid(True)
plt.tight_layout()
plt.show()

# Measure and Plot Conservation of Mass in 2D (for axisymmetric coordinates)
plt.figure(figsize=(10, 6))
plt.plot(t, ring_flux, label = 'Accumulated Boundary Flux')
plt.plot(t,ring_concentration, label = 'Total Concentration in Ring')
RMSE = np.sqrt(np.mean((ring_concentration-ring_flux)**2) )
RMSPE = RMSE*100/np.mean(ring_concentration)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(60,0.02, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.xlabel('Time (days)')
plt.ylabel(r'$\mu$mol H/mm')
plt.title(f'Conservation of Mass: 2D Ring')
plt.xlim(0,t.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

difference = abs(ring_flux-ring_concentration)
plt.figure(figsize=(10, 6))
plt.plot(t,difference)
plt.xlabel('Time (days)')
plt.ylabel(r'$\mu$mol H/mm')
plt.title(f'Conservation of Mass Difference: 2D Ring')
plt.xlim(0,t.max())
plt.grid(True)
plt.tight_layout()
plt.show()

# Measure and Plot Conservation of Mass in 3D (for axisymmetric coordinates)
plt.figure(figsize=(10, 6))
plt.plot(t, annulus_flux, label = 'Accumulated Boundary Flux')
plt.plot(t,annulus_total_mass, label = 'Total Mass in Annulus')
RMSE = np.sqrt(np.mean((annulus_total_mass-annulus_flux)**2) )
RMSPE = RMSE*100/np.mean(annulus_total_mass)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(60,5, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.xlabel('Time (Days)')
plt.ylabel(r'$\mu$mol H')
plt.title(f'Conservation of Mass: 3D Annulus')
plt.xlim(0,t.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

difference = abs(annulus_flux-annulus_total_mass)
plt.figure(figsize=(10, 6))
plt.plot(t,difference)
plt.xlabel('Time (Days)')
plt.ylabel(r'$\mu$mol H')
plt.title(f'Conservation of Mass Difference: 3D Annulus')
plt.xlim(0,t.max())
plt.grid(True)
plt.tight_layout()
plt.show()

# # Pressure Paramter Study
# pressure = parameter_study_data['pressure']
# yields = parameter_study_data['yield']

# # Pressure Parameter Study
# plt.figure(figsize=(10, 6))
# plt.plot(pressure,yields,'ro')
# plt.ylabel(r'H Total Mass ($\mu$mol)')
# plt.xlabel('Pressure (psi)')
# plt.title(f'Atomic Hydrogen in Steel over 1-10% Hydrogen Content in 24 psi He Backfill')
# plt.xlim(0)
# plt.ylim(0)
# plt.grid(True)
# plt.tight_layout()
# plt.show()

# plt.figure(figsize=(10, 6))
# plt.plot(pressure,yields/assumed_gas_total_mass[0]*100)
# plt.ylabel('Percentage (%)')
# plt.xlabel('Pressure (psi)')
# plt.title(f'Atomic Hydrogen in Steel over 1-10% Hydrogen Content in 24 psi He Backfill')
# plt.xlim(0)
# plt.ylim(0)
# plt.grid(True)
# plt.tight_layout()
# plt.show()

# # Percentage of Hydrogen in steel vs hydrogen in canister
# plt.figure(figsize=(10, 6))
# # plt.plot(t,100*annulus_total_mass/initial_canister_concentration) # Total mass vs concentration?? Units off
# plt.plot(t,100*annulus_total_mass/assumed_gas_total_mass)
# plt.ylabel('Percentage %')
# plt.xlabel('Time (days)')
# plt.title(f'Percentage of Total Hydrogen in Steel (Estimated Generation from Ideal Gas Law)')
# plt.xlim(0)
# plt.ylim(0)
# plt.grid(True)
# plt.tight_layout()
# plt.show()
