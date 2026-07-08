"""DIR recovery fractions and upstream T2 pressures for the two PCC DIR membranes.

Both quantities come from the multiscale result ``dir_pcc_fuel_cycle_2rt_10Pa_out2.csv``:

- Left axis (blue)   : upstream T2 partial pressure feeding each DIR membrane (VP, FCU)
                       [Pa], drawn at full resolution (VP solid, FCU dashed).
- Right axis (orange): the resulting DIR recovery fraction (flux_to_storage / DIR feed
                       flux) [-], linear 0-1.

Quantities are colored by axis (pressure = blue/C0, DIR fraction = orange/C1) and the
axis labels/ticks/spines are colored to match. The result CSV holds tens of thousands of
rows, so the DIR-fraction curves are drawn at log-spaced sample points with open markers
(VP circles, FCU squares); otherwise the dashed lines merge into a solid block on the log
time axis. The pressure curves keep full resolution so the early per-pulse oscillation
envelope stays visible. A dotted horizontal line marks the baseline (fixed) VP DIR
fraction = 0.3 from ``fuel_cycle_2023/fuel_cycle_base.i`` (the base model has no separate
FCU DIR, i.e. 0).
"""

import os

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

plt.rcParams.update({"font.size": 18})

script_folder = os.path.dirname(os.path.abspath(__file__))
if "/TMAP8/doc/" in script_folder:  # documentation build
    test_dir = "../../../../test/tests/PCC_multiscale_example"
else:  # test folder
    test_dir = script_folder
csv_candidates = [
    os.path.join(test_dir, "dir_pcc_fuel_cycle_2rt_10Pa_out2.csv"),
    os.path.join(test_dir, "gold", "dir_pcc_fuel_cycle_2rt_10Pa_out2_reference.csv"),
]
dir_csv = next((candidate for candidate in csv_candidates if os.path.isfile(candidate)), None)
if dir_csv is None:
    raise FileNotFoundError(
        "Could not find a PCC DIR pressure/fraction CSV in {}".format(csv_candidates)
    )
figures_dir = os.path.join(test_dir, "figures")
os.makedirs(figures_dir, exist_ok=True)

time_unit = 3600 * 24  # seconds per day
baseline_dir_vp = 0.3  # fuel_cycle_base.i f_DIR (VP only; FCU baseline = 0)

pcc = pd.read_csv(dir_csv)
t = pcc["time"].values / time_unit

fig, ax = plt.subplots(figsize=[6.5, 5.5])
ax2 = ax.twinx()

# Left axis: upstream pressures (solid). Thin lines so the early per-pulse oscillation
# envelope (bang-bang transient before the coupling reaches steady state) stays legible.
sample_times = np.logspace(np.log10(0.1), np.log10(t.max()), 30000)
sample_idx = np.unique(np.searchsorted(t, sample_times).clip(0, len(t) - 1))
ts = t[sample_idx]
(p_vp,) = ax.plot(
    t, pcc["pressure_VP"].values, "-", color="C0", lw=1.5, alpha=0.6, label="VP pressure"
)
(p_fcu,) = ax.plot(
    ts, pcc["pressure_FCU"].values[sample_idx], "--", color="C0", lw=1.5, label="FCU pressure"
)

# Right axis: computed DIR fractions. Sample at log-spaced times so the dashed lines stay
# legible (the raw CSV has tens of thousands of rows, which renders as a solid block).
sample_times = np.logspace(np.log10(0.1), np.log10(t.max()), 1000)
sample_idx = np.unique(np.searchsorted(t, sample_times).clip(0, len(t) - 1))
ts = t[sample_idx]
(f_vp,) = ax2.plot(
    t,
    pcc["DIR_fraction_VP"].values,
    linestyle="-",
    color="C1",
    lw=1.5,
    alpha=0.6,
    label="VP DIR fraction",
)
(f_fcu,) = ax2.plot(
    ts,
    pcc["DIR_fraction_FCU"].values[sample_idx],
    linestyle="--",
    color="C1",
    lw=1.5,
    label="FCU DIR fraction",
)
base_line = ax2.axhline(
    baseline_dir_vp, ls=":", color="C1", lw=3, label="baseline DIR"
)

ax.set_xlabel("Time (days)")
# Left axis (pressure) in blue, right axis (DIR fraction) in orange.
ax.set_ylabel("Upstream T$_2$ pressure (Pa)", color="C0")
ax2.set_ylabel("DIR fraction (-)", color="C1")
ax.tick_params(axis="y", colors="C0")
ax2.tick_params(axis="y", colors="C1")
ax.spines["left"].set_color("C0")
ax.spines["right"].set_color("C1")
ax2.spines["left"].set_color("C0")
ax2.spines["right"].set_color("C1")
ax.set_xscale("log")
ax.set_xlim(left=0.1, right=1)
ax.set_ylim(bottom=-5, top=2e1)
ax.set_xticks([0.1, 1])
# ax.set_xticklabels([r"10^{-1}", "10^0"])
ax2.set_ylim(0, 1.05)
ax.xaxis.set_minor_formatter("")
# Scientific notation on the left (pressure) axis, with the 1e4 offset colored to match.
# ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
ax.yaxis.get_offset_text().set_color("C0")
# Legend drawn on the twin (top) axes with a high z-order so its text/handles stay above
# every curve. The frame is transparent so the curves behind it remain visible.
# Matplotlib packs legend columns as contiguous slices with the extra entry in the FIRST
# column, so 5 handles give 3/2. Pad with an invisible spacer at the bottom of column 1 so
# the split becomes 2 (pressures) / 3 (DIR fractions).
blank = plt.Line2D([], [], linestyle="none", marker="", label=" ")
legend = ax2.legend(
    handles=[p_vp, p_fcu, blank, f_fcu, f_vp, base_line],
    loc="lower center",
    bbox_to_anchor=(0.49, 0.03),
    ncol=2,
    fontsize=14,
    framealpha=0.8,
)
legend.set_zorder(10)
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

fig_path = os.path.join(figures_dir, "dir_pcc_dir_fraction_pressure.png")
plt.savefig(fig_path, bbox_inches="tight", dpi=300)
plt.close(fig)
print(f"Saved {fig_path}")
