import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import os
import glob

script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# Filter out empty files — MOOSE writes a header-only file for the INITIAL step
all_files = sorted(glob.glob("concentration_profile/val-2k_out_concentration_profile_*.csv"))
profile_files = [
    f for f in all_files
    if pd.read_csv(f, skipinitialspace=True).shape[0] > 0
]
num_timesteps = len(profile_files)

if num_timesteps == 0:
    raise FileNotFoundError(
        "No non-empty concentration profile CSV files found. "
        "Run the simulation with VectorPostprocessors enabled."
    )

global_data = pd.read_csv("val-2k_out.csv")
times = global_data["time"].values

near_surface_limit_um = 1.0  # μm shown in lower subplot

# Pre-scan non-empty files for fixed axis limits across all frames
c_max = 0.0
for f in profile_files:
    df = pd.read_csv(f, skipinitialspace=True)
    c_max = max(c_max, df["concentration"].max())
c_max *= 1.05

x_max_um = pd.read_csv(profile_files[0], skipinitialspace=True)["x"].max()

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), constrained_layout=True)


def animate(frame):
    ax1.clear()
    ax2.clear()

    df = pd.read_csv(profile_files[frame], skipinitialspace=True)
    x = df["x"].values              # μm
    c = df["concentration"].values  # at/μm³

    time_s = times[frame] if frame < len(times) else times[-1]

    # Full-domain profile
    ax1.plot(x, c, color="steelblue", linewidth=1.5)
    ax1.set_xlim(0, x_max_um)
    ax1.set_ylim(0, c_max)
    ax1.set_xlabel(r"Depth ($\mu$m)")
    ax1.set_ylabel(r"Concentration (at/$\mu$m$^3$)")
    ax1.set_title(f"Deuterium in Tungsten — t = {time_s:.2f} s")
    ax1.grid(True)

    # Near-surface zoom
    mask = x <= near_surface_limit_um
    ax2.plot(x[mask], c[mask], color="darkorange", linewidth=1.5)
    ax2.set_xlim(0, near_surface_limit_um)
    ax2.set_ylim(0, c_max)
    ax2.set_xlabel(r"Depth ($\mu$m)")
    ax2.set_ylabel(r"Concentration (at/$\mu$m$^3$)")
    ax2.set_title(f"Near-surface (0 – {near_surface_limit_um} $\\mu$m)")
    ax2.grid(True)

    return ax1, ax2


ani = animation.FuncAnimation(
    fig, animate, frames=num_timesteps, interval=100, blit=False
)

# Use ffmpeg if available, otherwise fall back to Pillow (gif)
if animation.writers.is_available("ffmpeg"):
    output_file = "val-2k_concentration_animation.mp4"
    ani.save(output_file, writer="ffmpeg", fps=10)
else:
    output_file = "val-2k_concentration_animation.gif"
    ani.save(output_file, writer="pillow", fps=10)

plt.close(fig)
print(f"Saved {output_file} ({num_timesteps} frames)")
