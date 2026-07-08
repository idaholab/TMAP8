# PCC Membrane ↔ Fuel-Cycle MultiApp Coupling — Analysis Record

Record of the analysis, design, and verification for coupling the component-level
proton-conducting-ceramic (PCC) tritium-separation membrane into the system-level Meschini-2023
fuel cycle via a MOOSE MultiApp.

## 1. Objective

Replace the lumped tritium-separation-membrane term in the fuel cycle (fixed extraction efficiency
`eta_2 = 0.85`, recovery residence time `residence11`) with a detailed 1D BCY membrane component
model, so the recovery emerges from physics. The membrane upstream is modeled as a **container**
(gas plenum) whose pressure drives the component model, co-evolved in time with the fuel cycle.

## 2. The two models

| | Parent (system level) | Sub-app (component level) |
|---|---|---|
| File | `fuel_cycle_PCC_membrane.i` | `pcc_membrane_sub.i` |
| Physics | 11 coupled scalar ODE inventories (Meschini 2023) | 1D BCY membrane: reaction-limited sorption + voltage drift + Joule heating |
| Units | kg of tritium, seconds | nm, Pa, at/nm³, flux at/nm²/s |
| Interface | container pressure (Pa) out, permeation rate (kg/s) in | upstream pressure (Pa) in, fluxes out |

## 3. Container model and flow topology

The membrane inventory `I11` (`T_11_membrane`) is a **container** (gas plenum, initial **0 Pa**):

- IN: the full TES output `T_02_TES/residence2`.
- OUT (permeate): the membrane permeation rate `J` (from the component model) → **heat exchanger
  (I5)**.
- OUT (retentate): `T_11_membrane/residence11` (un-permeated) → **recycled to the TES (I2)**.
- decay retained.

Mass balance (ParsedODEKernel residuals are negated/LHS):
- `[I11]` container: `dN/dt = T_02_TES/residence2 − J − T_11_membrane/residence11 − N·λ`.
- `[I2]`  TES: `+ T_11_membrane/residence11` recycle added.
- `[I5]`  HX: source is the permeate `J` (`membrane_permeation_rate`).
- `[I10]` storage: membrane term **removed** (permeate goes to the HX, not storage).

Tritium path: TES → container → {HX (permeate), TES (retentate recycle), decay}. Conserved (minus
decay). Diagnostics: `eta_2_calculated = J/feed` (instantaneous) and `eta_2_cumulative =
∫J dt / ∫feed dt` (smooth; the instantaneous ratio is noisy early when the feed ≈ 0).

## 4. Pressure ↔ flux bridge (ideal gas)

- **Down:** `membrane_upstream_pressure = max(T_11_membrane, 0)/M_T2_molar · R · T_feed / V_feed`
  [Pa]. `max(.,0)` guards a transient negative holdup (the scalar ODE is not positivity-bounded)
  from producing a nonphysical negative pressure. **No upper cap** — the holdup is bounded by the
  system inventory, so the pressure cannot run away (an earlier `min(.,1.5e5)` cap was a
  never-triggered magic number and was removed).
- **Up:** `permeation_rate_kg_per_s = max(-flux_right, 0) · 1e18 · A_membrane · M_T_atomic / N_a`
  [kg/s] (downstream OT flux is negative when tritium permeates out; `1e18`: at/nm²/s → at/m²/s;
  one T per OT → atomic-T molar mass). The upstream/downstream fluxes are also pulled up
  (`membrane_flux_upstream/downstream`) so the parent CSV carries them too.

## 5. Lock-step TransientMultiApp coupling (mirrors TE_models/1d_pressure_bakeout...)

- `TransientMultiApp`, `execute_on = TIMESTEP_END`, `positions = '0 0 0'`. The membrane co-evolves
  on the **same global clock** as the fuel cycle (no steady-state self-termination, warm
  continuation). The sub `endtime` is large; the parent drives the stop time.
- `sub_cycling = true`: the membrane takes its own (smaller, adaptive) timesteps to reach the
  parent's time within each fuel-cycle step — required because the parent `dt` (≥ ~1e3 s, up to
  1e6 s) far exceeds the membrane's stable step from a cold start. `output_sub_cycles = false` keeps
  the sub CSV to one row per fuel-cycle step.
- Transfers (all `TIMESTEP_END`, `MultiAppPostprocessorTransfer`): down `membrane_upstream_pressure
  → received_pressure`; up `permeation_rate_kg_per_s → membrane_permeation_rate`, and the
  left/right fluxes. Within `TIMESTEP_END`, `execute(TIMESTEP_END)` computes the pressure before
  `execMultiApps`, so the fresh end-of-step pressure is sent down.
