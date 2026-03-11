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

TEMPERATURES_C = [325, 350, 375]
TEMPERATURES_K = [t + 273.15 for t in TEMPERATURES_C]
FIG_DPI = 300
ATOM_RATIO_THRESHOLD = 0.5  # threshold to select upper-branch / plateau-side data
N_SMOOTH = 400  # number of points for smoother analytical curves

# Column names (experimental CSVs)
COL_PRESSURE_BAR = "Partial Pressure"  # in bar
COL_PRESSURE_PA = "Partial Pressure (Pa)"  # converted to Pa
COL_ATOM_RATIO_WTPCT = "Atom Ratio"  # provided as wt% H in CSVs
COL_ATOM_RATIO = "Atom Ratio"  # standardized as atomic ratio H/Zr2Fe

# Column names (TMAP outputs)
COL_TMAP_T = "temperature"
COL_TMAP_P = "pressure_H2_enclosure_1_at_interface"
COL_TMAP_AF = "atomic_fraction_H_enclosure_2_at_interface"

# Molar masses for wt% → atomic ratio conversion
MOLAR_MASS_ZR2FE = 2 * 91.22 + 55.85  # 238.29 g/mol
MOLAR_MASS_H = 1.008  # g/mol

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------
if "/tmap8/doc/" in script_folder.lower():
    root = "../../../../../test/tests/Zr2Fe_hydrogen_system/"
else:
    root = ""

exp_data_dir = os.path.join(root, "PCT_data")
gold_dir = os.path.join(root, "gold")


# ------------------------------------------------------------------------------
# Models
# ------------------------------------------------------------------------------
def p0_lim_func(T):
    """
    Pressure-limiter function p0(T) for Zr2FeHx.
    T in Kelvin, returns Pa.
    """
    T = np.array(T)
    return np.exp(-4.12 + 1.03e-2 * T)


def atom_ratio_eq_upper_func(T, P):
    """
    High-pressure isotherm model: equilibrium atomic ratio for given T and P.
    T in Kelvin, P in Pa. Returns atomic ratio (H/Zr2Fe).
    """
    T = np.array(T)
    P = np.array(P)
    p0 = p0_lim_func(T)
    safe_log_arg = np.maximum(P - p0, 1e-10)
    exponent = 5.41 - 1.36e-2 * T + (2.32e-01 + 1.51e-4 * T) * np.log(safe_log_arg)
    return 4.30 - 1.81 / (0.5 + np.exp(exponent))


def rmse(y_true, y_pred):
    return np.sqrt(np.mean((np.array(y_true) - np.array(y_pred)) ** 2))


# ------------------------------------------------------------------------------
# Helper conversions (fixed behavior)
# ------------------------------------------------------------------------------
def pressure_bar_to_pa(series):
    """Convert pressure from bar to Pa."""
    return series.values * 1e5


def atom_ratio_wtpct_to_atomic(series):
    """Convert Atom Ratio from wt% H to atomic ratio H/Zr2Fe."""
    wt_H = series.values
    return (wt_H / MOLAR_MASS_H) / ((100.0 - wt_H) / MOLAR_MASS_ZR2FE)


# ------------------------------------------------------------------------------
# Load experimental data
# ------------------------------------------------------------------------------
data_by_temp = {}
for Tc, Tk in zip(TEMPERATURES_C, TEMPERATURES_K):
    f = os.path.join(exp_data_dir, f"{int(Tc)}.csv")
    if not os.path.exists(f):
        print(f"File not found: {f}")
        continue

    df = pd.read_csv(f)

    # Validate columns
    if (COL_PRESSURE_BAR not in df.columns) or (COL_ATOM_RATIO_WTPCT not in df.columns):
        print(f"Missing required columns in {f}")
        continue

    # Convert units/values (bar→Pa, wt%→atomic ratio)
    AR = atom_ratio_wtpct_to_atomic(df[COL_ATOM_RATIO_WTPCT])
    P = pressure_bar_to_pa(df[COL_PRESSURE_BAR])

    df_out = pd.DataFrame({COL_PRESSURE_PA: P, COL_ATOM_RATIO: AR})
    df_out = (
        df_out[[COL_PRESSURE_PA, COL_ATOM_RATIO]].dropna().sort_values(COL_PRESSURE_PA)
    )
    data_by_temp[Tk] = df_out.reset_index(drop=True)

# ------------------------------------------------------------------------------
# Raw plot (Atomic Ratio vs Pressure) for each temperature
# ------------------------------------------------------------------------------
fig = plt.figure(figsize=(10, 6))
for Tk in TEMPERATURES_K:
    df = data_by_temp.get(Tk)
    if df is None:
        continue

    plt.scatter(df[COL_ATOM_RATIO], df[COL_PRESSURE_PA], s=28, label=f"{Tk:.2f} K")
    plt.plot(df[COL_ATOM_RATIO], df[COL_PRESSURE_PA])

