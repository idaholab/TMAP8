import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load CSV data
data = pd.read_csv("gas_steel_out.csv")
data_steel_only = pd.read_csv("steel_only_out.csv")
SRNL_data = pd.read_csv("gold/SRNL_data.csv")

# Gather simulation data
t = data["time"]
H_partial_pressure_interface = data["H_partial_pressure_interface"]  # Pa
total_mass_steel = data["cylinder_total_mass_steel"]
total_mass_gas = data["cylinder_total_mass_gas"]
total_mass = data["cylinder_total_mass"]
time_integrated_flux = data["cylinder_time_integrated_flux"]
total_generation = data["cylinder_total_generation"]
# Steel-only simulation data for comparison (most recent run of steel_only.i)
steel_only_total_mass_steel = data_steel_only["3d_mass_in_domain"]
t_steel = data_steel_only["time"]
# SRNL data for validation assuming 124 Gy/min in Cobalt-60 irraditator
SRNL_time = SRNL_data["Dose (MGy)"] * 365.25 / 65.21904
SRNL_total_mass_gas = 2 * SRNL_data["Cum. H2 yield (μmol)"]  # Count H atoms
SRNL_partial_pressure = (
    1e3 * SRNL_data["Gas pressure (kPa)"] * SRNL_data["H2 gas fraction (%)"] / 100
)


# Linear Mapping of simulation data to experimental data for validation
def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output):
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
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (
            tmap_input[right_limit] - tmap_input[left_limit]
        ) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[
            left_limit
        ]
    return new_tmap_output


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
percentage = 100 * total_mass_steel / total_mass
ax2.plot(t, percentage, color="tab:orange", linestyle="--")
ax2.set_ylabel("% H in Steel", color="tab:orange")
ax2.tick_params(axis="y", colors="tab:orange")
ax2.set_ylim(0)
plt.savefig("gas_steel_hydrogen_yield.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Plot SRNL Partial Pressure measurements
fig = plt.figure(figsize=(10, 6))
plt.plot(SRNL_time, SRNL_partial_pressure, "ro", label="Experimental Data")
plt.plot(t, H_partial_pressure_interface, label="Full Simulation")
mapped_pressure = numerical_solution_on_experiment_input(
    SRNL_time, t, H_partial_pressure_interface
)
RMSE = np.sqrt(np.mean((mapped_pressure - SRNL_partial_pressure) ** 2))
RMSPE = RMSE * 100 / np.mean(SRNL_partial_pressure)
plt.text(
    t.iloc[-1] / 2,
    H_partial_pressure_interface.iloc[-1] / 4,
    "RMSPE = %.2f " % RMSPE + "%",
    fontweight="bold",
)
plt.ylabel(r"H_2 Partial Pressure (Pa)")
plt.xlabel("Time (Days)")
plt.title(f"Interface Partial Pressure: SRNL Data vs. Gas-steel model")
plt.xlim(0)
plt.legend()
plt.ylim(0)
plt.grid(True)
plt.savefig("partial_pressure_comparison.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Comparison of Concentration in Steel between two models
# Error handling if different number of timesteps are taken between two simulations
if len(t_steel) < len(t):
    total_mass_steel_RMSPE = numerical_solution_on_experiment_input(
        t_steel, t, total_mass_steel
    )
    RMSE = np.sqrt(np.mean((steel_only_total_mass_steel - total_mass_steel_RMSPE) ** 2))
    RMSPE = RMSE * 100 / np.mean(steel_only_total_mass_steel)
elif len(t_steel) > len(t):
    steel_only_total_mass_steel_RMSPE = numerical_solution_on_experiment_input(
        t, t_steel, steel_only_total_mass_steel
    )
    RMSE = np.sqrt(np.mean((steel_only_total_mass_steel_RMSPE - total_mass_steel) ** 2))
    RMSPE = RMSE * 100 / np.mean(steel_only_total_mass_steel_RMSPE)
else:
    RMSE = np.sqrt(np.mean((steel_only_total_mass_steel - total_mass_steel) ** 2))
    RMSPE = RMSE * 100 / np.mean(steel_only_total_mass_steel)
fig = plt.figure(figsize=(10, 6))
plt.plot(t_steel, steel_only_total_mass_steel, label="Steel-only Simulation")
plt.plot(t, total_mass_steel, label="Gas-steel Simulation")
plt.text(
    t.iloc[-1] / 2,
    total_mass_steel.iloc[-1] / 4,
    "RMSPE = %.2f " % RMSPE + "%",
    fontweight="bold",
)
plt.ylabel(r"Cum. H Mass ($\mu$mol)")
plt.xlabel("Time (Days)")
plt.title(f"Steel H Total Mass Model Comparison")
plt.xlim(0)
plt.legend()
plt.ylim(0)
plt.grid(True)
plt.savefig("hydrogen_yield_model_comparison.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Total Hydrogen in the Gas compared to SRNL experimental data
fig = plt.figure(figsize=(10, 6))
plt.plot(t, total_mass_gas, label="Simulation")
plt.plot(SRNL_time, SRNL_total_mass_gas, "ro", label="Experimental Data")
# Map simulation results to experimental data
simulation_mapped_total_mass_gas = numerical_solution_on_experiment_input(
    SRNL_time, t, total_mass_gas
)
RMSE = np.sqrt(np.mean((simulation_mapped_total_mass_gas - SRNL_total_mass_gas) ** 2))
RMSPE = RMSE * 100 / np.mean(SRNL_total_mass_gas)
plt.text(
    t.iloc[-1] / 2,
    total_mass_gas.iloc[-1] / 4,
    "RMSPE = %.2f " % RMSPE + "%",
    fontweight="bold",
)
plt.legend()
plt.ylabel(r"H_2 Total Mass ($\mu$mol $H_2$)")
plt.xlabel("Time (Days)")
plt.title(r"$H_2$ in Gas Phase vs Time")
plt.xlim(0)
plt.ylim(0)
plt.grid(True)
plt.savefig("gas_phase_validation.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# Measure and Plot Conservation of Mass in 3D (for axisymmetric coordinates)
fig = plt.figure(figsize=(10, 6))
plt.plot(
    t,
    time_integrated_flux + total_generation,
    label="Accumulated Boundary Flux + Source",
)
plt.plot(t, total_mass, label="H Total Mass")
RMSE = np.sqrt(np.mean((total_mass - time_integrated_flux - total_generation) ** 2))
RMSPE = RMSE * 100 / np.mean(total_mass)
plt.text(
    t.iloc[-1] / 2,
    total_mass.iloc[-1] / 4,
    "RMSPE = %.2f " % RMSPE + "%",
    fontweight="bold",
)
plt.xlabel("Time (Days)")
plt.ylabel(r"$\mu$mol H")
plt.title(f"Conservation of Mass")
plt.xlim(0, t.max())
plt.ylim(0)
plt.legend()
plt.grid(True)
plt.savefig("gas_steel_conservation_of_mass.png", bbox_inches="tight", dpi=300)
plt.close(fig)
