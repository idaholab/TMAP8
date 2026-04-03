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
exp_e_temperature = exp_e["temperature (K)"].values
exp_e_release = exp_e["release_rate (arb)"].values
exp_e_norm = exp_e_release / np.max(np.abs(exp_e_release))


def compute_rmspe(
    sim_temperature, sim_norm, exp_temperature, exp_norm, threshold_frac=0.05
):
    """Compute RMSPE between interpolated simulation and experimental data.

    Only points where the experimental value exceeds threshold_frac of the
    experimental maximum are included.

    Args:
        sim_temperature: simulation temperature array
        sim_norm: normalized simulation release rate
        exp_temperature: experimental temperature array
        exp_norm: normalized experimental release rate
        threshold_frac: fraction of max experimental value used as filter

    Returns:
        float: RMSPE value in percent
    """
    sim_interp = np.interp(exp_temperature, sim_temperature, sim_norm)
    mask = exp_norm > threshold_frac * np.max(np.abs(exp_norm))
    rmse = np.sqrt(np.mean((sim_interp[mask] - exp_norm[mask]) ** 2))
    rmspe = rmse * 100.0 / np.mean(np.abs(exp_norm[mask]))
    return rmspe


# ============================================================
# Figure 1: Reference parameters vs experiment
# ============================================================

sim_ref = pd.read_csv(os.path.join(gold_folder, "val-2j_out.csv"))
sim_ref_temperature = sim_ref["temperature_pp"]
sim_ref_release = np.abs(sim_ref["release_rate"])
sim_ref_norm = sim_ref_release / sim_ref_release.max()

