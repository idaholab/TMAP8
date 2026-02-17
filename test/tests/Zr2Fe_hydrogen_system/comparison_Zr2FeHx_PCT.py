# Import Required Libraries
# Import the necessary libraries, including pandas.
<<<<<<< HEAD
import os
=======

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from mpl_toolkits.mplot3d import Axes3D
import os
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)
<<<<<<< HEAD
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
=======
>>>>>>> 4b97c708 (Fixing python file for test)

<<<<<<< HEAD
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


def atom_ratio_eq_upper_func(T, P):
    """
    High-pressure isotherm model: equilibrium atomic ratio for given T and P.
    T in Kelvin, P in Pa. Returns atomic ratio (H/Zr2Fe).
    """
    T = np.array(T)
    P = np.array(P)
    p0 = 5  # Pa
    safe_log_arg = np.maximum(P - p0, 1e-10)
    exponent = -2.49 - 7.62e-03 * T + (5.63e-02 + 1.72e-4 * T) * np.log(safe_log_arg)
    return 5.0 - 8.32e-03 / (1.0e-03 + np.exp(exponent))


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
data_by_temperature = {}
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
    data_by_temperature[Tk] = df_out.reset_index(drop=True)

# ------------------------------------------------------------------------------
# Raw plot (Atomic Ratio vs Pressure) for each temperature
# ------------------------------------------------------------------------------
fig = plt.figure(figsize=(10, 6))
for Tk in TEMPERATURES_K:
    df = data_by_temperature.get(Tk)
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

rmse_by_temperature = {}
for Tk in TEMPERATURES_K:
    df = data_by_temperature.get(Tk)
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
            plt.scatter(AR_hi, P_hi, label=f"{Tk:.2f} K Data")
            # Compute RMSE on original points (unchanged)
            r = rmse(AR_hi, fit_hi)
            rmse_by_temperature[Tk] = float(r)

            # ---- Smooth analytical curve: densify pressure grid (ONLY CHANGE) ----
            P_min = np.min(P_hi)
            P_max = np.max(P_hi)
            p0_T = 5
            # Start slightly above p0 to keep log argument positive
            P_start = max(P_min, p0_T * 1.001)
            # Use configured number of points for smooth curve
            P_grid = np.logspace(np.log10(P_start), np.log10(P_max), N_SMOOTH)
            fit_grid = atom_ratio_eq_upper_func(Tk, P_grid)

            # Plot smooth analytical/model curve with the same RMSE label
            plt.plot(fit_grid, P_grid, "-", label=f"{Tk:.2f} K Fit RMSE {r:.3f}")


# TMAP8 overlays with markers; compute error only for upper branch (P >= p0)
def overlay_tmap(dfp):
    T_pred = float(dfp[COL_TMAP_T].iat[-1])
    P_pred = float(dfp[COL_TMAP_P].iat[-1])
    AF_pred = float(dfp[COL_TMAP_AF].iat[-1])
    p0 = 5

    AF_model = float(atom_ratio_eq_upper_func(T_pred, np.array([P_pred]))[0])
    err_pct = abs(AF_pred - AF_model) / AF_model * 100 if AF_model != 0 else np.nan
    marker_style = "x"  # high-pressure branch
    label = f"{int(T_pred)}.15 K, {P_pred:.2e} Pa (err {err_pct:.2f}%)"

    plt.scatter(AF_pred, P_pred, marker=marker_style, color="k", s=90, label=label)


for dfp in tmap_data.values():
    overlay_tmap(dfp)

plt.yscale("log")
plt.ylabel("Partial Pressure (Pa)")
plt.xlabel("Atomic Ratio H/Zr₂Fe (-)")
plt.grid(True)
plt.legend(bbox_to_anchor=(1.18, 1.02))
plt.tight_layout()
plt.savefig("Zr2FeHx_PCT_fit_2D.png", dpi=FIG_DPI)
plt.close(fig)


"""
• Plots exp scatter vs TMAP8 dashed
• Calculates MAPE on overlapping atomic‑ratio range
"""
from pathlib import Path

# ------------------------------------------------------------------------------
# Compute Mean Average Percent Error (MAPE)
# ------------------------------------------------------------------------------


def compute_mape(ar_t, p_t, ar_e, p_e):
    # Sort the TMAP8 curve
    ar_t = ar_t[np.argsort(ar_t)]
    p_t = p_t[np.argsort(ar_t)]
    # Sort the Experimental curve
    ar_e = ar_e[np.argsort(ar_e)]
    p_e = p_e[np.argsort(p_e)]

    # Determine the overlapping x-range between the two curves
    lo = max(ar_e.min(), ar_t.min())
    hi = min(ar_e.max(), ar_t.max())

    # Keep only experimental points that fall within the overlapping range
    mask = (ar_e >= lo) & (ar_e <= hi)
    ar_e2 = ar_e[mask]
    p_e2 = p_e[mask]

    # Interpolate experimental curve values at the x-locations of TMAP8 curves
    p_interp = np.interp(ar_e2, ar_t, p_t)
    return np.mean(np.abs((p_interp - p_e2) / p_e2)) * 100