plt.yscale("log")
plt.xlabel("Atomic Ratio H/Zr₂Fe (-)")
plt.ylabel("Partial Pressure (Pa)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("Zr2FeHx_PCT_Data.png", dpi=FIG_DPI)
plt.close(fig)

# ------------------------------------------------------------------------------
# Plateau / limiter fit (p0 vs T) from selected experimental points
# ------------------------------------------------------------------------------
p0_vals = p0_lim_func(np.array(TEMPERATURES_K))

sel_T, sel_P = [], []
for Tk in TEMPERATURES_K:
    df = data_by_temp.get(Tk)
    if df is None:
        continue

    AR = df[COL_ATOM_RATIO].values
    P = df[COL_PRESSURE_PA].values
    idx = np.where(AR > ATOM_RATIO_THRESHOLD)[0]
    if idx.size:
        sel_T.append(Tk)
        sel_P.append(P[idx[0]])

fig = plt.figure(figsize=(5, 5))
plt.plot(TEMPERATURES_K, p0_vals, "--", label="Fit")
if sel_T:
    plt.scatter(sel_T, sel_P, color="red", label="Selected Pressures")

plt.yscale("log")
plt.xlabel("Temperature (K)")
plt.ylabel("Pressure (Pa)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("Zr2FeHx_PCT_pressure_limiter_fit.png", dpi=FIG_DPI)
plt.close(fig)

# ------------------------------------------------------------------------------
# Load TMAP8 predictions
# ------------------------------------------------------------------------------
tmap_files = {
    "Zr2FeHx_PCT_T598_P1e03_out.csv",
    "Zr2FeHx_PCT_T623_P1e04_out.csv",
    "Zr2FeHx_PCT_T648_P1e02_out.csv",
    "Zr2FeHx_PCT_T648_P1e05_out.csv",
}

tmap_data = {}
for f in tmap_files:
    path = os.path.join(gold_dir, f)
    if os.path.exists(path):
        tmap_data[f] = pd.read_csv(path)
    else:
        print(f"TMAP file not found: {path}")

# ------------------------------------------------------------------------------
# Combined figure: experimental  + TMAP8 overlay
# ------------------------------------------------------------------------------
fig = plt.figure(figsize=(12, 8))

rmse_by_temp = {}
for Tk in TEMPERATURES_K:
    df = data_by_temp.get(Tk)
    if df is None:
        continue

    P = df[COL_PRESSURE_PA].values
    AR = df[COL_ATOM_RATIO].values

    # Select upper branch (above threshold)
    idx_hi = AR > ATOM_RATIO_THRESHOLD
    if np.any(idx_hi):
        P_hi = P[idx_hi]
        AR_hi = AR[idx_hi]
        fit_hi = atom_ratio_eq_upper_func(Tk, P_hi)

        valid = np.isfinite(fit_hi)
        P_hi, AR_hi, fit_hi = P_hi[valid], AR_hi[valid], fit_hi[valid]

        if len(fit_hi) > 0:
            # Plot experimental upper-branch points
            plt.scatter(P_hi, AR_hi, label=f"{Tk:.2f} K Data")
            # Compute RMSE on original points (unchanged)
            r = rmse(AR_hi, fit_hi)
            rmse_by_temp[Tk] = float(r)

            # ---- Smooth analytical curve: densify pressure grid (ONLY CHANGE) ----
            P_min = np.min(P_hi)
            P_max = np.max(P_hi)
            p0_T = float(p0_lim_func(Tk))
            # Start slightly above p0 to keep log argument positive
            P_start = max(P_min, p0_T * 1.001)
            # Use configured number of points for smooth curve
            P_grid = np.logspace(np.log10(P_start), np.log10(P_max), N_SMOOTH)
            fit_grid = atom_ratio_eq_upper_func(Tk, P_grid)

            # Plot smooth analytical/model curve with the same RMSE label
            plt.plot(P_grid, fit_grid, "-", label=f"{Tk:.2f} K Fit RMSE {r:.3f}")


# TMAP8 overlays with markers; compute error only for upper branch (P >= p0)
def overlay_tmap(dfp):
    T_pred = float(dfp[COL_TMAP_T].iat[-1])
    P_pred = float(dfp[COL_TMAP_P].iat[-1])
    AF_pred = float(dfp[COL_TMAP_AF].iat[-1])
    p0 = float(p0_lim_func(T_pred))

    if P_pred >= p0:
        AF_model = float(atom_ratio_eq_upper_func(T_pred, np.array([P_pred]))[0])
        err_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan
        marker_style = "x"  # high-pressure branch
        label = f"{int(T_pred)} K, {P_pred:.2e} Pa (err {err_pct:.2f}%)"
    else:
        marker_style = "*"  # low-pressure; upper model not applicable
        label = f"{int(T_pred)} K, {P_pred:.2e} Pa (low-branch)"

    plt.scatter(P_pred, AF_pred, marker=marker_style, color="k", s=90, label=label)


for dfp in tmap_data.values():
    overlay_tmap(dfp)

plt.xscale("log")
plt.xlabel("Partial Pressure (Pa)")
plt.ylabel("Atomic Ratio H/Zr₂Fe (-)")
plt.grid(True)
plt.legend(bbox_to_anchor=(1.18, 1.02))
plt.tight_layout()
plt.savefig("Zr2FeHx_PCT_fit_2D.png", dpi=FIG_DPI)
plt.close(fig)

# ------------------------------------------------------------------------------
# RMSE summary across temperatures
# ------------------------------------------------------------------------------
if rmse_by_temp:
    avg_rmse = float(np.mean(list(rmse_by_temp.values())))
    print(
        "Temperatures (K) and RMSE values:",
        {f"{Tk:.2f} K": v for Tk, v in rmse_by_temp.items()},
    )
    print(f"Average RMSE: {avg_rmse:.3f}")
else:
    print("No valid RMSE computed (check data and thresholds).")
