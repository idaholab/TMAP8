# Cleaned and refactored analysis of YHx PCT data

from __future__ import annotations

import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Changes working directory to script directory (for consistent MooseDocs usage).
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

# -------------------------------------------------------------------------------
# Configuration & Constants
# -------------------------------------------------------------------------------

C_TO_K = 273.15  # Celsius to Kelvin

TEMPERATURES_K = [433, 573, 604]  # °K
TEMPERATURES_C = np.array([t - C_TO_K for t in TEMPERATURES_K])

# Thresholds
ATOM_RATIO_THRESHOLD_START = 0.5                # used for selecting lower/upper branches
ATOM_RATIO_THRESHOLD_END = 1.4
FIG_DPI = 300

# Column names expected in experimental CSV
COL_PRESSURE_NA = "Partial Pressure"      # raw field from CSV; may be Pa or log10(Pa)
COL_PRESSURE_PA = "Partial Pressure (Pa)" # computed/normalized field
COL_ATOM_RATIO = "Atom Ratio"
COL_TEMPERATURE_K = "Temperature (K)"

# Column names expected in TMAP8 CSVs
COL_TMAP_T = "temperature"
COL_TMAP_P = "pressure_H2_enclosure_1_at_interface"
COL_TMAP_AF = "atomic_fraction_H_enclosure_2_at_interface"

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)

# ------------------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------------------

def script_folder() -> Path:
    """Return the directory of this script, with a fallback to current working dir."""
    try:
        return Path(__file__).resolve().parent
    except NameError:
        # __file__ not defined (e.g., interactive)
        return Path.cwd()

def resolve_data_folders(base_folder: Path) -> Tuple[Path, Path]:
    """
    Determine experimental data folder and TMAP8 gold folder depending on path context.
    """
    base_str = str(base_folder).lower()

    # Experimental PCT data
    if "/tmap8/doc/" in base_str:
        exp_base = base_folder / "../../../../../test/tests/ZrCo_hydrogen_system"
    else:
        exp_base = base_folder  # current folder

    exp_data_folder = (exp_base / "PCT_data").resolve()

    # TMAP8 gold outputs
    if "/tmap8/doc/" in base_str:
        gold_folder = (base_folder / "../../../../../test/tests/ZrCo_hydrogen_system/gold").resolve()
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
    return np.exp(12.427 - 4.8366e-2 * T + 7.1464e-5 * np.square(T))

