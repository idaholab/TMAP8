# Physics-Based Non-Dimensionalization for Trapping Equations

## Problem Statement

The val-2f validation case (self-damaged tungsten, 6 trap species) exhibits significant
serial-vs-parallel solution differences. The root cause is inconsistent equation scaling
across trap species, which produces an ill-conditioned Jacobian whose sensitivity to
floating-point ordering (a function of parallel partitioning) is too high.

The previous approach used a single `trap_per_free = 1e7` to derive all scaling
references, giving every trapped species the same
`trap_concentration_reference = 1/trap_per_free = 1e-7`. This is incorrect because the
six trap species span very different physical concentration ranges.

---

## Long-Term Vision

The ultimate goal is that a user specifies **only the physical parameters** of the
problem (in SI or any consistent unit system) and the solver automatically
non-dimensionalizes the equations to achieve a well-conditioned Jacobian. No scaling
hints, no `trap_per_free`, no `trap_concentration_reference`, no
`mobile_concentration_reference`.

All Physics actions that TMAP8 uses — `SpeciesTrappingPhysics`, `SpeciesDiffusionPhysics`
(mobile), and `HeatConductionCG` — should participate in a coordinated
non-dimensionalization derived entirely from parameters the user already provides.

---

## Automatic Reference Quantity Derivation

### Trapped concentrations

**Reference**: `C_t_ref_i = N · Ct0_ref_i`

`Ct0_ref_i` is the spatial maximum of the `Ct0_i` occupancy-fraction function evaluated
over the mesh at `t = 0`. It is obtained automatically as follows:

1. Attempt to parse the `Ct0_i` parameter string as a `Real` constant. If successful,
   use it directly.
2. Otherwise, `dynamic_cast` the registered MOOSE `Function` to `ParsedFunction`. If
   the cast fails, raise a `paramError`: _"automatic_trapping_scaling with a
   non-ParsedFunction Ct0 is not yet implemented"_.
3. If the cast succeeds, scan the expression string for the token `\bt\b` (word-boundary
   match for `t`). If found, raise a `paramError`: _"Ct0 appears to be time-dependent;
   automatic scaling requires a time-independent Ct0 or an explicit Ct0_reference"_.
4. Evaluate `ct0_func.value(0, node)` at every mesh node and take the maximum.
   This gives `Ct0_ref_i`, and `C_t_ref_i = N · Ct0_ref_i`.

**Survey of existing tests**: every `Ct0` usage in the repository is either a parseable
constant or a spatial-only `ParsedFunction` with no `t` dependence (Fermi-Dirac,
Gaussian, step-function profiles). Steps 2–3 therefore cover 100% of current use cases
with no user intervention.

### Mobile concentration

**Reference**: the maximum of all physical scale estimates available at setup time.
Because mobile concentration physics can exist without traps, and because surface BCs
often directly fix the concentration scale, the reference is:

```
C_m_ref  =  max(C_m_BC, C_m_IC, C_m_trap)
```

where each term is defined below. Any term that cannot be evaluated (e.g., no traps) is
treated as zero and excluded from the maximum.

#### C_m_BC — Dirichlet boundary condition values

If `SpeciesDiffusionPhysics` registers Dirichlet BCs on the mobile species (the common
case for surface-concentration implantation problems), the BC values directly bound `C_m`
at the boundaries. The reference contribution is:

```
C_m_BC  =  max over all Dirichlet BCs { constant value or ParsedFunction max at t=0 }
```

For `FunctionDirichletBC`, evaluate the function at `t = 0` over all boundary nodes
and take the maximum (same approach as for `Ct0` spatial functions above).

#### C_m_IC — Initial condition value

If the IC for the mobile species is non-zero, it gives a direct lower bound:

```
C_m_IC  =  IC constant value, or ParsedFunction spatial max at t=0
```

For most TMAP8 problems the mobile-species IC is 0, so this term is zero.

#### C_m_trap — Trapping equilibrium estimate

When traps are present, the steady-state mobile concentration is bounded by the
McNabb-Foster equilibrium condition. Setting `dC_t_i/dt = 0` at half-occupancy
(`C_t_i = N·Ct0_i/2`) in the target `trap_per_free = 1` formulation gives:

```
C_m_eq_i  =  (α_r_i / α_t_i) · exp(−(E_r_i − E_t_i) / T_ref) · N
```

The maximum across all trap species is driven by the **weakest trap** (smallest
`E_r − E_t`), which constrains the mobile concentration from above during charging:

```
C_m_trap  =  max_i [ (α_r_i / α_t_i) · exp(−(E_r_i − E_t_i) / T_ref) · N ]
```