# --------------------------------------------------------------------
# Full PCT TMAP8 modelling capabilities versus experimental data comparsion plots
# --------------------------------------------------------------------

base = Path(__file__).resolve().parent
exp_dir = base / "PCT_data"

fig, ax = plt.subplots(figsize=(10, 7))

for Tk in TEMPERATURES_K:
    df = data_by_temperature.get(Tk)
    ar_exp = df[COL_ATOM_RATIO].values
    p_exp = df[COL_PRESSURE_PA].values

    # ---------------------------
    # Load TMAP8
    # ---------------------------
    tmap_name = f"Zr2FeHx_PCT_Low_to_High_{int(Tk)}K.csv"
    tmap_path = os.path.join(gold_dir, tmap_name)
    df_tmap = pd.read_csv(tmap_path)

    ar_tmap = (
        df_tmap["atomic_fraction_H_enclosure_2_at_interface"].astype(float).to_numpy()
    )
    p_tmap = df_tmap["pressure_H2_enclosure_1_at_interface"].astype(float).to_numpy()

    mask = np.isfinite(ar_tmap) & np.isfinite(p_tmap)
    ar_tmap = ar_tmap[mask]
    p_tmap = p_tmap[mask]

    # ---------------------------
    # MAPE
    # ---------------------------
    mape = compute_mape(ar_tmap, p_tmap, ar_exp, p_exp)

    # ---------------------------
    # Plot
    # ---------------------------
    ax.scatter(ar_exp, p_exp, s=30, label=f"Exp {int(Tk)}.15 K")
    order = np.argsort(ar_tmap)
    ax.plot(
        ar_tmap[order],
        p_tmap[order],
        "--",
        lw=2,
        label=f"TMAP {int(Tk)}.15 K (err={mape:.2f}%)",
    )

# ---------------------------
# Final formatting
# ---------------------------
ax.set_yscale("log")
ax.set_xlabel("Atomic Ratio H/Zr₂Fe")
ax.set_ylabel("Pressure (Pa)")
ax.grid(True, ls="--", alpha=0.6)
ax.legend(fontsize=8)

fig.tight_layout()
plt.savefig("PCT_all_temperatures_experimental_vs_TMAP8_Zr2Fe.png", dpi=FIG_DPI)
=======
# ================================================================================ #
# Constants
molar_mass_Zr2Fe = 2 * 91.22 + 55.85  # = 238.29 g/mol
molar_mass_H = 1.008  # g/mol

# User-defined inputs
temperature_list = [325, 350, 375]  # Celsius


colors = ['blue', 'green', 'red', 'purple']

#NEED TO FIX THIS
# Extract data from experiments
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    folderPath = "../../../../../test/tests/Zr2Fe_hydrogen_system/"
else:                                  # if in test folder
    folderPath = ""
folderNameExpData = 'PCT_data/'



# ============================================================================== #
# Load and process data
data_matrix = []
list_expData = []

fig1, ax1 = plt.subplots()

for i, temp_c in enumerate(temperature_list):
    temp_k = temp_c + 273.15
    file_path = os.path.join(folderPath, folderNameExpData, f"{int(temp_c)}.csv")

    try:
        df = pd.read_csv(file_path)

        if {'Atom Ratio', 'Partial Pressure'}.issubset(df.columns):
            wt_H = df['Atom Ratio'].values
            partial_pressure_pa = df['Partial Pressure'].values * 1e5  # bar to Pa

            atom_ratio = (wt_H / molar_mass_H) / ((100 - wt_H) / molar_mass_Zr2Fe)

            data_matrix.append({
                'Temperature': temp_k,
                'AtomRatio': atom_ratio,
                'PartialPressure': partial_pressure_pa
            })

            df_exp = pd.DataFrame({
                'Temperature (K)': [temp_k] * len(atom_ratio),
                'Atom Ratio': atom_ratio,
                'Partial Pressure (Pa)': partial_pressure_pa
            })
            list_expData.append(df_exp)

            ax1.plot(atom_ratio, partial_pressure_pa, '-', color=colors[i],
                     label=f"{temp_k:.2f} K", linewidth=1.5)
            ax1.scatter(atom_ratio, partial_pressure_pa, color=colors[i], s=30, edgecolor='black')
        else:
            print(f"Missing required columns in {file_path}")

    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

