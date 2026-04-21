import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load CSV data
data = pd.read_csv("steel_only_out.csv")

# Gather data
t = data["time"]
total_mass_steel = data["3d_mass_in_domain"]
flux_steel = data["3d_time_integrated_flux"]
exact_diffusion_length = data["exact_diffusion_length"]
simulated_diffusion_length = data["simulated_diffusion_length"]
assumed_gas_total_mass = 2 * data["assumed_gas_total_mass"]  # Count Atomic Hydrogen
assumed_total_mass = assumed_gas_total_mass + total_mass_steel

# Total Mass and Percentage in Steel
fig, ax1 = plt.subplots(figsize=(10, 6))
ax1.plot(t, total_mass_steel, color="tab:blue")
ax1.set_ylabel(r"H Total Mass ($\mu$mol)", color="tab:blue")
ax1.tick_params(axis="y", colors="tab:blue")
ax1.set_xlabel("Time (Days)")
ax1.set_title(f"Hydrogen H in Steel vs Time")
ax1.set_xlim(0)
ax1.set_ylim(0)
ax1.grid(True)
ax2 = ax1.twinx()
percentage = 100 * total_mass_steel / assumed_total_mass
ax2.plot(t, percentage, color="tab:orange", linestyle="--")
ax2.set_ylabel("% H in Steel", color="tab:orange")
ax2.tick_params(axis="y", colors="tab:orange")
ax2.set_ylim(0)
plt.savefig("steel_only_hydrogen_yield.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Check length of diffusion front
fig = plt.figure(figsize=(10, 6))
plt.plot(t, exact_diffusion_length, label="Exact Diffusion Length sqrt(pi*D*t)")
plt.plot(t, simulated_diffusion_length, label=f"Simulated Diffusion Length")
RMSE = np.sqrt(np.mean((simulated_diffusion_length - exact_diffusion_length) ** 2))
RMSPE = RMSE * 100 / np.mean(exact_diffusion_length)
plt.text(80, 0.1, "RMSPE = %.2f " % RMSPE + "%", fontweight="bold")
plt.legend()
plt.ylabel("Length (mm)")
plt.xlabel("Time (days)")
plt.title(f"Hydrogen Canister Simulation: 1D Diffusion Front Length")
plt.xlim(0)
plt.ylim(0)
plt.grid(True)
plt.savefig("diffusion_length.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Plot conservation of mass
fig = plt.figure(figsize=(10, 6))
plt.plot(t, flux_steel, label="Accumulated Boundary Flux")
plt.plot(t, total_mass_steel, label="H Total Mass")
RMSE = np.sqrt(np.mean((total_mass_steel - flux_steel) ** 2))
RMSPE = RMSE * 100 / np.mean(total_mass_steel)
plt.text(60, 5, "RMSPE = %.2f " % RMSPE + "%", fontweight="bold")
plt.xlabel("Time (Days)")
plt.ylabel(r"$\mu$mol H")
plt.title(f"Conservation of Mass")
plt.xlim(0, t.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.savefig("steel_only_conservation_of_mass.png", bbox_inches="tight", dpi=300)
plt.close(fig)
