#!/usr/bin/env python3
import json
import math
from pathlib import Path

KB_EV = 8.617333262145179e-05


def arrhenius(prefactor: float, energy_ev: float, temperature_k: float) -> float:
    return prefactor * math.exp(-energy_ev / (KB_EV * temperature_k))


def main() -> None:
    temperature_ref = 370.0
    length_reference_um = 1.0

    tungsten_density_um3 = 6.3222e10
    diffusion_prefactor_um2_s = 1.6e5
    diffusion_energy_ev = 0.28
    trapping_prefactor_s = 1.6e-7 / (1.1e-10 ** 2 * 6.0)
    trapping_energies_ev = {
        "intrinsic": 0.28,
        "1": 0.28,
        "2": 0.28,
        "3": 0.28,
        "4": 0.28,
        "5": 0.28,
    }
    detrapping_prefactor_s = 1.0e13
    detrapping_energies_ev = {
        "intrinsic": 1.04,
        "1": 1.15,
        "2": 1.35,
        "3": 1.65,
        "4": 1.85,
        "5": 2.05,
    }
    mobile_concentration_reference_um3 = (
        (detrapping_prefactor_s / trapping_prefactor_s)
        * math.exp(
            -(detrapping_energies_ev["intrinsic"] - trapping_energies_ev["intrinsic"])
            / (KB_EV * temperature_ref)
        )
        * tungsten_density_um3
    )

    diffusion_rate_ref = arrhenius(diffusion_prefactor_um2_s, diffusion_energy_ev, temperature_ref)
    diffusion_time_reference = length_reference_um ** 2 / diffusion_rate_ref

    trapping_rates = {
        name: trapping_prefactor_s * mobile_concentration_reference_um3 / tungsten_density_um3
        for name in trapping_energies_ev
    }
    trapping_effective_rates = {
        name: arrhenius(trapping_rates[name], trapping_energies_ev[name], temperature_ref)
        for name in trapping_rates
    }
    trapping_time_scales = {name: 1.0 / rate for name, rate in trapping_effective_rates.items()}

    release_effective_rates = {
        name: arrhenius(detrapping_prefactor_s, detrapping_energies_ev[name], temperature_ref)
        for name in detrapping_energies_ev
    }
    release_time_scales = {name: 1.0 / rate for name, rate in release_effective_rates.items()}

    fastest_reaction_time = min(
        min(trapping_time_scales.values()), min(release_time_scales.values())
    )
    time_reference = min(diffusion_time_reference, fastest_reaction_time)

    dimensionless_trapping_rates = {
        name: trapping_prefactor_s * time_reference * mobile_concentration_reference_um3 / tungsten_density_um3
        for name in trapping_energies_ev
    }
    dimensionless_release_rates = {
        name: detrapping_prefactor_s * time_reference for name in detrapping_energies_ev
    }

    payload = {
        "temperature_reference_K": temperature_ref,
        "length_reference_um": length_reference_um,
        "mobile_concentration_reference_at_per_um3": mobile_concentration_reference_um3,
        "diffusion_time_reference_s": diffusion_time_reference,
        "fastest_reaction_time_s": fastest_reaction_time,
        "selected_time_reference_s": time_reference,
        "dimensionless_trapping_rate": dimensionless_trapping_rates,
        "dimensionless_release_rate": dimensionless_release_rates,
        "trapping_time_scales_s": trapping_time_scales,
        "release_time_scales_s": release_time_scales,
    }

    print("# val-2f dimensionless reference scales")
    print(json.dumps(payload, indent=2, sort_keys=True))

    out_path = Path("test/tests/val-2f-dimensionless/reference_scales.json")
    out_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="ascii")


if __name__ == "__main__":
    main()