# Finalize first plot
ax1.set_xlabel("Atomic Ratio H/Zr₂Fe (-)")
ax1.set_ylabel("Partial Pressure (Pa)")
ax1.set_yscale("log")
ax1.set_title("Atomic Ratio vs Partial Pressure at Different Temperatures")
ax1.legend()
ax1.grid(True)
plt.savefig('Zr2FeHx_PCT.png', bbox_inches='tight', dpi=300)
plt.close(fig1)

# ============================================================================= #
# Define theoretical pressure limit function
def p0_lim_func(temperature):
    temperature = np.array(temperature)
    return np.exp(-4.12265+ 1.0288e-02 * temperature)

# Convert temperature_list from °C to K
temperature_list_K = np.array([t + 273.15 for t in temperature_list])
p0_lim = p0_lim_func(temperature_list_K)

# ============================================================================= #
# Extract filtered pressures and temperatures based on atom ratio threshold
atom_ratio_threshold = 0.5
selected_temps = []
selected_pressures = []

for data in list_expData:
    atom_ratio = data['Atom Ratio'].values
    pressure = data['Partial Pressure (Pa)'].values
    temperature = data['Temperature (K)'].iloc[0]

    idx = np.where(atom_ratio > atom_ratio_threshold)[0]
    if len(idx) > 0:
        selected_temps.append(temperature)
        selected_pressures.append(pressure[idx[0]])
    else:
        print(f'No atom ratio > {atom_ratio_threshold} found for {temperature:.2f} K')

selected_temps = np.array(selected_temps)
selected_pressures = np.array(selected_pressures)

# ============================================================================= #
# Plot the fit and the filtered plateau pressures
fig2, ax2 = plt.subplots(figsize=(5, 5))
ax2.plot(temperature_list_K, p0_lim, label='Fit', linestyle='--')
ax2.scatter(selected_temps, selected_pressures, color='red', label='Pressures')
ax2.set_xlabel('Temperature (K)')
ax2.set_ylabel('log(Pressure) (Pa)')
ax2.legend()
ax2.grid(True)
fig2.tight_layout()
plt.savefig('Zr2FeHx_PCT_pressure_limiter_fit.png', bbox_inches='tight', dpi=300)
plt.close(fig2)

# ============================================================================= #

# Define pressure isotherm model function
def atom_ratio_eq_upper_func(temperature, pressure):
    """
    Calculates the equilibrium atomic ratio at high pressures for a given temperature and pressure.
    """
    temperature = np.array(temperature)
    pressure = np.array(pressure)
    p0 = p0_lim_func(temperature)

    # Ensure log argument is positive
    safe_log_arg = np.maximum(pressure - p0, 1e-10)

    exponent = (
        5.4074
        - 1.3571e-2 * temperature
        + (0.23190 + 1.5078e-4 * temperature) * np.log(safe_log_arg)
    )

    return 4.30 - 1.8103 / (0.5 + np.exp(exponent))


# ============================================================================ #
if "/tmap8/doc/" in script_folder.lower():     # if in documentation folder
    csv_folder = "../../../../../test/tests/Zr2Fe_hydrogen_system/gold/"
else:                                  # if in test folder
    csv_folder = "./gold/"

TMAP8_prediction_T648_P1e05 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T648_P1e05_out.csv")
TMAP8_prediction_T648_P1e02 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T648_P1e02_out.csv")

TMAP8_prediction_T598_P1e03 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T598_P1e03_out.csv")
TMAP8_prediction_T623_P1e04 = pd.read_csv(csv_folder + "Zr2FeHx_PCT_T623_P1e04_out.csv")

TMAP8_prediction_T648_P1e05_temperature = TMAP8_prediction_T648_P1e05['temperature'].iat[-1]
TMAP8_prediction_T648_P1e05_pressure = TMAP8_prediction_T648_P1e05['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T648_P1e05_atomic_fraction = TMAP8_prediction_T648_P1e05['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T648_P1e05_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T648_P1e05_temperature,TMAP8_prediction_T648_P1e05_pressure)

TMAP8_prediction_T648_P1e02_temperature = TMAP8_prediction_T648_P1e02['temperature'].iat[-1]
TMAP8_prediction_T648_P1e02_pressure = TMAP8_prediction_T648_P1e02['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T648_P1e02_atomic_fraction = TMAP8_prediction_T648_P1e02['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T648_P1e02_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T648_P1e02_temperature,TMAP8_prediction_T648_P1e02_pressure)

