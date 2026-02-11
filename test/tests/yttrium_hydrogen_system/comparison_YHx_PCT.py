

from __future__ import annotations

import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)
# -------------------------------------------------------------------------------------
# Configuration & Constants
# ----------------------------------------------------------------------------------------

MMHG_TO_PA = 133.322  # 1 mmHg = 133.322 Pa
C_TO_K = 273.15       # Celsius to Kelvin

TEMPERATURES_C = [900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300,1350]
TEMPERATURES_K = np.array([t + C_TO_K for t in TEMPERATURES_C])

ATOM_RATIO_THRESHOLD = 0.5  # for low-pressure selection
PLATEAU_DERIVATIVE_THRESHOLD = 1.0  # threshold for plateau detection
FIG_DPI = 300

# Column names expected in experimental CSV
COL_PRESSURE_MMHG = "Partial Pressure (mm Hg)"
COL_PRESSURE_PA = "Partial Pressure (Pa)"
COL_ATOM_RATIO = "Atom Ratio (-)"
COL_TEMPERATURE_K = "Temperature (K)"

# Column names expected in TMAP8 CSVs
COL_TMAP_T = "temperature"
COL_TMAP_P = "pressure_H2_enclosure_1_at_interface"
COL_TMAP_AF = "atomic_fraction_H_enclosure_2_at_interface"

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s"
)
logger = logging.getLogger(__name__)

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------

def script_folder() -> Path:
    """Return the directory of this script, with a fallback to current working dir."""
    try:
        return Path(__file__).resolve().parent
    except NameError:
        return Path.cwd()

def resolve_data_folders(base_folder: Path) -> Tuple[Path, Path]:
    """
    Determine experimental data folder and TMAP8 gold folder depending
    on path context. Keeps consistency with your original intent, but
    uses yttrium_hydrogen_system consistently (fixing a small mismatch).
    """
    base_str = str(base_folder).lower()

    # Experimental PCT data
    if "/tmap8/doc/" in base_str:
        exp_base = base_folder / "../../../../../test/tests/yttrium_hydrogen_system"
    else:
        exp_base = base_folder  # current folder

    exp_data_folder = (exp_base / "PCT_data").resolve()

    # TMAP8 gold outputs
    if "/tmap8/doc/" in base_str:
        gold_folder = (base_folder / "../../../../../test/tests/yttrium_hydrogen_system/gold").resolve()
    else:
        gold_folder = (base_folder / "gold").resolve()

    return exp_data_folder, gold_folder

# ------------------------------------------------------------------------------
# Math Models
# ------------------------------------------------------------------------------

def p0_lim_func(temperature: np.ndarray | float) -> np.ndarray | float:
    """
    Plateau pressure function p0_lim(T).
    """
    T = np.array(temperature, dtype=float)
    return np.exp(-26.1 + 3.88e-2 * T - 9.7e-6 * np.square(T))

def atom_ratio_eq_lower_func(temperature: float, pressure: np.ndarray) -> np.ndarray:
    """
    Lower-pressure branch: atom ratio as a function of (T, P).
    Domain guard: requires p0_lim(T) - P > 0 for log().
    """
    T = float(temperature)
    p0 = p0_lim_func(T)
    arg = (p0 - pressure)
    with np.errstate(divide='ignore', invalid='ignore'):
        val = 0.5 - (1.0e-3 + np.exp(
            -89.737 + 9.7537e-2 * T + (1.1924 - 4.4125e-3 * T) * np.log(arg)
        )) ** (-1)
    return val

def atom_ratio_eq_upper_func(temperature: float, pressure: np.ndarray) -> np.ndarray:
    """
    Upper-pressure branch: atom ratio as a function of (T, P).
    Domain guard: requires pressure - p0_lim(T) > 0 for log().
    """
    T = float(temperature)
    p0 = p0_lim_func(T)
    arg = (pressure - p0)
    with np.errstate(divide='ignore', invalid='ignore'):
        val = 2.0 - (1.0 + np.exp(
            21.6 - 0.0225 * T + (-0.0445 + 7.18e-4 * T) * np.log(arg)
        )) ** (-1)
    return val

# ------------------------------------------------------------------------------
# Data Loading & Utilities
# ------------------------------------------------------------------------------

