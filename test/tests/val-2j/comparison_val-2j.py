import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_folder)

# Set path to gold folder based on whether script is run from docs or test directory
if "/tmap8/doc/" in script_folder.lower():
    gold_folder = "../../../../test/tests/val-2j/gold"
else:
    gold_folder = "./gold"

# ============================================================
# Read experimental data
# ============================================================

exp_e = pd.read_csv(os.path.join(gold_folder, "experiment_data_sample_e.csv"))
exp_e_temp = exp_e["temperature (K)"].values
exp_e_release = exp_e["release_rate (arb)"].values
exp_e_norm = exp_e_release / np.max(np.abs(exp_e_release))


def compute_rmspe(sim_temp, sim_norm, exp_temp, exp_norm, threshold_frac=0.05):
    """Compute RMSPE between interpolated simulation and experimental data.

    Only points where the experimental value exceeds threshold_frac of the
    experimental maximum are included.

    Args:
        sim_temp: simulation temperature array
        sim_norm: normalized simulation release rate
        exp_temp: experimental temperature array
        exp_norm: normalized experimental release rate
        threshold_frac: fraction of max experimental value used as filter

    Returns:
        float: RMSPE value in percent
    """
    sim_interp = np.interp(exp_temp, sim_temp, sim_norm)
    mask = exp_norm > threshold_frac * np.max(np.abs(exp_norm))
    rmse = np.sqrt(np.mean((sim_interp[mask] - exp_norm[mask]) ** 2))
    rmspe = rmse * 100.0 / np.mean(np.abs(exp_norm[mask]))
    return rmspe


# ============================================================
# Figure 1: Reference parameters vs experiment
# ============================================================

sim_ref = pd.read_csv(os.path.join(gold_folder, "val-2j_out.csv"))
sim_ref_temp = sim_ref["temperature_pp"]
sim_ref_release = np.abs(sim_ref["release_rate"])
sim_ref_norm = sim_ref_release / sim_ref_release.max()

rmspe_ref = compute_rmspe(sim_ref_temp, sim_ref_norm, exp_e_temp, exp_e_norm)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(
    sim_ref_temp,
    sim_ref_norm,
    linestyle="-",
    label="TMAP8",
    color="tab:red",
)
ax.plot(
    exp_e_temp,
    exp_e_norm,
    marker="o",
    linestyle="None",
    markerfacecolor="none",
    markeredgecolor="k",
    label="Experimental (Sample E)",
)

ax.set_xlabel("Temperature (K)")
ax.set_ylabel("Normalized tritium release rate (-)")
ax.set_xlim(300, 900)
ax.legend(loc="best")
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()
ax.text(
    0.95,
    0.90,
    f"RMSPE = {rmspe_ref:.2f}%",
    fontweight="bold",
    transform=ax.transAxes,
    ha="right",
)
plt.savefig("val-2j_comparison_sample_e.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# ============================================================
# Figure 2: Optimized parameters vs experiment
# ============================================================

sim_opt = pd.read_csv(os.path.join(gold_folder, "optimal_bayesian_params_out.csv"))
sim_opt_temp = sim_opt["temperature_pp"]
sim_opt_release = np.abs(sim_opt["release_rate"])
sim_opt_norm = sim_opt_release / sim_opt_release.max()

rmspe_opt = compute_rmspe(sim_opt_temp, sim_opt_norm, exp_e_temp, exp_e_norm)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(
    sim_opt_temp,
    sim_opt_norm,
    linestyle="-",
    label="TMAP8 (optimized)",
    color="tab:red",
)
ax.plot(
    exp_e_temp,
    exp_e_norm,
    marker="o",
    linestyle="None",
    markerfacecolor="none",
    markeredgecolor="k",
    label="Experimental (Sample E)",
)

ax.set_xlabel("Temperature (K)")
ax.set_ylabel("Normalized tritium release rate (-)")
ax.set_xlim(300, 900)
ax.legend(loc="best")
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()
ax.text(
    0.95,
    0.90,
    f"RMSPE = {rmspe_opt:.2f}%",
    fontweight="bold",
    transform=ax.transAxes,
    ha="right",
)
plt.savefig("val-2j_comparison_optimized.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# ============================================================
# Print RMSPE values
# ============================================================

print(f"Reference parameters RMSPE = {rmspe_ref:.2f}%")
print(f"Optimized parameters RMSPE = {rmspe_opt:.2f}%")
