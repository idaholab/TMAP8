import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load CSV data
data = pd.read_csv('steel_only_out.csv')

# Gather Data
t = data['time']
steel_total_mass = data['3d_mass_in_domain']
steel_flux = data['3d_time_integrated_flux']
exact_diffusion_length = data['exact_diffusion_length']
simulated_diffusion_length = data['simulated_diffusion_length']
assumed_gas_total_mass = 2*data['assumed_gas_total_mass'] # Count Atomic Hydrogen
assumed_total_mass = assumed_gas_total_mass + steel_total_mass


# Total Mass and Percentage in Steel
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plot the total mass data
ax1.plot(t, steel_total_mass, label = 'H Total Mass')
ax1.set_ylabel(r'H Total Mass ($\mu$mol)')
ax1.set_xlabel('Time (days)')
ax1.set_title(f'Atomic Hydrogen H in Steel vs Time')
ax1.set_xlim(0)
ax1.set_ylim(0)
ax1.grid(True)

# Plot Percentage data for assumed mass in gas-phase
ax2 = ax1.twinx()
ax2.set_ylabel('% H in Steel', color='k')
percentage = 100. * steel_total_mass / assumed_total_mass
ax2.plot(t, percentage, color='tab:orange', linestyle='--', label='% in Steel')
ax2.set_ylim(0)

lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2)
plt.savefig("steel_only_hydrogen_yield.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Check length of diffusion front
fig = plt.figure(figsize=(10, 6))
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
plt.savefig("diffusion_length.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Plot conservation of mass
fig = plt.figure(figsize=(10, 6))
plt.plot(t, steel_flux, label = 'Accumulated Boundary Flux')
plt.plot(t,steel_total_mass, label = 'H Total Mass')
RMSE = np.sqrt(np.mean((steel_total_mass-steel_flux)**2) )
RMSPE = RMSE*100/np.mean(steel_total_mass)
print(f'RMSPE = %.2f '%RMSPE+'%')
plt.text(60,5, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.xlabel('Time (Days)')
plt.ylabel(r'$\mu$mol H')
plt.title(f'Conservation of Mass')
plt.xlim(0,t.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.savefig("steel_only_COM.png", bbox_inches="tight", dpi=300)
plt.close(fig)