def load_pct_data(exp_data_folder: Path, temperatures_k: np.ndarray) -> Dict[float, pd.DataFrame]:
    """
    Load and preprocess experimental PCT data for each temperature.
    Returns a dict keyed by temperature (K).
    """
    data_by_temp: Dict[float, pd.DataFrame] = {}

    for temp_K in temperatures_k:
        temp_C = int(temp_K - C_TO_K)
        file_path = exp_data_folder / f"{temp_C}.csv"

        if not file_path.exists():
            logger.warning(f"Missing experimental CSV for {temp_C}°C: {file_path}")
            continue

        try:
            df = pd.read_csv(file_path)
            if COL_PRESSURE_MMHG not in df.columns or COL_ATOM_RATIO not in df.columns:
                raise ValueError(f"CSV missing required columns: '{COL_PRESSURE_MMHG}', '{COL_ATOM_RATIO}'")

            df[COL_PRESSURE_PA] = df[COL_PRESSURE_MMHG] * MMHG_TO_PA
            df.drop(columns=[COL_PRESSURE_MMHG], inplace=True)
            df[COL_TEMPERATURE_K] = temp_K

            # Sort by atom ratio for monotonicity across plots/derivatives
            df.sort_values(by=COL_ATOM_RATIO, inplace=True)
            df.reset_index(drop=True, inplace=True)

            data_by_temp[temp_K] = df

        except Exception as e:
            logger.error(f"Error processing file {file_path}: {e}")

    return data_by_temp

def calculate_derivative(exp_df: pd.DataFrame) -> np.ndarray:
    """
    Compute d(Atom Ratio)/d(Pressure) using numpy gradient.
    Independent variable (x) = pressure (Pa), dependent (y) = atom ratio.
    """
    x = exp_df[COL_PRESSURE_PA].to_numpy()
    y = exp_df[COL_ATOM_RATIO].to_numpy()

    # Use log-scale spacing awareness if needed; here regular gradient with x spacing
    dy_dx = np.gradient(y, x)
    return dy_dx

def detect_plateau_indices(exp_df: pd.DataFrame, threshold: float = PLATEAU_DERIVATIVE_THRESHOLD) -> Tuple[Optional[int], Optional[int]]:
    """
    Identify plateau region based on normalized derivative |dy/dx| / y < threshold.
    Returns (start_index, end_index) or (None, None).
    """
    y = exp_df[COL_ATOM_RATIO].to_numpy()
    dy_dx = calculate_derivative(exp_df)

    # Normalize derivative by y to detect flat regions relative to magnitude
    with np.errstate(divide='ignore', invalid='ignore'):
        norm = np.abs(dy_dx) / np.where(y != 0, y, np.nan)

    edges = np.where(norm < threshold)[0]
    if len(edges) == 0:
        return None, None
    return int(edges[0]), int(edges[-1])

