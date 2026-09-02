#!/usr/bin/env python3

"""Analytical comparison for the Fuerst et al. (2023) PAV test."""

from __future__ import annotations

import csv
import math
import os
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import brentq


SCRIPT_FOLDER = Path(os.path.abspath(__file__)).parent
os.chdir(SCRIPT_FOLDER)


def locate_input_file() -> Path:
    """Return the location of the ver-1p input file."""
    candidates = [SCRIPT_FOLDER / "ver-1p.i"]
    candidates.extend(
        parent / "test" / "tests" / "ver-1p" / "ver-1p.i"
        for parent in SCRIPT_FOLDER.parents
    )

    for candidate in candidates:
        if candidate.is_file():
            return candidate

    searched = "\n  ".join(str(path) for path in candidates)
    raise FileNotFoundError(
        f"Could not find ver-1p input file. Searched:\n  {searched}"
    )


def get_numeric_parameter(parameter_name: str) -> float:
    """Read a numerical top level parameter from ver-1p.i."""
    input_file = locate_input_file()

    with input_file.open(encoding="utf-8") as handle:
        for line in handle:
            stripped = line.strip()

            if stripped.startswith(f"{parameter_name} ="):
                raw_value = stripped.split("=", maxsplit=1)[1]
                raw_value = raw_value.split("#", maxsplit=1)[0].strip()
                return float(raw_value)

    raise KeyError(
        f"Could not find parameter {parameter_name!r} in {input_file}"
    )


# Model parameters read from ver-1p.i
T = get_numeric_parameter("T")
R = get_numeric_parameter("R")
C_IN = get_numeric_parameter("C_in")
RE = get_numeric_parameter("Re")
L_TUBE = get_numeric_parameter("L_tube")
R_I = get_numeric_parameter("r_i")
R_O = get_numeric_parameter("r_o")
N_SEGMENTS = int(get_numeric_parameter("N_segments"))
U_PBLI = get_numeric_parameter("u_PbLi")
K_L_TABLE_BASE = get_numeric_parameter("K_L_table_base")
K_R = get_numeric_parameter("K_R")
M_PBLI_ATOM = get_numeric_parameter("M_PbLi_atom")


AREA_RATIO = R_O / R_I
K_R_INNER = AREA_RATIO * K_R

# Verification criterion for the 20 segment solution
MAX_ERROR_PERCENT = 1.0


def locate_gold_csv() -> Path:
    """Return the location of the ver-1p gold CSV file."""
    candidates = [SCRIPT_FOLDER / "gold" / "ver-1p_out.csv"]
    candidates.extend(
        parent
        / "test"
        / "tests"
        / "ver-1p"
        / "gold"
        / "ver-1p_out.csv"
        for parent in SCRIPT_FOLDER.parents
    )

    for candidate in candidates:
        if candidate.is_file():
            return candidate

    searched = "\n  ".join(str(path) for path in candidates)
    raise FileNotFoundError(
        f"Could not find ver-1p gold CSV. Searched:\n  {searched}"
    )


def surface_concentration(
    c_bulk: float,
    partition_ratio: float,
    radial_resistance: float,
) -> float:
    """Return the vanadium concentration at the vacuum-facing surface."""
    radical = (
        1.0
        + 4.0
        * radial_resistance
        * K_R_INNER
        * partition_ratio
        * c_bulk
    )

    return (
        2.0 * partition_ratio * c_bulk
        / (1.0 + math.sqrt(radical))
    )


def analytical_solution() -> dict[str, object]:
    """Return the continuous analytical axial concentration solution."""
    # PbLi properties.
    d_l = 8.30e-9 * math.exp(-7.37e3 / (R * T))
    rho_pbli = 10520.35 - 1.19051 * T
    c_pbli_atoms = rho_pbli / M_PBLI_ATOM
    k_l = K_L_TABLE_BASE * c_pbli_atoms

    # Vanadium properties
    d_s = 2.90e-8 * math.exp(-4.2e3 / (R * T))
    k_s = 0.138 * math.exp(29.0e3 / (R * T))

    # Liquid mass transfer
    d_h = 2.0 * R_I
    q_pbli = U_PBLI * math.pi * R_I**2
    nu_pbli = U_PBLI * d_h / RE
    sc = nu_pbli / d_l
    sh = 0.023 * RE**0.83 * sc ** (1.0 / 3.0)
    k_t = sh * d_l / d_h

    # Radial transport parameters
    partition_ratio = k_s / k_l
    membrane_resistance = (
        R_I * math.log(R_O / R_I) / d_s
    )
    radial_resistance = (
        partition_ratio / k_t + membrane_resistance
    )

    y_in = surface_concentration(
        C_IN,
        partition_ratio,
        radial_resistance,
    )

    def axial_residual(y: float, z: float) -> float:
        return (
            1.0 / y
            - 1.0 / y_in
            - 2.0
            * radial_resistance
            * K_R_INNER
            * math.log(y / y_in)
            - (
                2.0
                * math.pi
                * R_I
                * partition_ratio
                * K_R_INNER
                / q_pbli
            )
            * z
        )

    concentrations = []

    for index in range(1, N_SEGMENTS + 1):
        z = index * L_TUBE / N_SEGMENTS

        y = brentq(
            axial_residual,
            y_in * 1.0e-8,
            y_in,
            args=(z,),
            xtol=1.0e-14,
            rtol=1.0e-14,
        )

        c_bulk = (
            y + radial_resistance * K_R_INNER * y**2
        ) / partition_ratio

        concentrations.append(c_bulk)

    c_out = concentrations[-1]
    efficiency = 1.0 - c_out / C_IN

    # Average flux on the inner surface
    total_inner_area = 2.0 * math.pi * R_I * L_TUBE
    average_flux = (
        q_pbli * (C_IN - c_out) / total_inner_area
    )

    return {
        "concentrations": concentrations,
        "outlet": c_out,
        "efficiency": efficiency,
        "average_flux": average_flux,
    }