TMAP8_prediction_T598_P1e03_temperature = TMAP8_prediction_T598_P1e03['temperature'].iat[-1]
TMAP8_prediction_T598_P1e03_pressure = TMAP8_prediction_T598_P1e03['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T598_P1e03_atomic_fraction = TMAP8_prediction_T598_P1e03['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T598_P1e03_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T598_P1e03_temperature,TMAP8_prediction_T598_P1e03_pressure)

TMAP8_prediction_T623_P1e04_temperature = TMAP8_prediction_T623_P1e04['temperature'].iat[-1]
TMAP8_prediction_T623_P1e04_pressure = TMAP8_prediction_T623_P1e04['pressure_H2_enclosure_1_at_interface'].iat[-1]
TMAP8_prediction_T623_P1e04_atomic_fraction = TMAP8_prediction_T623_P1e04['atomic_fraction_H_enclosure_2_at_interface'].iat[-1]
analytical_equation_T623_P1e04_atomic_fraction = atom_ratio_eq_upper_func(TMAP8_prediction_T623_P1e04_temperature,TMAP8_prediction_T623_P1e04_pressure)


# ============================================================================ #

# Initialize a dictionary to store RMSE values for each temperature
RMSE_values = {}

# Plot the data points and the fit function for each temperature
fig = plt.figure(figsize=(12, 6))

print('temperature_list',temperature_list)

for i, temperature in enumerate(temperature_list):
  # Extract the data points for the current temperature
  expData = list_expData[i]
  pressures = expData['Partial Pressure (Pa)']
  atom_ratios = expData['Atom Ratio']

  idx = np.where(atom_ratios> 0.5)[0]



  if  idx is not None:
    # Select only the values that are above the transition region
    pressures_upper = pressures[idx]
    atom_ratios_upper = atom_ratios[idx]

    # Calculate the fit values using the function
    fit_values_upper = atom_ratio_eq_upper_func(temperature+273.15, pressures_upper)


    # Calculate the RMSE for the current temperature
    RMSE = np.sqrt(np.mean((np.array(atom_ratios_upper) - np.array(fit_values_upper))**2))
    RMSE_values[temperature] = RMSE



    plt.scatter(pressures_upper, atom_ratios_upper, label=f'{temperature+273.15} K Data')

    # Plot the fit function
    plt.plot(pressures_upper, fit_values_upper, label=f'{temperature+273.15} K Fit (RMSE: {RMSE:.2f})')

# plot the TMAP8 predictions
error = abs(TMAP8_prediction_T648_P1e05_atomic_fraction-analytical_equation_T648_P1e05_atomic_fraction)/analytical_equation_T648_P1e05_atomic_fraction*100
plt.scatter(TMAP8_prediction_T648_P1e05_pressure, TMAP8_prediction_T648_P1e05_atomic_fraction, label =f'{TMAP8_prediction_T648_P1e05_temperature} K and {TMAP8_prediction_T648_P1e05_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T648_P1e02_atomic_fraction-analytical_equation_T648_P1e02_atomic_fraction)/analytical_equation_T648_P1e02_atomic_fraction*100
plt.scatter(TMAP8_prediction_T648_P1e02_pressure, TMAP8_prediction_T648_P1e02_atomic_fraction, label =f'{TMAP8_prediction_T648_P1e02_temperature} K and {TMAP8_prediction_T648_P1e02_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T598_P1e03_atomic_fraction-analytical_equation_T598_P1e03_atomic_fraction)/analytical_equation_T598_P1e03_atomic_fraction*100
plt.scatter(TMAP8_prediction_T598_P1e03_pressure, TMAP8_prediction_T598_P1e03_atomic_fraction, label =f'{TMAP8_prediction_T598_P1e03_temperature} K and {TMAP8_prediction_T598_P1e03_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)
error = abs(TMAP8_prediction_T623_P1e04_atomic_fraction-analytical_equation_T623_P1e04_atomic_fraction)/analytical_equation_T623_P1e04_atomic_fraction*100
plt.scatter(TMAP8_prediction_T623_P1e04_pressure, TMAP8_prediction_T623_P1e04_atomic_fraction, label =f'{TMAP8_prediction_T623_P1e04_temperature} K and {TMAP8_prediction_T623_P1e04_pressure:.2f} Pa prediction (error: {error:.2f} %)', marker='x', color= 'k', s=90)

plt.xlabel('Partial Pressure (Pa)')
plt.ylabel('Atom Ratio (-)')
plt.xscale('log')
plt.legend(bbox_to_anchor=(1.1, 1.05))
plt.grid(True)
plt.tight_layout()
plt.savefig('Zr2FeHx_PCT_fit_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# print the RMSE values for each temperature
print('temperatures (K) and RMSE values: ',RMSE_values)

# print the average RMSE value
average_rmse = np.mean(list(RMSE_values.values()))
print(f'Average RMSE: {average_rmse:.2f}')


>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