def rmse(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """
    Root Mean Squared Error.
    """
    return float(np.sqrt(np.mean((y_true - y_pred) ** 2)))

# ------------------------------------------------------------------------------
# Plotting Helpers
# ------------------------------------------------------------------------------

def save_fig(fig: plt.Figure, filename: str) -> None:
    fig.tight_layout()
    fig.savefig(filename, bbox_inches='tight', dpi=FIG_DPI)
    plt.close(fig)
    logger.info(f"Saved figure: {filename}")

# ------------------------------------------------------------------------------
# Main Analysis Steps
# ------------------------------------------------------------------------------

def plot_plateau_fit_vs_selected_pressure(temperatures_k: np.ndarray, data_by_temp: Dict[float, pd.DataFrame]) -> None:
    """
    Plot p0_lim(T) vs temperature and overlay first pressure where atom ratio > threshold.
    """
    p0_vals = p0_lim_func(temperatures_k)

    # Extract filtered pressures where atom ratio exceeds threshold
    selected_temps: List[float] = []
    selected_pressures: List[float] = []

    for T in temperatures_k:
        df = data_by_temp.get(T)
        if df is None:
            continue

        atom_ratio = df[COL_ATOM_RATIO].to_numpy()
        pressure = df[COL_PRESSURE_PA].to_numpy()

        idx = np.where(atom_ratio > 0.65)[0]
        if len(idx) > 0:
            selected_temps.append(T)
            selected_pressures.append(float(pressure[idx[0]]))
        else:
            logger.info(f"No atom ratio > {ATOM_RATIO_THRESHOLD} found for {T:.0f} K")

    # Plot
    fig = plt.figure(figsize=(5, 5))
    plt.plot(temperatures_k, p0_vals, label='Fit', linestyle='--')
    if selected_temps:
        plt.scatter(selected_temps, selected_pressures, color='red', label='Plateau Pressures')

    plt.xlabel('Temperature (K)')
    plt.ylabel('Pressure (Pa)')
    plt.yscale('log')
    plt.legend()
    plt.grid(True)

    save_fig(fig, 'YHx_PCT_plateau_pressure_fit.png')

def plot_low_pressure_fit(temperatures_k: np.ndarray, data_by_temp: Dict[float, pd.DataFrame], gold_folder: Path) -> None:
    """
    Fit and plot low-pressure branch against experimental & TMAP8 predictions.
    """
    # Read TMAP8 predictions
    predictions_files = {
        "YHx_PCT_T1573_P5e3_out.csv",
        "YHx_PCT_T1473_P3e3_out.csv",
        "YHx_PCT_T1273_P3e2_out.csv",
        "YHx_PCT_T1573_P6e2_out.csv",
    }
    tmap_dfs: Dict[str, pd.DataFrame] = {}

    for fname in predictions_files:
        fpath = gold_folder / fname
        if fpath.exists():
            tmap_dfs[fname] = pd.read_csv(fpath)
        else:
            logger.warning(f"Missing TMAP8 CSV: {fpath}")

    # Plot
    fig = plt.figure(figsize=(12, 8))
    rmse_values: Dict[float, float] = {}

    for T in temperatures_k:
        df = data_by_temp.get(T)
        if df is None:
            continue

        pressures = df[COL_PRESSURE_PA].to_numpy()
        atom_ratios = df[COL_ATOM_RATIO].to_numpy()

        # Focus on lower branch (atom_ratio < 0.5)
        idx = np.where(atom_ratios < ATOM_RATIO_THRESHOLD)[0]
        if len(idx) == 0:
            continue

        pressures_lower = pressures[idx]
        atom_ratios_lower = atom_ratios[idx]

        # Guard domain: p0 - P > 0
        mask = p0_lim_func(T) - pressures_lower > 0
        pressures_lower = pressures_lower[mask]
        atom_ratios_lower = atom_ratios_lower[mask]
        if len(pressures_lower) == 0:
            continue

        fit_vals = atom_ratio_eq_lower_func(T, pressures_lower)
        # Remove NaNs/infs if any
        valid = np.isfinite(fit_vals)
        fit_vals = fit_vals[valid]
        atom_ratios_lower = atom_ratios_lower[valid]
        pressures_lower = pressures_lower[valid]

        if len(fit_vals) == 0:
            continue

        err = rmse(atom_ratios_lower, fit_vals)
        rmse_values[T] = err

        plt.scatter(pressures_lower, atom_ratios_lower, label=f'{int(T)} K Data')
        plt.plot(pressures_lower, fit_vals, label=f'{int(T)} K Fit (RMSE: {err:.3f})')

    # Overlay TMAP8 predictions
    for fname, df in tmap_dfs.items():
        T_pred = float(df[COL_TMAP_T].iat[-1])
        P_pred = float(df[COL_TMAP_P].iat[-1])
        AF_pred = float(df[COL_TMAP_AF].iat[-1])

        AF_model = float(atom_ratio_eq_lower_func(T_pred, np.array([P_pred]))[0])
        error_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan

        plt.scatter(P_pred, AF_pred,
                    label=f'{int(T_pred)} K, {P_pred:.2e} Pa (err: {error_pct:.2f}%)',
                    marker='x', color='k', s=90)

    plt.xlabel('Partial Pressure (Pa)')
    plt.ylabel('Atom Ratio (-)')
    plt.xscale('log')
    plt.ylim(0.00, 0.5)
    plt.xlim(1e2, 1e5)
    plt.legend(bbox_to_anchor=(1.15, 1.02))
    plt.grid(True)

    save_fig(fig, 'YHx_PCT_fit_2D_LowPressure.png')

    if rmse_values:
        logger.info(f'Low-pressure RMSE by temperature (K): {rmse_values}')
        avg_rmse = float(np.mean(list(rmse_values.values())))
        logger.info(f'Low-pressure Average RMSE: {avg_rmse:.3f}')
    else:
        logger.info('No RMSE computed for low-pressure (no valid points).')

def plot_high_pressure_fit(temperatures_k: np.ndarray, data_by_temp: Dict[float, pd.DataFrame], gold_folder: Path) -> None:
    """
    Fit and plot high-pressure branch against experimental & TMAP8 predictions.
    Also detects plateau indices via derivative method.
    """
    # Read TMAP8 predictions
    predictions_files = {
        "YHx_PCT_T1273_P3e3_out.csv",
        "YHx_PCT_T1173_P1e3_out.csv",
        "YHx_PCT_T1173_P1e4_out.csv",
        "YHx_PCT_T1173_P5e4_out.csv",
    }
    tmap_dfs: Dict[str, pd.DataFrame] = {}

    for fname in predictions_files:
        fpath = gold_folder / fname
        if fpath.exists():
            tmap_dfs[fname] = pd.read_csv(fpath)
        else:
            logger.warning(f"Missing TMAP8 CSV: {fpath}")

    # Detect plateau positions (derivative-based), then fit upper branch
    fig = plt.figure(figsize=(12, 6))
    rmse_values: Dict[float, float] = {}

    for T in temperatures_k:
        df = data_by_temp.get(T)
        if df is None:
            continue

        start_idx, end_idx = detect_plateau_indices(df, threshold=PLATEAU_DERIVATIVE_THRESHOLD)

        pressures = df[COL_PRESSURE_PA].to_numpy()
        atom_ratios = df[COL_ATOM_RATIO].to_numpy()

        # Use indices above end of plateau as "upper branch"
        if end_idx is not None and end_idx < len(pressures) - 1:
            pressures_upper = pressures[end_idx + 1:]
            atom_ratios_upper = atom_ratios[end_idx + 1:]
        else:
            # Fallback: try high atom ratios directly if plateau not detected
            idx_hi = np.where(atom_ratios >= 1.0)[0]
            if len(idx_hi) == 0:
                continue
            pressures_upper = pressures[idx_hi]
            atom_ratios_upper = atom_ratios[idx_hi]

        # Guard domain: pressure - p0 > 0
        mask = pressures_upper - p0_lim_func(T) > 0
        pressures_upper = pressures_upper[mask]
        atom_ratios_upper = atom_ratios_upper[mask]
        if len(pressures_upper) == 0:
            continue

        fit_vals = atom_ratio_eq_upper_func(T, pressures_upper)
        valid = np.isfinite(fit_vals)
        fit_vals = fit_vals[valid]
        atom_ratios_upper = atom_ratios_upper[valid]
        pressures_upper = pressures_upper[valid]

        if len(fit_vals) == 0:
            continue

        err = rmse(atom_ratios_upper, fit_vals)
        rmse_values[T] = err

        plt.scatter(pressures_upper, atom_ratios_upper, label=f'{int(T)} K Data')
        plt.plot(pressures_upper, fit_vals, label=f'{int(T)} K Fit (RMSE: {err:.3f})')

    # Overlay TMAP8 predictions
    for fname, df in tmap_dfs.items():
        T_pred = float(df[COL_TMAP_T].iat[-1])
        P_pred = float(df[COL_TMAP_P].iat[-1])
        AF_pred = float(df[COL_TMAP_AF].iat[-1])

        AF_model = float(atom_ratio_eq_upper_func(T_pred, np.array([P_pred]))[0])
        error_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan

        plt.scatter(P_pred, AF_pred,
                    label=f'{int(T_pred)} K, {P_pred:.2e} Pa (err: {error_pct:.2f}%)',
                    marker='x', color='k', s=90)

    plt.xlabel('Partial Pressure (Pa)')
    plt.ylabel('Atom Ratio (-)')
    plt.xscale('log')
    plt.legend(bbox_to_anchor=(1.15, 1.02))
    plt.grid(True)

    save_fig(fig, 'YHx_PCT_fit_2D_HighPressure.png')

    if rmse_values:
        logger.info(f'High-pressure RMSE by temperature (K): {rmse_values}')
        avg_rmse = float(np.mean(list(rmse_values.values())))
        logger.info(f'High-pressure Average RMSE: {avg_rmse:.3f}')
    else:
        logger.info('No RMSE computed for high-pressure (no valid points).')

# ------------------------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------------------------

def main() -> None:
    base = script_folder()
    exp_data_folder, gold_folder = resolve_data_folders(base)

    logger.info(f"Experimental data folder: {exp_data_folder}")
    logger.info(f"TMAP8 gold folder:       {gold_folder}")

    data_by_temp = load_pct_data(exp_data_folder, TEMPERATURES_K)

    if not data_by_temp:
        logger.error("No experimental data loaded. Aborting.")
        return

    plot_plateau_fit_vs_selected_pressure(TEMPERATURES_K, data_by_temp)
    plot_low_pressure_fit(TEMPERATURES_K, data_by_temp, gold_folder)
    plot_high_pressure_fit(TEMPERATURES_K, data_by_temp, gold_folder)
if __name__ == "__main__":
    main()