**Why this is fully automatic**: `α_r_i`, `α_t_i`, `E_r_i`, `E_t_i`, `N`, and the
initial temperature are all required parameters of `SpeciesTrappingPhysics`. No
additional user input is needed for this term.

#### Fallback

If all three sources give zero (zero IC, all-Neumann BCs, no traps), the mobile
concentration reference cannot be inferred from available parameters. In this case the
Physics action emits a `paramError` requesting an explicit `mobile_concentration_reference`.
This situation corresponds to a source-driven (Neumann-only) problem where the flux
magnitude sets the scale; an automatic estimate would require knowledge of the source
term and diffusion time, which are problem-specific.

**Robustness note**: references are computed once at setup using `T_ref = T_initial` and
`t = 0` for all function evaluations. They are static preconditioner constants and do not
change between Newton iterations. During desorption heating, the actual mobile
concentration may rise above `C_m_ref` as traps empty, but static references that are
appropriate for the charging phase (where trapping–mobile coupling is numerically
dominant) provide good overall conditioning.

### Temperature (heat conduction)

**Reference**: `T_ref = T_initial` (the initial temperature, already required in the
problem setup).

For the heat equation:

```
ρ Cp dT/dt = ∇·(k ∇T) + Q
```

the natural non-dimensionalization divides the equation by `k · T_ref / L_ref²`, where
`L_ref` is a characteristic length. Both `T_ref` and `L_ref` are derivable without user
input:

- `T_ref`: taken from the initial condition of the temperature variable. For TMAP8
  problems this is always a named constant (e.g., `temperature_initial`). The Physics
  action can query the temperature variable's IC via `ParsedFunction` evaluation or
  simply accept the initial temperature as its existing required parameter.
- `L_ref`: derived from the mesh bounding box (available via `mesh().getInflatedProcessorBoundingBox()`
  or `mesh().dimensionWidth()`). For 1D problems this is the domain length.

**Row scale for the heat equation**:

```
heat_residual_reference  =  k_ref · T_ref / L_ref²
```

where `k_ref` is the thermal conductivity (already a parameter of `HeatConductionCG`
or derivable from a material property at `T_ref`).

**Variable scale for temperature**:

```
temperature_scaling  =  1 / T_ref
```

This normalizes the temperature variable to O(1) (e.g., 370 K → ~1 in natural units).

**Coupling to trapping**: when heat conduction and species trapping are coupled (as in
val-2f where temperature drives Arrhenius rates), the two non-dimensionalizations must
be consistent. The Arrhenius factors `exp(-E/T)` involve `T` directly; after scaling
`T → T / T_ref`, these become `exp(-E / (T_ref · T̂))`. No change to the kernel
expressions is needed — the scaling only appears in the preconditioner, not the computed
residual.

---

## Why `trap_per_free` Must Be Eliminated from Kernel Physics

`trap_per_free` currently serves two conflated roles that must be separated:

### Role 1 (physics): Variable normalization

`TrappingNodalKernel` is written in terms of a **normalized** stored variable
`u = C_t_physical / trap_per_free`. The kernel equations are:

```
empty_sites  =  N·Ct0 − Σ u_j · trap_per_free
residual     =  −α_t · exp(−E_t/T) · empty_sites · C_m / (N · trap_per_free)
```

And the mobile coupling uses `coef = trap_per_free` to recover `d(C_t_physical)/dt`
from `d(u)/dt`.

This normalization was introduced to keep the stored variable numerically small, but it
means the user must choose `trap_per_free` to match the expected concentration ratio —
which requires physics intuition and varies per trap species. When a single value is used
for all trap species, the normalization is wrong for any trap whose density differs
significantly from the implicit assumption.

### Role 2 (scaling): Scaling reference proxy

`trap_concentration_reference = 1/trap_per_free` was used as the equation-scaling
reference. This is the wrong formula — the correct per-species reference is
`N · Ct0_ref_i` (target formulation), and it must be per-species.

### Resolution

Set `trap_per_free = 1` in the kernel physics (i.e., store `C_t` in physical units).
The equations become exactly the standard McNabb-Foster form. Non-dimensionalization is
handled entirely by the scaling infrastructure using `C_t_ref_i = N · Ct0_ref_i`, which
the Physics action computes automatically from existing parameters.

This is **not** a change to the physical model — it is a change in the choice of
internal variable representation. The physical solution is identical.

---

## Physical Scales in val-2f

### Current formulation (with `trap_per_free = 1e7`)