def read_last_csv_row(path: Path) -> dict[str, str]:
    """Return the final data row in a CSV file."""
    with path.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))

    if not rows:
        raise RuntimeError(f"No data rows found in {path}")

    return rows[-1]


def value(row: dict[str, str], name: str) -> float:
    """Return a named CSV value as a float."""
    if name not in row:
        raise KeyError(
            f"Column {name!r} is missing from the TMAP8 CSV"
        )

    return float(row[name])


def relative_error_percent(
    actual: float,
    expected: float,
) -> float:
    """Return the absolute relative error as a percentage."""
    return abs((actual - expected) / expected) * 100.0


def make_plot(
    actual: dict[str, str],
    expected: dict[str, object],
) -> float:
    """Plot TMAP8 and analytical concentration profiles."""
    z = np.linspace(
        0.0,
        L_TUBE,
        N_SEGMENTS + 1,
    )

    tmap8 = np.array(
        [value(actual, "C00_inlet")]
        + [
            value(actual, f"C{index:02d}_pp")
            for index in range(1, N_SEGMENTS + 1)
        ]
    )

    analytical = np.array(
        [C_IN] + list(expected["concentrations"])
    )

    relative_difference = (
        (tmap8 - analytical) / analytical
    )
    rmspe = float(
        np.sqrt(np.mean(relative_difference**2)) * 100.0
    )

    plt.figure(figsize=(8, 5.4))

    plt.plot(
        z,
        tmap8,
        label=f"TMAP8 ({N_SEGMENTS} segments)",
        linewidth=2.2,
    )

    plt.plot(
        z,
        analytical,
        "--",
        label="Analytical",
        linewidth=2.0,
    )

    plt.xlabel("Axial location (m)")
    plt.ylabel(r"Bulk concentration (mol m$^{-3}$)")
    plt.grid(
        which="major",
        linestyle="--",
        alpha=0.3,
    )
    plt.minorticks_on()
    plt.legend()

    plt.text(
        0.05,
        0.08,
        f"RMSPE = {rmspe:.3f}%",
        transform=plt.gca().transAxes,
    )

    plt.tight_layout()
    plt.savefig(
        "ver-1p_comparison_analytical_concentration.png",
        dpi=300,
    )
    plt.close()

    return rmspe


def main() -> int:
    """Run the analytical comparison and return an exit status."""
    try:
        gold_csv = locate_gold_csv()
        analytical = analytical_solution()
        actual = read_last_csv_row(gold_csv)

    except (
        FileNotFoundError,
        KeyError,
        OSError,
        RuntimeError,
        ValueError,
    ) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2

    rmspe = make_plot(actual, analytical)

    tmap8_outlet = value(actual, "C20_pp")
    tmap8_efficiency = value(
        actual,
        "extraction_efficiency",
    )
    tmap8_flux = value(
        actual,
        "average_permeation_flux_mol_m2_s",
    )

    outlet_error = relative_error_percent(
        tmap8_outlet,
        analytical["outlet"],
    )
    efficiency_error = relative_error_percent(
        tmap8_efficiency,
        analytical["efficiency"],
    )
    flux_error = relative_error_percent(
        tmap8_flux,
        analytical["average_flux"],
    )

    print(f"Gold CSV: {gold_csv}")
    print(
        "Analytical outlet concentration: "
        f"{analytical['outlet']:.12e} mol/m^3"
    )
    print(
        "TMAP8 outlet concentration:       "
        f"{tmap8_outlet:.12e} mol/m^3"
    )
    print(
        "Outlet relative error:             "
        f"{outlet_error:.6f}%"
    )
    print(
        "Analytical extraction efficiency: "
        f"{analytical['efficiency']:.12e}"
    )
    print(
        "TMAP8 extraction efficiency:       "
        f"{tmap8_efficiency:.12e}"
    )
    print(
        "Efficiency relative error:         "
        f"{efficiency_error:.6f}%"
    )
    print(
        "Analytical average permeation flux: "
        f"{analytical['average_flux']:.12e} mol/m^2/s"
    )
    print(
        "TMAP8 average permeation flux:       "
        f"{tmap8_flux:.12e} mol/m^2/s"
    )
    print(
        "Flux relative error:                 "
        f"{flux_error:.6f}%"
    )
    print(
        "Concentration profile RMSPE:         "
        f"{rmspe:.6f}%"
    )

    failures = []

    if rmspe > MAX_ERROR_PERCENT:
        failures.append(
            f"profile RMSPE = {rmspe:.6f}%"
        )

    if outlet_error > MAX_ERROR_PERCENT:
        failures.append(
            f"outlet error = {outlet_error:.6f}%"
        )

    if efficiency_error > MAX_ERROR_PERCENT:
        failures.append(
            f"efficiency error = {efficiency_error:.6f}%"
        )

    if flux_error > MAX_ERROR_PERCENT:
        failures.append(
            f"average flux error = {flux_error:.6f}%"
        )

    if failures:
        print(
            "\nFAILED analytical comparison:",
            file=sys.stderr,
        )

        for failure in failures:
            print(f"  {failure}", file=sys.stderr)

        print(
            f"Allowed error = {MAX_ERROR_PERCENT:.2f}%",
            file=sys.stderr,
        )

        return 1

    print(
        "TMAP8 agrees with the continuous analytical "
        f"solution within {MAX_ERROR_PERCENT:.1f}%."
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
