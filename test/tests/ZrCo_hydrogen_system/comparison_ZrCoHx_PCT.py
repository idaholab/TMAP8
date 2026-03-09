# Import Required Libraries
# Import the necessary libraries, including pandas.
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------
# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_folder)

TEMPERATURES_K = [433, 573, 604]  # K
ATOM_RATIO_LOW = 0.55
ATOM_RATIO_HIGH = 1.4
FIG_DPI = 300
N_SMOOTH = 400  # number of points for smoother analytical curves

COL_PRESSURE_EXP_LOG = "Partial Pressure"  # log10(Pa)
COL_PRESSURE_PA = "Partial Pressure (Pa)"
COL_ATOM_RATIO = "Atom Ratio"
COL_TMAP_T = "temperature"
COL_TMAP_P = "pressure_H2_enclosure_1_at_interface"
COL_TMAP_AF = "atomic_fraction_H_enclosure_2_at_interface"

# ============================================================================ #
# Paths
if "/tmap8/doc/" in script_folder.lower():
    root = "../../../../../test/tests/ZrCo_hydrogen_system/"
else:
    root = ""

folderPath = root
folderNameExpData = "PCT_data"
folderNameGold = "gold"

exp_data_dir = os.path.join(folderPath, folderNameExpData)
gold_dir = os.path.join(folderPath, folderNameGold)


# ------------------------------------------------------------------------------
# Models
# ------------------------------------------------------------------------------


def p0_lim_func(T):
    return np.exp(12.43 - 4.84e-2 * T + 7.15e-5 * T**2)


def atom_ratio_eq_lower_func(T, P):
    p0 = p0_lim_func(T)
    arg = np.maximum(p0 - P, 1e-10)
    return 0.5 - (
        0.001 + np.exp(-4.29 + 1.98e-02 * T + (-1.07 + 5.69e-04 * T) * np.log(arg))
    ) ** (-1)


def atom_ratio_eq_upper_func(T, P):
    p0 = p0_lim_func(T)
    arg = np.maximum(P - p0, 1e-10)
    return 2.5 - 3.42 * (
        1.4 + np.exp(7.97 - 1.99e-02 * T + (-1.69e-01 + 1.19e-03 * T) * np.log(arg))
    ) ** (-1)


def rmse(y_true, y_pred):
    return np.sqrt(np.mean((y_true - y_pred) ** 2))


# ------------------------------------------------------------------------------
# Load experimental data
# ------------------------------------------------------------------------------
data_by_temp = {}
for T in TEMPERATURES_K:
    f = os.path.join(exp_data_dir, f"{T}.csv")
    df = pd.read_csv(f)
    df[COL_PRESSURE_PA] = 10 ** df[COL_PRESSURE_EXP_LOG]
    df = df[[COL_PRESSURE_PA, COL_ATOM_RATIO]].dropna().sort_values(COL_PRESSURE_PA)
    data_by_temp[T] = df.reset_index(drop=True)

# ------------------------------------------------------------------------------
# Raw plot
# ------------------------------------------------------------------------------
fig = plt.figure(figsize=(10, 6))
for T in TEMPERATURES_K:
    df = data_by_temp.get(T)
    if df is None:
        continue
    plt.scatter(df[COL_ATOM_RATIO], df[COL_PRESSURE_PA], s=28, label=f"{T}.15 K")
    plt.plot(df[COL_ATOM_RATIO], df[COL_PRESSURE_PA])