rmspe_ref = compute_rmspe(
    sim_ref_temperature, sim_ref_norm, exp_e_temperature, exp_e_norm
)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(
    sim_ref_temperature,
    sim_ref_norm,
    linestyle="-",
    label="TMAP8",
    color="tab:red",
)
ax.plot(
    exp_e_temperature,
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
ax.set_ylim(bottom=0)
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

sim_opt = pd.read_csv(
    os.path.join(gold_folder, "val-2j_optimal_bayesian_params_out.csv")
)
sim_opt_temperature = sim_opt["temperature_pp"]
sim_opt_release = np.abs(sim_opt["release_rate"])
sim_opt_norm = sim_opt_release / sim_opt_release.max()

rmspe_opt = compute_rmspe(
    sim_opt_temperature, sim_opt_norm, exp_e_temperature, exp_e_norm
)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(
    sim_opt_temperature,
    sim_opt_norm,
    linestyle="-",
    label="TMAP8 (optimized)",
    color="tab:red",
)
ax.plot(
    exp_e_temperature,
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
ax.set_ylim(bottom=0)
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
# Figure 2b: Defect density evolution during TDS
# ============================================================

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(
    sim_ref["temperature_pp"],
    sim_ref["defect_density_pp"] / sim_ref["defect_density_pp"].iloc[0],
    linestyle="-",
    label="TMAP8",
    color="tab:red",
)

ax.set_xlabel("Temperature (K)")
ax.set_ylabel("Normalized defect density $D_{id}/D_{id,0}$ (-)")
ax.set_xlim(300, 900)
ax.set_ylim(0, 1.05)
ax.legend(loc="best")
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()
plt.savefig("val-2j_defect_density_evolution.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# ============================================================
# Figure 3: Arrhenius parameter comparison (reference vs optimized)
# ============================================================

kB_eV = 8.617333262e-5  # Boltzmann constant in eV/K
temperature_array = np.linspace(300, 900, 500)  # K
inverse_temperature = 1.0 / temperature_array  # 1/K

# Reference parameters
D0_ref, Ed_ref = 6.9e-7, 1.07
at0_ref, et_ref = 4.2e8, 1.04
ar0_ref, er_ref = 4.1e6, 1.19

# Optimized parameters
D0_opt_val, Ed_opt_val = 8.190614e-5, 0.970690
at0_opt_val, et_opt_val = 1.290375e9, 0.887460
ar0_opt_val, er_opt_val = 2.486356e5, 1.100495

D_ref = D0_ref * np.exp(-Ed_ref / (kB_eV * temperature_array))
D_opt_arr = D0_opt_val * np.exp(-Ed_opt_val / (kB_eV * temperature_array))

at_ref = at0_ref * np.exp(-et_ref / (kB_eV * temperature_array))
at_opt_arr = at0_opt_val * np.exp(-et_opt_val / (kB_eV * temperature_array))

ar_ref = ar0_ref * np.exp(-er_ref / (kB_eV * temperature_array))
ar_opt_arr = ar0_opt_val * np.exp(-er_opt_val / (kB_eV * temperature_array))

fig, axes = plt.subplots(1, 3, figsize=[14, 4.5])

# Panel 1: Diffusivity D(T)
ax = axes[0]
ax.semilogy(1000 * inverse_temperature, D_ref, "-", color="tab:blue", label="Reference")
ax.semilogy(
    1000 * inverse_temperature, D_opt_arr, "--", color="tab:red", label="Optimized"
)
ax.set_xlabel("1000/T (1/K)")
ax.set_ylabel("D (m$^2$/s)")
ax.set_title("Diffusivity")
ax.legend()
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

# Panel 2: Trapping rate alpha_t(T)
ax = axes[1]
ax.semilogy(
    1000 * inverse_temperature, at_ref, "-", color="tab:blue", label="Reference"
)
ax.semilogy(
    1000 * inverse_temperature, at_opt_arr, "--", color="tab:red", label="Optimized"
)
ax.set_xlabel("1000/T (1/K)")
ax.set_ylabel(r"$\alpha_t$ (s$^{-1}$)")
ax.set_title("Trapping rate coefficient")
ax.legend()
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

# Panel 3: Detrapping rate alpha_r(T)
ax = axes[2]
ax.semilogy(
    1000 * inverse_temperature, ar_ref, "-", color="tab:blue", label="Reference"
)
ax.semilogy(
    1000 * inverse_temperature, ar_opt_arr, "--", color="tab:red", label="Optimized"
)
ax.set_xlabel("1000/T (1/K)")
ax.set_ylabel(r"$\alpha_r$ (s$^{-1}$)")
ax.set_title("Detrapping rate coefficient")
ax.legend()
ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
ax.minorticks_on()

plt.tight_layout()
plt.savefig("val-2j_arrhenius_comparison.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# ============================================================
# Figure 4: Reference vs optimized parameter comparison with
#           distribution of top 20% scoring evaluations
# ============================================================

import json

bayesian_json = os.path.join(
    gold_folder, "bayesian_val2j_results/val2j_bayesian_6p.json"
)
all_inputs = []
all_scores = []
if os.path.exists(bayesian_json):
    with open(bayesian_json) as f:
        bayes_data = json.load(f)
    for ts in bayes_data["time_steps"]:
        if ts["time_step"] == 0:
            continue
        inputs = ts["conditional"]["inputs"]
        outputs = ts["conditional"]["outputs_required"]
        if outputs:
            for inp, out in zip(inputs, outputs):
                all_inputs.append(inp)
                all_scores.append(out)
    all_inputs = np.array(all_inputs)
    all_scores = np.array(all_scores)

# Parameter metadata: name, reference value, optimized value, search bounds
# Column order in JSON: log10_alpha_t, epsilon_t, log10_alpha_r, epsilon_r, log10_D0, E_d
# Reorder for display: D0, E_d, alpha_t, epsilon_t, alpha_r, epsilon_r
param_info = [
    (r"log$_{10}$($D_0$) (m$^2$/s)", -6.161, np.log10(8.190614e-5), -8.0, -4.0, 4),
    (r"$E_d$ (eV)", 1.07, 0.970690, 0.8, 1.4, 5),
    (
        r"log$_{10}$($\alpha_{t0}$) (s$^{-1}$)",
        8.623,
        np.log10(1.290375e9),
        7.0,
        10.0,
        0,
    ),
    (r"$\epsilon_t$ (eV)", 1.04, 0.887460, 0.8, 1.3, 1),
    (r"log$_{10}$($\alpha_{r0}$) (s$^{-1}$)", 6.613, np.log10(2.486356e5), 5.0, 8.0, 2),
    (r"$\epsilon_r$ (eV)", 1.19, 1.100495, 0.9, 1.5, 3),
]

fig, axes = plt.subplots(2, 3, figsize=[14, 6])
axes = axes.flatten()

# Filter to top 20% scoring evaluations for plot
if len(all_scores) > 0:
    score_threshold = np.percentile(all_scores, 80)
    top_mask = all_scores >= score_threshold

for i, (label, ref_val, opt_val, lb, ub, json_col) in enumerate(param_info):
    ax = axes[i]
    ax.axvspan(lb, ub, alpha=0.10, color="gray", label="Search range")
    # Plot distribution of top 20% scoring evaluations (horizontal)
    if len(all_scores) > 0:
        from scipy.stats import gaussian_kde

        top_values = all_inputs[top_mask, json_col]
        kde = gaussian_kde(top_values)
        x_kde = np.linspace(lb, ub, 200)
        y_kde = kde(x_kde)
        ax.fill_between(x_kde, y_kde, alpha=0.2, color="tab:green")
        ax.plot(
            x_kde, y_kde, color="tab:green", linewidth=1.5, label="Top 20% evaluations"
        )
    ax.axvline(
        ref_val, color="tab:blue", linestyle="--", linewidth=2, label="Reference"
    )
    ax.axvline(opt_val, color="tab:red", linestyle="-", linewidth=2, label="Optimized")
    ax.set_xlabel(label, fontsize=11)
    ax.set_yticks([])
    ax.set_xlim(lb, ub)
    ax.set_ylim(bottom=0)
    ax.legend(fontsize=10, loc="upper right")
    ax.grid(visible=True, which="major", color="0.65", linestyle="--", alpha=0.3)
    ax.minorticks_on()

plt.tight_layout()
plt.savefig("val-2j_bayesian_parameter_exploration.png", bbox_inches="tight", dpi=300)
plt.close(fig)

# ============================================================
# Print RMSPE values
# ============================================================

print(f"Reference parameters RMSPE = {rmspe_ref:.2f}%")
print(f"Optimized parameters RMSPE = {rmspe_opt:.2f}%")
