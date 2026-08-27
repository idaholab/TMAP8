#!/usr/bin/env python3
"""Generate figures for val-2l from compact gold CSV files."""

from pathlib import Path
import csv
import math

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

EXP_CONV = 1.0 / 2.24e4 * 6.022e23 * 2 / 60 * 1e4
R = 8.31446261815324
N_A = 6.02214076e23


def _paths():
    script_dir = Path(__file__).resolve().parent
    if (script_dir / "gold").is_dir():
        return script_dir / "gold", script_dir
    repo_root = script_dir.parents[3]
    return repo_root / "test/tests/val-2l/gold", script_dir


GOLD_DIR, OUTPUT_DIR = _paths()


def read_csv(path):
    with path.open(newline="") as stream:
        return list(csv.DictReader(stream))


def load_experiment(temp_label):
    vi = read_csv(GOLD_DIR / f"Lee2005_{temp_label}_VI.csv")
    fi = read_csv(GOLD_DIR / f"Lee2005_{temp_label}_FI.csv")
    return [
        (float(v["Voltage(V)"]), float(f["Flux(cm^3/min/cm^2)"]) * EXP_CONV)
        for v, f in zip(vi, fi)
    ]


def load_summary(filename, temp_key="temperature_K"):
    rows = []
    for row in read_csv(GOLD_DIR / filename):
        rows.append(
            {
                "temperature": float(row[temp_key]),
                "voltage": float(row["voltage_V"]),
                "flux": float(row["flux_atoms_m2_s"]),
                **row,
            }
        )
    return rows


def rmspe(sim_rows, exp_rows, temperature):
    refs = exp_rows[::2]
    vals = []
    for voltage, ref_flux in refs:
        candidates = [
            row for row in sim_rows
            if abs(row["temperature"] - temperature) < 2.0 and abs(row["voltage"] - voltage) < 0.03
        ]
        if candidates:
            vals.append((candidates[0]["flux"], ref_flux))
    if not vals:
        return float("nan")
    mean_ref = sum(ref for _, ref in vals) / len(vals)
    return math.sqrt(sum((sim - ref) ** 2 for sim, ref in vals) / len(vals)) / mean_ref * 100.0


def split_by_temp(rows, temp):
    return sorted([row for row in rows if abs(row["temperature"] - temp) < 2.0], key=lambda row: row["voltage"])


def plot_flux(summary_name, output_name, title, overlay=None, temp_key="temperature_K"):
    rows = load_summary(summary_name, temp_key=temp_key)
    exp_773 = load_experiment("500C")
    exp_973 = load_experiment("700C")
    fig, ax = plt.subplots(figsize=(6.5, 5.0))

    for temp, color, label, exp_rows in [
        (973.0, "C1", "973 K", exp_973),
        (773.0, "C0", "773 K", exp_773),
    ]:
        sim = split_by_temp(rows, temp)
        ax.plot([r["voltage"] for r in sim], [r["flux"] for r in sim], ".-", color=color, label=f"TMAP8 {label}")
        ax.plot([v for v, _ in exp_rows], [f for _, f in exp_rows], "s", color=color, fillstyle="none", label=f"Lee et al. {label}")
        err = rmspe(rows, exp_rows, temp)
        xpos = 0.58 if temp == 973.0 else 0.08
        ypos = 0.88 if temp == 973.0 else 0.78
        if math.isfinite(err):
            ax.text(xpos, ypos, f"RMSPE {label}: {err:.2f}%", color=color, transform=ax.transAxes)

    if overlay:
        over_rows = load_summary(overlay["summary"])
        sim = split_by_temp(over_rows, overlay["temperature"])
        ax.plot([r["voltage"] for r in sim], [r["flux"] for r in sim], "--", color=overlay.get("color", "C0"), label=overlay["label"])

    ax.set_xlabel("Voltage (V)")
    ax.set_ylabel(r"Hydrogen flux (atoms m$^{-2}$ s$^{-1}$)")
    ax.set_title(title)
    ax.grid(True, linestyle="--", color="0.75", alpha=0.5)
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / output_name, dpi=300)
    plt.close(fig)


def plot_temperature():
    rows = load_summary("val-2l_joule_summary.csv", temp_key="temperature_nominal_K")
    fig, ax = plt.subplots(figsize=(6.5, 5.0))
    for temp, color, label in [(773.0, "C0", "773 K"), (973.0, "C1", "973 K")]:
        sim = split_by_temp(rows, temp)
        ax.plot([r["voltage"] for r in sim], [float(r["delta_T_K"]) for r in sim], ".-", color=color, label=f"Delta T {label}")
        ax.plot([r["voltage"] for r in sim], [float(r["temperature_max_K"]) - temp for r in sim], "--", color=color, label=f"Peak rise {label}")
    ax.set_xlabel("Voltage (V)")
    ax.set_ylabel("Temperature rise (K)")
    ax.set_title("Joule-heating temperature response")
    ax.grid(True, linestyle="--", color="0.75", alpha=0.5)
    ax.legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "val-2l_joule_temperature.png", dpi=300)
    plt.close(fig)