plt.yscale("log")
plt.xlabel("Atom Ratio (-)")
plt.ylabel("Partial Pressure (Pa)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("ZrCoHx_PCT_Data.png", dpi=FIG_DPI)
plt.close(fig)

# ------------------------------------------------------------------------------
# Plateau fit
# ------------------------------------------------------------------------------
p0_vals = p0_lim_func(np.array(TEMPERATURES_K))
sel_T, sel_P = [], []
for T in TEMPERATURES_K:
    df = data_by_temp.get(T)
    if df is None:
        continue
    AR, P = df[COL_ATOM_RATIO].values, df[COL_PRESSURE_PA].values
    idx = np.where(AR > ATOM_RATIO_LOW)[0]
    if idx.size:
        sel_T.append(T)
        sel_P.append(P[idx[0]])
fig = plt.figure(figsize=(5, 5))
plt.plot(TEMPERATURES_K, p0_vals, "--", label="Fit")
if sel_T:
    plt.scatter(sel_T, sel_P, color="red", label="Plateau Pressures")
plt.yscale("log")
plt.xlabel("Temperature (K)")
plt.ylabel("Pressure (Pa)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("ZrCoHx_PCT_plateau_pressure_fit.png", dpi=FIG_DPI)
plt.close(fig)

# ------------------------------------------------------------------------------
# Load TMAP8 predictions
# ------------------------------------------------------------------------------
low_files = {
    "ZrCoHx_PCT_T433_1E2P_out.csv",
    "ZrCoHx_PCT_T573_1E3P_out.csv",
    "ZrCoHx_PCT_T604_6E3P_out.csv",
    "ZrCoHx_PCT_T604_1E4P_out.csv",
}
high_files = {
    "ZrCoHx_PCT_T433_1E4P_out.csv",
    "ZrCoHx_PCT_T433_3E4P_out.csv",
    "ZrCoHx_PCT_T573_1E4P_out.csv",
    "ZrCoHx_PCT_T604_5E4P_out.csv",
}

tmap_low = {}
for f in low_files:
    path = os.path.join(gold_dir, f)
    if os.path.exists(path):
        tmap_low[f] = pd.read_csv(path)

tmap_high = {}
for f in high_files:
    path = os.path.join(gold_dir, f)
    if os.path.exists(path):
        tmap_high[f] = pd.read_csv(path)

# ------------------------------------------------------------------------------
# Consistent colors by temperature for both low & high branches
# ------------------------------------------------------------------------------
TEMP_COLOR_MAP = {
    433: "#1f77b4",  # blue
    573: "#ff7f0e",  # orange
    604: "#2ca02c",  # green
}

# ------------------------------------------------------------------------------
# Combined figure: low + high + TMAP8 overlay
# ------------------------------------------------------------------------------
fig = plt.figure(figsize=(12, 8))

# Experimental data and fits
for T in TEMPERATURES_K:
    df = data_by_temp.get(T)
    if df is None:
        continue
    P, AR = df[COL_PRESSURE_PA].values, df[COL_ATOM_RATIO].values
    color_T = TEMP_COLOR_MAP.get(int(T), None)

    # Low branch
    idx_low = AR < ATOM_RATIO_LOW
    if np.any(idx_low):
        P_lo, AR_lo = P[idx_low], AR[idx_low]
        fit_lo = atom_ratio_eq_lower_func(T, P_lo)
        # scatter (data)
        plt.scatter(P_lo, AR_lo, label=f"{T}.15 K Data", color=color_T)
        # smooth analytical curve over the observed low-pressure range (log-spaced)
        P_lo_min = float(np.nanmax([np.min(P_lo), 1e-12]))  # guard for positivity
        P_lo_max = float(np.max(P_lo))
        if P_lo_max > P_lo_min:
            P_lo_smooth = np.geomspace(P_lo_min, P_lo_max, N_SMOOTH)
            fit_lo_smooth = atom_ratio_eq_lower_func(T, P_lo_smooth)
            plt.plot(
                P_lo_smooth,
                fit_lo_smooth,
                "--",
                label=f"{T}.15 K Fit RMSE {rmse(AR_lo, fit_lo):.3f}",
                color=color_T,
            )
        else:
            # fallback to original points if range collapses
            plt.plot(
                P_lo,
                fit_lo,
                "--",
                label=f"{T}.15 K Fit RMSE {rmse(AR_lo, fit_lo):.3f}",
                color=color_T,
            )

    # High branch
    idx_hi = AR > ATOM_RATIO_HIGH
    if np.any(idx_hi):
        P_hi, AR_hi = P[idx_hi], AR[idx_hi]
        fit_hi = atom_ratio_eq_upper_func(T, P_hi)
        valid = np.isfinite(fit_hi)
        P_hi, AR_hi, fit_hi = P_hi[valid], AR_hi[valid], fit_hi[valid]
        if len(fit_hi) > 0:
            # scatter (data)
            plt.scatter(P_hi, AR_hi, label=f"{T}.15 K Data", color=color_T)
            # smooth analytical curve over the observed high-pressure range (log-spaced)
            P_hi_min = float(np.nanmax([np.min(P_hi), 1e-12]))
            P_hi_max = float(np.max(P_hi))
            if P_hi_max > P_hi_min:
                P_hi_smooth = np.geomspace(P_hi_min, P_hi_max, N_SMOOTH)
                fit_hi_smooth = atom_ratio_eq_upper_func(T, P_hi_smooth)
                plt.plot(
                    P_hi_smooth,
                    fit_hi_smooth,
                    "-",
                    label=f"{T}.15 K Fit RMSE {rmse(AR_hi, fit_hi):.3f}",
                    color=color_T,
                )
            else:
                # fallback to original points if range collapses
                plt.plot(
                    P_hi,
                    fit_hi,
                    "-",
                    label=f"{T}.15 K Fit RMSE {rmse(AR_hi, fit_hi):.3f}",
                    color=color_T,
                )


# TMAP8 overlays with different markers
def overlay_tmap(dfp):
    T_pred = dfp[COL_TMAP_T].iat[-1]
    P_pred = dfp[COL_TMAP_P].iat[-1]
    AF_pred = dfp[COL_TMAP_AF].iat[-1]
    p0 = p0_lim_func(T_pred)
    if P_pred < p0:
        AF_model = atom_ratio_eq_lower_func(T_pred, np.array([P_pred]))[0]
        marker_style = "*"  # star for low-pressure
    else:
        AF_model = atom_ratio_eq_upper_func(T_pred, np.array([P_pred]))[0]
        marker_style = "x"  # X for high-pressure
    err_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan
    plt.scatter(
        P_pred,
        AF_pred,
        marker=marker_style,
        color="k",
        s=90,
        label=f"{int(T_pred)}.15 K, {P_pred:.2e} Pa (err {err_pct:.2f}%)",
    )


# Apply overlays
for dfp in tmap_low.values():
    overlay_tmap(dfp)
for dfp in tmap_high.values():
    overlay_tmap(dfp)

plt.xscale("log")
plt.xlabel("Partial Pressure (Pa)")
plt.ylabel("Atom Ratio (-)")
plt.grid(True)
plt.legend(bbox_to_anchor=(1.18, 1.02))
plt.tight_layout()
plt.savefig("ZrCoHx_PCT_fit_2D.png", dpi=FIG_DPI)
plt.close(fig)