def atom_ratio_eq_lower_func(temperature: float, pressure: np.ndarray) -> np.ndarray:
    """
    Lower-pressure branch: atom ratio as a function of (T, P).
    Domain guard: requires p0_lim(T) - P > 0 for log().
    """
    T = float(temperature)
    p0 = p0_lim_func(T)
    arg = np.maximum((p0 - pressure),1e-10)
    val = 0.5 - (0.01 + np.exp(
             -4.2856 + 1.9812e-02 * T + (-1.0656 + 5.6857e-04 * T) * np.log(arg)
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
        val = 2.5 - 3.4249 * (1.4 + np.exp(
            7.9727 - 0.019856 * T + (-1.6938e-01 + 1.1876e-03 * T) * np.log(arg)
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
        file_path = exp_data_folder / f"{temp_K}.csv"

        if not file_path.exists():
            logger.warning(f"Missing experimental CSV for {temp_K}K: {file_path}")
            continue

        try:
            df = pd.read_csv(file_path)

            if COL_ATOM_RATIO not in df.columns:
                raise ValueError(f"CSV missing required column: '{COL_ATOM_RATIO}'")
            if COL_PRESSURE_NA in df.columns:
                df[COL_PRESSURE_PA] = 10**(df[COL_PRESSURE_NA])
            else:
                raise ValueError(f"CSV missing required pressure column: '{COL_PRESSURE_NA}' or '{COL_PRESSURE_PA}'")

            # Add temperature column
            df[COL_TEMPERATURE_K] = float(temp_K)

            # Clean and sort by pressure (important for derivatives)
            df = df[[COL_PRESSURE_PA, COL_ATOM_RATIO, COL_TEMPERATURE_K]].dropna()
            df.sort_values(by=COL_PRESSURE_PA, inplace=True)
            df.reset_index(drop=True, inplace=True)

            data_by_temp[temp_K] = df

        except Exception as e:
            logger.error(f"Error processing file {file_path}: {e}")

    return data_by_temp



def rmse(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    """Root Mean Squared Error."""
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

    selected_temps: List[float] = []
    selected_pressures: List[float] = []

    for T in temperatures_k:
        df = data_by_temp.get(T)
        if df is None or df.empty:
            continue

        atom_ratio = df[COL_ATOM_RATIO].to_numpy(dtype=float)
        pressure = df[COL_PRESSURE_PA].to_numpy(dtype=float)

        idx = np.where(atom_ratio > ATOM_RATIO_THRESHOLD_START)[0]
        if len(idx) > 0:
            selected_temps.append(float(T))
            selected_pressures.append(float(pressure[idx[0]]))
        else:
            logger.info(f"No atom ratio > {ATOM_RATIO_THRESHOLD_START} found for {T:.0f} K")

    fig = plt.figure(figsize=(5, 5))
    plt.plot(temperatures_k, p0_vals, label='Fit', linestyle='--')
    if selected_temps:
        plt.scatter(selected_temps, selected_pressures, color='red', label=f'Plateau Pressures')

    plt.xlabel('Temperature (K)')
    plt.ylabel('Pressure (Pa)')
    plt.yscale('log')
    plt.legend()
    plt.grid(True)

    save_fig(fig, 'ZrCoHx_PCT_plateau_pressure_fit.png')

def plot_low_pressure_fit(temperatures_k: np.ndarray, data_by_temp: Dict[float, pd.DataFrame], gold_folder: Path) -> None:
    """
    Fit and plot low-pressure branch against experimental & TMAP8 predictions.
    Lower branch: Atom Ratio < ATOM_RATIO_THRESHOLD_START and P < p0_lim(T).
    """
    predictions_files = {
        "ZrCoHx_PCT_T433_1E2P_out.csv",
        "ZrCoHx_PCT_T573_1E3P_out.csv",
        "ZrCoHx_PCT_T604_6E3P_out.csv",
        "ZrCoHx_PCT_T604_1E4P_out.csv",
    }
    tmap_dfs: Dict[str, pd.DataFrame] = {}
    for fname in predictions_files:
        fpath = gold_folder / fname
        if fpath.exists():
            try:
                tmap_dfs[fname] = pd.read_csv(fpath)
            except Exception as e:
                logger.warning(f"Failed reading TMAP8 CSV {fpath}: {e}")
        else:
            logger.warning(f"Missing TMAP8 CSV: {fpath}")

    fig = plt.figure(figsize=(12, 8))
    rmse_values: Dict[float, float] = {}

    for T in temperatures_k:
        df = data_by_temp.get(T)
        if df is None or df.empty:
            continue

        pressures = df[COL_PRESSURE_PA].to_numpy(dtype=float)
        atom_ratios = df[COL_ATOM_RATIO].to_numpy(dtype=float)

        # Lower branch selection
        mask_lower = np.where(atom_ratios < 1) [0]
        pressures_lower = pressures[mask_lower]
        atom_ratios_lower = atom_ratios[mask_lower]
        fit_vals = atom_ratio_eq_lower_func(float(T), pressures_lower)

        err = rmse(atom_ratios_lower, fit_vals)
        rmse_values[float(T)] = err

        plt.scatter(pressures_lower, atom_ratios_lower, label=f'{int(T)} K Data')
        plt.plot(pressures_lower, fit_vals, label=f'{int(T)} K Fit (RMSE: {err:.3f})')

    # Overlay TMAP8 predictions
    for fname, df_pred in tmap_dfs.items():
        try:
            T_pred = float(df_pred[COL_TMAP_T].iat[-1])
            P_pred = float(df_pred[COL_TMAP_P].iat[-1])
            AF_pred = float(df_pred[COL_TMAP_AF].iat[-1])

            AF_model = float(atom_ratio_eq_lower_func(T_pred, np.array([P_pred]))[0])
            error_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan

            plt.scatter(P_pred, AF_pred,
                        label=f'{int(T_pred)} K, {P_pred:.2e} Pa (err: {error_pct:.2f}%)',
                        marker='x', color='k', s=90)
        except Exception as e:
            logger.warning(f"TMAP8 overlay error for {fname}: {e}")

    plt.xlabel('Partial Pressure (Pa)')
    plt.ylabel('Atom Ratio (-)')
    plt.xscale('log')
    plt.ylim(0.0001, 0.5)
    plt.legend(bbox_to_anchor=(1.15, 1.02))
    plt.grid(True)

    save_fig(fig, 'ZrCoHx_PCT_fit_2D_LowPressure.png')

    if rmse_values:
        logger.info(f'Low-pressure RMSE by temperature (K): {rmse_values}')
        avg_rmse = float(np.mean(list(rmse_values.values())))
        logger.info(f'Low-pressure Average RMSE: {avg_rmse:.3f}')
    else:
        logger.info('No RMSE computed for low-pressure (no valid points).')

def plot_high_pressure_fit(temperatures_k: np.ndarray, data_by_temp: Dict[float, pd.DataFrame], gold_folder: Path) -> None:
    """
    Fit and plot high-pressure branch against experimental & TMAP8 predictions.
    Also detects plateau indices via derivative method on pressure-sorted data.
    """
    predictions_files = {
        "ZrCoHx_PCT_T433_1E4P_out.csv",
        "ZrCoHx_PCT_T433_3E4P_out.csv",
        "ZrCoHx_PCT_T573_1E4P_out.csv",
        "ZrCoHx_PCT_T604_5E4P_out.csv",
    }
    tmap_dfs: Dict[str, pd.DataFrame] = {}
    for fname in predictions_files:
        fpath = gold_folder / fname
        if fpath.exists():
            try:
                tmap_dfs[fname] = pd.read_csv(fpath)
            except Exception as e:
                logger.warning(f"Failed reading TMAP8 CSV {fpath}: {e}")
        else:
            logger.warning(f"Missing TMAP8 CSV: {fpath}")

    fig = plt.figure(figsize=(12, 6))
    rmse_values: Dict[float, float] = {}

    for T in temperatures_k:
        df = data_by_temp.get(T)
        if df is None or df.empty:
            continue

        pressures = df[COL_PRESSURE_PA].to_numpy(dtype=float)
        atom_ratios = df[COL_ATOM_RATIO].to_numpy(dtype=float)


        mask =np.where( atom_ratios > ATOM_RATIO_THRESHOLD_END) [0]
        pressures_upper = pressures[mask]
        atom_ratios_upper = atom_ratios[mask]

        fit_vals = atom_ratio_eq_upper_func(float(T), pressures_upper)
        valid = np.isfinite(fit_vals)
        pressures_upper = pressures_upper[valid]
        atom_ratios_upper = atom_ratios_upper[valid]
        fit_vals = fit_vals[valid]
        if len(fit_vals) == 0:
            continue

        err = rmse(atom_ratios_upper, fit_vals)
        rmse_values[float(T)] = err

        plt.scatter(pressures_upper, atom_ratios_upper, label=f'{int(T)} K Data')
        plt.plot(pressures_upper, fit_vals, label=f'{int(T)} K Fit (RMSE: {err:.3f})')

    # Overlay TMAP8 predictions
    for fname, df_pred in tmap_dfs.items():
        try:
            T_pred = float(df_pred[COL_TMAP_T].iat[-1])
            P_pred = float(df_pred[COL_TMAP_P].iat[-1])
            AF_pred = float(df_pred[COL_TMAP_AF].iat[-1])

            AF_model = float(atom_ratio_eq_upper_func(T_pred, np.array([P_pred]))[0])
            error_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan

            plt.scatter(P_pred, AF_pred,
                        label=f'{int(T_pred)} K, {P_pred:.2e} Pa (err: {error_pct:.2f}%)',
                        marker='x', color='k', s=90)
        except Exception as e:
            logger.warning(f"TMAP8 overlay error for {fname}: {e}")

    plt.xlabel('Partial Pressure (Pa)')
    plt.ylabel('Atom Ratio (-)')
    plt.xscale('log')
    plt.legend(bbox_to_anchor=(1.15, 1.02))
    plt.grid(True)

    save_fig(fig, 'ZrCoHx_PCT_fit_2D_HighPressure.png')

    if rmse_values:
        logger.info(f'High-pressure RMSE by temperature (K): {rmse_values}')
        avg_rmse = float(np.mean(list(rmse_values.values())))
        logger.info(f'High-pressure Average RMSE: {avg_rmse:.3f}')
    else:
        logger.info('No RMSE computed for high-pressure (no valid points).')
# ------------------------------------------------------------------------------
# Raw Experimental Data Plot
# ------------------------------------------------------------------------------

def plot_raw_pct_data(temperatures_k: np.ndarray, data_by_temp: Dict[float, pd.DataFrame]) -> None:
    """
    Plot the raw experimental PCT data: pressure (Pa) vs atom ratio (-) for each temperature.
    Saves as a PNG without any model overlays or TMAP8 predictions.
    """
    fig = plt.figure(figsize=(10, 6))

    for T in temperatures_k:
        df = data_by_temp.get(float(T))
        if df is None or df.empty:
            logger.warning(f"No raw data available for {T} K; skipping.")
            continue

        # Data already sorted by pressure during load
        pressures = df[COL_PRESSURE_PA].to_numpy(dtype=float)
        atom_ratios = df[COL_ATOM_RATIO].to_numpy(dtype=float)

        # Raw scatter + line to guide the eye
        plt.scatter(atom_ratios,pressures, s=28, alpha=0.9, label=f'{int(T)} K')
        plt.plot(atom_ratios,pressures , linewidth=1.0, alpha=0.7)

    plt.ylabel('Partial Pressure (Pa)')
    plt.xlabel('Atom Ratio (-)')
    plt.yscale('log')
    plt.grid(True, which='both', linestyle='--', alpha=0.5)
    plt.legend(title='Temperature', loc='best')
    save_fig(fig, 'ZrCoHx_PCT_Data.png')

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

    # NEW: Raw experimental plot (pressure vs composition at various temperatures)
    plot_raw_pct_data(TEMPERATURES_K, data_by_temp)

    plot_plateau_fit_vs_selected_pressure(TEMPERATURES_K, data_by_temp)
    plot_low_pressure_fit(TEMPERATURES_K, data_by_temp, gold_folder)
    plot_high_pressure_fit(TEMPERATURES_K, data_by_temp, gold_folder)

if __name__ == "__main__":
    main()