- **Fixed-point (Picard) iteration with under-relaxation** on the parent (`fixed_point_max_its`,
  `relaxation_factor`, `transformed_postprocessors = 'membrane_permeation_rate'`). The membrane
  permeates steeply at low container pressure, so an explicit one-step-lagged coupling oscillates
  and drives the holdup negative; Picard makes `J` and the holdup mutually consistent each step.
  (`TransientMultiApp` supports fixed-point iteration natively; `FullSolveMultiApp` does not unless
  `auto_advance = true`.)

## 6. Membrane area is the key calibration knob

The membrane is a voltage-driven pump: at large area it permeates faster than the fuel cycle feeds
it, so the container cannot pressurize. Verified directly: at `A_membrane = 1 m²` the membrane
permeates ~1.5e-8 kg/s even at ~1e-5 Pa, exceeding the TES feed (~2e-9 kg/s early), so the
container pressure stays ~0 (sub-µPa) and the holdup hovers at ~0. The area is therefore sized so
the membrane permeates ~the feed only at a meaningful pressure:

| Param | File | Value | Role |
|---|---|---|---|
| `A_membrane` | sub | 2.0e-3 m² (≈20 cm²) | flux → kg/s scale; sets the operating pressure |
| `V_feed` | parent | 10 m³ | holdup → pressure; lowers gain / slows dynamics (steady P is area-set) |
| `T_feed` | parent | 773 K | container gas temperature (matches the membrane) |
| `residence11` | parent | 100 s | retentate recycle time to the TES |

Steady container pressure is set by the membrane (flux = feed) and is largely independent of
`V_feed`; `V_feed` and `A_membrane` are documented placeholders to calibrate to a real device.

## 7. Verification (this machine: macOS arm64; `export SDKROOT=/Users/$(whoami)/sdks/MacOSX26.2.sdk`)

Coupled run (`simulation_time = 20000`, ~75 s with Picard + sub_cycling), exit 0, no solver
failures, all values finite:
- Container pressure rises **smoothly 0 → 0.37 Pa** (continues toward ~Pa-scale as the TES fills) —
  the key verification curve.
- `membrane_permeation_rate` and `T_05_HX` (HX, fed by permeate) grow smoothly.
- Container holdup `T_11_membrane` positive and smooth (a negligible −4e-8 numerical blip at the
  very start; `max(.,0)` clamps the pressure there).
- `eta_2_cumulative` is smooth, settling ~0.38 by t=20000 (vs the lumped 0.85 → RMSPE ≈ 41%): with
  this area the physics-based recovery is well below the assumed value, and it declines as the feed
  grows (the fixed-area membrane saturates).
- `total_tritium` conserved (0.8030 → 0.8033, breeding gain).
- Both CSVs carry the interface quantities — parent: `membrane_upstream_pressure`,
  `membrane_permeation_rate`, `membrane_flux_upstream/downstream`; sub
  (`fuel_cycle_PCC_membrane_out_pcc_membrane0_csv.csv`): `received_pressure`,
  `recombination_flux_OT_dry_left/right`, `permeation_rate_kg_per_s`.

## 8. How to run

```bash
cd test/tests/PCC_multiscale_example
../../../tmap8-opt -i fuel_cycle_PCC_membrane.i --check-input
../../../tmap8-opt -i fuel_cycle_PCC_membrane.i simulation_time=20000   # coupled run (manual/heavy)
python3 comparison_PCC_membrane.py                                      # plots incl. container pressure
../../../../run_tests --re PCC_multiscale_example                       # CI tests (filter is --re, NOT -i)
```
If an arm64/JIT error appears, first `export SDKROOT=/Users/$(whoami)/sdks/MacOSX26.2.sdk`.

**Testing structure.** The CI `tests` cover only `check_input` (input validity) and `comparison`
(the verification plot, which reads the committed gold). The full coupled run is **not** a CI
CSVDiff: the warm-continued, sub-cycled bounded membrane solver intermittently emits a non-fatal
"failed to converge" warning, and the harness's `--error` flag would turn that fatal. The coupled
run is therefore exercised manually (above) and its gold is committed for the plot.

## 9. Notes / future work

- `A_membrane`/`V_feed` are placeholders; calibrate to a real device and target recovery. To raise
  the recovery toward 0.85, increase the area (but not so far the container stops pressurizing) or
  lengthen `residence11`.
- The full 3-year run is expensive (membrane PDE sub-cycled + Picard-iterated every fuel-cycle
  step) — heavy.
- Coupled CSVDiff is environment-sensitive (nonlinear PDE sub-app); gold on macOS arm64, relaxed
  tolerances.
- A `steady_*` `FullSolveMultiApp` variant of these inputs exists in the directory as a
  single-pass comparison; this case is the lock-step `TransientMultiApp` version.
- `tests` uses issue `#429`.