| Trap | Ct0 reference | max stored concentration |
|------|--------------|-------------------------|
| 1 (damage) | ~7.6e-4 (sat.) | ~4.8 at/μm³ |
| 2 (damage) | ~6.0e-4 (sat.) | ~3.8 at/μm³ |
| 3 (damage) | ~4.1e-4 (sat.) | ~2.6 at/μm³ |
| 4 (damage) | ~5.7e-4 (sat.) | ~3.6 at/μm³ |
| 5 (damage) | ~1.7e-4 (sat.) | ~1.1 at/μm³ |
| intrinsic  | 3.8e-7 (const) | **~2.4e-3 at/μm³** |

The intrinsic trap operates ~1000–2000× lower than the damage traps. Using
`1/trap_per_free = 1e-7` uniformly leaves the intrinsic-trap rows ~1000× less
well-conditioned.

### Target formulation (with `trap_per_free = 1`, physical units)

| Trap | C_t_ref_i = N · Ct0_ref_i |
|------|--------------------------|
| 1 (damage) | ~4.8e7 at/μm³ |
| 2 (damage) | ~3.8e7 at/μm³ |
| 3 (damage) | ~2.6e7 at/μm³ |
| 4 (damage) | ~3.6e7 at/μm³ |
| 5 (damage) | ~1.1e7 at/μm³ |
| intrinsic  | ~2.4e4 at/μm³ |

Mobile reference (weakest trap = intrinsic at T = 370 K):

```
C_m_ref  =  (1e13 / 2.2e12) · exp(−(1.04 − 0.28) eV / (8.617e-5 eV/K · 370 K)) · N
         ≈  4.5 · exp(−23.8) · 6.3e10  ≈  13 at/μm³
```

---

## Governing Equations

### Current form (with `trap_per_free`)

```
du_i/dt =   α_t_i · exp(−E_t_i/T) · (N·Ct0_i − Σ_j u_j · trap_per_free) · C_m
          / (N · trap_per_free)
          − α_r_i · exp(−E_r_i/T) · u_i

dC_m/dt = [diffusion + source] − Σ_i trap_per_free · du_i/dt
```

where `u_i = C_t_i / trap_per_free`.

### Target form (`trap_per_free = 1`, physical units)

```
dC_t_i/dt =   α_t_i · exp(−E_t_i/T) · (N·Ct0_i − Σ_j C_t_j) · C_m / N
            − α_r_i · exp(−E_r_i/T) · C_t_i

dC_m/dt = [diffusion + source] − Σ_i dC_t_i/dt
```

Standard McNabb-Foster form. No free scaling parameters.

---

## Implementation Roadmap

### Phase 1 — Val-2f explicit-input fix (complete)

Per-trap `trap_concentration_reference_i` computed in `parameters_val-2f.params` as:

```
trap_concentration_reference_i  =  trap_density_i_sat / trap_per_free_i
                                 =  N · Ct0_ref_i / trap_per_free_i
```

This is behavior-preserving (kernel physics unchanged), corrects the intrinsic-trap
mis-scaling, and requires no kernel or Physics action code changes.

**Success criterion**: serial-parallel differences for the intrinsic trap decrease to
be comparable with damage traps. All 7 variable residual norms within an order of
magnitude (`show_var_residual_norms = true` in `[Debug]`).

### Phase 2 — Per-species automatic scaling in `SpeciesTrappingPhysics` (near-term)

Make `SpeciesTrappingPhysics` compute all scaling references automatically when
`automatic_trapping_scaling = true`, with no user specification of scaling parameters.

**Changes to `SpeciesTrappingPhysics`**:

1. Add `Ct0_reference` as an optional `vector<Real>` parameter (one per species). If
   not provided, auto-compute from the registered `Ct0` function during `addFEKernels`:
   - Parse as constant if possible.
   - Else `dynamic_cast` to `ParsedFunction`, check for `\bt\b` time dependence,
     then evaluate spatial max over mesh nodes at `t = 0`.
   - Emit `paramError` for non-ParsedFunction or time-dependent cases.
2. Change `trappedConcentrationReference(c_i)` → `trappedConcentrationReference(c_i, s_j)`
   returning `N[c_i] * Ct0_ref[c_i][s_j] / trap_per_free[c_i]`.
   Update all call sites in `addFEKernels` and `addSolverVariables`.
3. Add `mobileConcentrationReference(c_i)` computed as:
   ```
   C_m_ref = max(C_m_BC, C_m_IC, C_m_trap)
   ```
   - `C_m_BC`: maximum Dirichlet BC value for the mobile species (constant or
     ParsedFunction spatial max at `t=0`); provided by coordination with
     `SpeciesDiffusionPhysics` or by querying the registered BCs for the mobile variable.
   - `C_m_IC`: IC value/spatial max for the mobile species.
   - `C_m_trap`: `max_j[(α_r_j/α_t_j) · exp(−(E_r_j − E_t_j)/T_ref) · N]` from the
     weakest trap's equilibrium condition (zero if no traps).
   - Emit `paramError` if all three are zero, requesting explicit
     `mobile_concentration_reference`.