def plot_bayesian_history():
    rows = read_csv(GOLD_DIR / "val-2l_bayesian_history.csv")
    if not rows:
        return
    fig, ax = plt.subplots(figsize=(6.5, 4.5))
    iteration = [int(r["iteration"]) for r in rows]
    best = [float(r["best_objective"]) for r in rows]
    step = [float(r["best_step_objective"]) for r in rows]
    ax.plot(iteration, step, ".", color="C2", label="step best")
    ax.plot(iteration, best, "-", color="C0", label="best so far")
    ax.set_xlabel("Bayesian optimization iteration")
    ax.set_ylabel("Objective, log inverse RMSPE")
    ax.grid(True, linestyle="--", color="0.75", alpha=0.5)
    ax.legend()
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "val-2l_bayesian_optimization.png", dpi=300)
    plt.close(fig)


def _params(which):
    data = {r["parameter"]: float(r[which]) for r in read_csv(GOLD_DIR / "val-2l_parameter_sets.csv")}
    return data


def d_ot(params, temp):
    return 2.03 * 10 ** params["diffusivity_OT_prefactor_exponent"] * math.exp(-params["diffusivity_OT_energy"] / R / temp)


def d_vo(params, temp):
    return 1.1 * 10 ** params["diffusivity_V_O_prefactor_exponent"] * math.exp(-params["diffusivity_V_O_energy"] / R / temp)


def k_eq(params, temp, species):
    if species == "H2":
        dh, ds = params["delta_H_T2"], params["delta_S_T2"]
    else:
        dh, ds = params["delta_H_T2O"], params["delta_S_T2O"]
    return math.exp((dh - temp * ds) / R / temp)


def k_forward(params, temp, species):
    if species == "H2":
        exponent = params["T2_reaction_forward_mol_exponent"]
        energy = params["T2_reaction_forward_energy"]
    else:
        exponent = params["T2O_reaction_forward_mol_exponent"]
        energy = params["T2O_reaction_forward_energy"]
    return 8.0 * 10 ** exponent / N_A * math.exp(-energy / R / temp)


def plot_parameters():
    initial = _params("initial")
    optimized = _params("optimized")
    temps = [700.0 + i * 10.0 for i in range(41)]
    xvals = [1000.0 / t for t in temps]
    panels = [
        ("OH diffusivity", lambda p, t: d_ot(p, t), r"m$^2$/s"),
        ("O vacancy diffusivity", lambda p, t: d_vo(p, t), r"m$^2$/s"),
        ("H2 equilibrium", lambda p, t: k_eq(p, t, "H2"), "-"),
        ("H2O equilibrium", lambda p, t: k_eq(p, t, "H2O"), "-"),
        ("H2 forward rate", lambda p, t: k_forward(p, t, "H2"), r"m$^4$/atom/s"),
        ("H2O forward rate", lambda p, t: k_forward(p, t, "H2O"), r"m$^4$/atom/s"),
    ]
    fig, axes = plt.subplots(2, 3, figsize=(10.5, 6.4))
    for ax, (title, func, units) in zip([a for row in axes for a in row], panels):
        ax.plot(xvals, [func(initial, t) for t in temps], color="C0", label="initial")
        ax.plot(xvals, [func(optimized, t) for t in temps], color="C1", label="optimized")
        ax.set_yscale("log")
        ax.invert_xaxis()
        ax.set_title(title, fontsize=10)
        ax.set_xlabel(r"1000/T (K$^{-1}$)")
        ax.set_ylabel(units)
        ax.grid(True, linestyle="--", color="0.8", alpha=0.5)
    axes[0][0].legend(fontsize=8)
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "val-2l_parameter_comparison.png", dpi=300)
    plt.close(fig)


def main():
    plot_flux("val-2l_initial_summary.csv", "val-2l_initial_flux.png", "Initial parameter set")
    plot_flux("val-2l_optimized_summary.csv", "val-2l_optimized_flux.png", "Bayesian-optimized parameter set")
    plot_flux(
        "val-2l_joule_summary.csv",
        "val-2l_joule_flux.png",
        "Optimized parameter set with Joule heating",
        overlay={"summary": "val-2l_optimized_summary.csv", "temperature": 773.0, "label": "No Joule heat, 773 K", "color": "C0"},
        temp_key="temperature_nominal_K",
    )
    plot_temperature()
    plot_bayesian_history()
    plot_parameters()


if __name__ == "__main__":
    main()
