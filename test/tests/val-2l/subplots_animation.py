import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import os
import glob

script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# LineValueSampler output lives in a directory named after the VectorPostprocessor
# (val-2l.i: [VectorPostprocessors]/deuterium_mobile_concentration_profile).
profile_files = sorted(glob.glob(
    "deuterium_mobile_concentration_profile/"
    "val-2l_out_deuterium_mobile_concentration_profile_*.csv"
))
near_surface_limit_um = 20.0  # depth (um) shown in the lower zoom subplot
frame_stride = 5  # show every Nth timestep — keeps the movie fast to encode and compact

# Time of each profile: file index i aligns with row i of the global CSV
# (both include the INITIAL step at t = 0).
times = pd.read_csv("val-2l_out.csv")["time"].values

# Read each kept profile exactly once and cache its arrays, so the rest of the
# script (axis limits + every animation frame) reuses the data instead of
# re-parsing the CSVs. MOOSE writes a header-only file for the INITIAL step, so
# skip empties; subsample by frame_stride to avoid reading files we won't show.
frames = []
for i, f in enumerate(profile_files):
    if i >= len(times) or i % frame_stride != 0:
        continue
    df = pd.read_csv(f, skipinitialspace=True)
    if df.shape[0] == 0:
        continue
    frames.append((df["x"].values, df["deuterium_mobile_concentration"].values, times[i]))
if not frames:
    raise FileNotFoundError("No non-empty concentration profile CSV files found.")

# Fixed axis limits across all frames (computed from the cached arrays).
c_max = max(c.max() for _, c, _ in frames) * 1.05
x_max_um = frames[0][0].max()

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), constrained_layout=True)

# Build the line artists and static styling ONCE. The animation then only updates
# each line's data per frame instead of clearing and re-styling both axes.
# Markers sit on each mesh node (the NodalValueSampler points), so they reveal the
# graded element layout: dense at the surface, sparse in the bulk.
lines = []
for ax, xlim, color in ((ax1, x_max_um, "steelblue"),
                        (ax2, near_surface_limit_um, "darkorange")):
    (line,) = ax.plot([], [], color=color, linewidth=1.5,
                      marker="o", markersize=4, markerfacecolor="white",
                      markeredgecolor=color, markeredgewidth=1.0)
    ax.set_xlim(0, xlim)
    ax.set_ylim(0, c_max)
    ax.set_xlabel(r"Depth ($\mu$m)")
    ax.set_ylabel(r"Concentration (at/$\mu$m$^3$)")
    ax.grid(True)
    lines.append((line, xlim))
ax2.set_title(f"Near-surface (0 – {near_surface_limit_um:g} $\\mu$m)")
title = ax1.set_title("")


def animate(frame):
    x, c, t = frames[frame]
    artists = []
    for line, xlim in lines:
        mask = x <= xlim
        line.set_data(x[mask], c[mask])
        artists.append(line)
    title.set_text(f"Deuterium in Tungsten — t = {t:7.1f} s")
    artists.append(title)
    return artists


ani = animation.FuncAnimation(fig, animate, frames=len(frames), interval=100, blit=True)

# Use ffmpeg if available, otherwise fall back to Pillow (gif)
if animation.writers.is_available("ffmpeg"):
    output_file = "val-2l_concentration_animation.mp4"
    ani.save(output_file, writer="ffmpeg", fps=10)
else:
    output_file = "val-2l_concentration_animation.gif"
    ani.save(output_file, writer="pillow", fps=10)

plt.close(fig)
print(f"Saved {output_file} ({len(frames)} frames)")