4. Pass `C_m_ref` as `primary_concentration_reference` to
   `ScaledCoupledTimeDerivative`, replacing the hardcoded `1`.

**Result**: `automatic_trapping_scaling = true` fully determines all scaling from
existing physics parameters. No `trap_concentration_reference`,
`mobile_concentration_reference`, or `site_density_reference` parameters required in
the input file.

### Phase 3 — Eliminate `trap_per_free` from kernel physics (medium-term)

Refactor trapping kernels to the standard McNabb-Foster form (`trap_per_free = 1`).
Stored variables become physical concentrations.

**Changes**:

- `TrappingNodalKernel`: remove `trap_per_free` from `empty_sites` and residual.
  New formula:
  ```
  empty_sites  =  N·Ct0 − Σ C_t_j
  residual     =  −α_t · exp(−E_t/T) · empty_sites · C_m / N
  ```
- `ADScaledCoefCoupledTimeDerivative` / `ScaledCoupledTimeDerivative`: drop `coef`
  (fixed at 1). Coupling is 1-to-1 in physical units.
- `SpeciesTrappingPhysics`: remove `trap_per_free` from `addFEKernels`. Compute
  `C_t_ref_i = N · Ct0_ref_i` directly (no division by `trap_per_free`). Update
  `variableScalingFromReference` accordingly.
- Deprecation warning in `TrappingNodalKernel::validParams` if `trap_per_free != 1`.

**Migration**: existing input files with explicit `trap_per_free != 1` must update
initial conditions and coupling coefficients. Provide a migration guide.

### Phase 4 — Heat conduction non-dimensionalization (medium-term)

Extend automatic scaling to `HeatConductionCG` (or the equivalent TMAP8 heat physics).

**References**:
- `T_ref`: initial temperature, parsed from the temperature variable's initial condition
  or taken from an existing `initial_temperature` parameter.
- `L_ref`: characteristic length from the mesh bounding box (1D domain length,
  or smallest dimension for 2D/3D).
- `k_ref`: thermal conductivity evaluated at `T_ref` (available from the material
  property at setup time if it is a constant or a ParsedFunction of T).

**Row scale**:
```
heat_residual_reference  =  k_ref · T_ref / L_ref²
```

**Variable scale**: `1 / T_ref`

**Coupling with trapping**: Arrhenius factors `exp(−E/T)` couple temperature to
trapping rates. After scaling `T → T/T_ref`, these become `exp(−E / (T_ref · T̂))`.
The kernel expressions are unchanged; only the preconditioner sees the scaled system.
No cross-physics scaling coordination is needed in the kernels themselves.

### Phase 5 — Fully automatic, zero-parameter scaling (long-term)

All Physics actions query the information they need from already-registered objects:
- Temperature IC queried from the `FEProblemBase` IC warehouse.
- Domain length queried from the mesh.
- Material properties evaluated at reference conditions.

No scaling-related parameters appear anywhere in user input files. The trapping,
diffusion, and heat conduction physics collectively produce a well-conditioned Jacobian
from physical parameters alone.

---

## Correctness Guarantees

1. `scaleResidual(F) = F / residualReference` divides every residual term and every
   Jacobian entry in that row by the same constant. Row-scaling does not change the
   solution of the nonlinear system.
2. MOOSE variable scaling applies only to the preconditioner, not the Newton iterate.
3. Setting `trap_per_free = 1` (Phase 3) is a change of internal variable
   representation. With consistent initial conditions and coupling coefficients, the
   physical solution is identical.
4. The automatic references (`C_t_ref_i`, `C_m_ref`, `T_ref`) are constants computed
   once at setup. They do not vary between Newton iterations, ensuring a stable
   preconditioner.

---

## Anti-Patterns to Avoid

- **Do not** use MOOSE's `automatic_scaling = true` as a substitute. That heuristic
  ignores physics, varies between Newton iterations, and produces an inconsistent
  preconditioner. Static, physics-based references are superior.

- **Do not** use a single `trap_concentration_reference` for all trap species unless
  their trap densities are within an order of magnitude.

- **Do not** derive references from the instantaneous solution value. This changes
  every nonlinear iteration and is numerically unstable.

- **Do not** change `trap_per_free` in Phases 1 or 2 to fix scaling — it still appears
  in kernel physics and changing it changes the solution. Only in Phase 3, after kernels
  are refactored to standard McNabb-Foster form, can it be cleanly removed.

- **Do not** conflate equation (row) scaling with variable (column) scaling. Both must
  be set consistently: `variable_scaling = 1 / C_t_ref_i` and
  `residualReference = C_t_ref_i / t_ref`.
