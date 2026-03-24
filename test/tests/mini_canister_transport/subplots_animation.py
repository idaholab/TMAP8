import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import os
import glob

# Directory containing your CSV files
data_dir = 'csv_data'

# Get all gas files to determine number of timesteps
gas_files = sorted(glob.glob(os.path.join(data_dir, "verification_RZ_solution_profile_gas_*.csv")))
steel_files = sorted(glob.glob(os.path.join(data_dir, "verification_RZ_solution_profile_steel_*.csv")))

num_timesteps = len(gas_files)

# Set up the figure and axes
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), sharex=False)

def animate(timestep):
    ax1.clear()
    ax2.clear()

    timestep += 1  # because files start at 0001

    # File paths
    gas_path = os.path.join(data_dir, f"verification_RZ_solution_profile_gas_{timestep:04d}.csv")
    steel_path = os.path.join(data_dir, f"verification_RZ_solution_profile_steel_{timestep:04d}.csv")
    total_df = pd.read_csv(os.path.join(data_dir,"verification_RZ.csv"), skipinitialspace = True)

    # Load data
    gas_df = pd.read_csv(gas_path, skipinitialspace=True)
    steel_df = pd.read_csv(steel_path, skipinitialspace=True)

    # Extract data
    gas_x = gas_df['x']
    steel_x = steel_df['x']
    gas_var = gas_df.columns[0]
    steel_var = steel_df.columns[0]
    gas_values = gas_df[gas_var]
    steel_values = steel_df[steel_var]
    time = total_df['time']

    # Plot gas
    ax1.plot(gas_x, gas_values, color='blue')
    ax1.set_xlim(gas_x.min(), gas_x.max())
    ax1.set_ylim(gas_values.min()*0.995, gas_values.max()*1.005)
    ax1.set_ylabel(r'Molecular H$_2$ Concentration in Gas ($\mu$mol/mm$^3$)')
    ax1.set_title(f'Timestep {timestep} at Time: {time[timestep-1]:01.2f} days')
    ax1.grid(True)

    # Plot steel
    ax2.plot(steel_x, steel_values, color='green')
    ax2.set_xlim(steel_x.min(), steel_x.max())
    ax2.set_ylim(steel_values.min(), steel_values.max())
    ax2.set_ylabel(r'Atomic H Concentration in Steel ($\mu$mol/mm$^3$)')
    ax2.set_xlabel('Distance from Canister Center (mm)')
    # ax2.set_title(f'Steel - Timestep {timestep}')
    ax2.grid(True)

    return ax1, ax2

# Create animation
ani = animation.FuncAnimation(fig, animate, frames=num_timesteps, interval=300, blit=False)

# Save animation
ani.save('subplot_bar_profile_animation.mp4', writer='ffmpeg', fps=5)

plt.close()
