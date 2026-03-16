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

Eliminate `trap_per_free` entirely. Stored variables become dimensionless concentrations
`Ĉ_t_i = C_t_i / C_t_ref_i` (O(1) when the trap is near saturation). The kernel
equations are written in terms of Damköhler numbers and dimensionless quantities —
no physical units appear inside the residual computation. The coupling coefficient
`C_t_ref_i / C_m_ref` replaces `trap_per_free` and is derived automatically from
the reference quantities.

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

### Target formulation (dimensionless variables)

| Trap | C_t_ref_i = N · Ct0_ref_i | C_t_ref_i / C_m_ref (coupling coef) |
|------|--------------------------|--------------------------------------|
| 1 (damage) | ~4.8e7 at/μm³ | ~3.7e6 |
| 2 (damage) | ~3.8e7 at/μm³ | ~2.9e6 |
| 3 (damage) | ~2.6e7 at/μm³ | ~2.0e6 |
| 4 (damage) | ~3.6e7 at/μm³ | ~2.8e6 |
| 5 (damage) | ~1.1e7 at/μm³ | ~8.5e5 |
| intrinsic  | ~2.4e4 at/μm³ | ~1.8e3 |

Mobile reference (`C_m_ref` from weakest-trap equilibrium at T = 370 K):

```
C_m_ref  =  (1e13 / 2.2e12) · exp(−(1.04 − 0.28) eV / (8.617e-5 eV/K · 370 K)) · N
         ≈  13 at/μm³
```

Note: `C_m_ref ≈ 13 at/μm³` is derived from trapping equilibrium and is appropriate
for the charging phase. See the discussion in the `mobile_concentration_reference`
derivation section for the limitations of this estimate and the fallback strategies.

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

### Target form — truly dimensionless kernel equations

Define:
- `Ĉ_t_i = C_t_i / C_t_ref_i`     (O(1) stored variable, max ~1 when trap is full)
- `Ĉ_m   = C_m   / C_m_ref`        (O(1) stored variable)
- `t̂    = t     / t_ref`
- `Ŝ_i  = N · Ct0_i / C_t_ref_i`  (dimensionless trap capacity; = 1 when C_t_ref = N·Ct0_max)

Dimensionless Damköhler numbers (computed once at setup from known parameters):
```
Da_t_i  =  α_t_i · t_ref · C_m_ref / N          (trapping Damköhler, ~1 when refs are correct)
Da_r_i  =  α_r_i · t_ref                         (release  Damköhler)
```

Dimensionless trapped-species equation:
```
dĈ_t_i/dt̂  =  Da_t_i · exp(−E_t_i/T) · (Ŝ_i − Ĉ_t_i) · Ĉ_m
             −  Da_r_i · exp(−E_r_i/T) · Ĉ_t_i
```

Dimensionless mobile equation:
```
dĈ_m/dt̂  =  [dimensionless diffusion + source]
           − Σ_i  (C_t_ref_i / C_m_ref) · dĈ_t_i/dt̂
```

The coupling coefficient `C_t_ref_i / C_m_ref` is the **physics-derived, per-species
replacement for `trap_per_free`**. It is not a user input.

**Why this is the right target:**

Every intermediate quantity in the kernel residual computation is dimensionless and O(1)
when references are chosen correctly. The residual itself is O(1) _by construction_ —
no `scaleResidual` call is needed, and the entire `TMAPScaling` /
`TrappingEquationScaling` / `MobileEquationScaling` infrastructure becomes obsolete.
The Jacobian is automatically well-conditioned without any post-hoc row scaling.

The `mobile_concentration_reference` (previously stored but unused in the residual)
becomes a first-class input: it enters both `Da_t_i` and the mobile coupling coefficient.

---

## Fundamental Success Criterion

**Serial and parallel runs must produce identical results** (within floating-point
reordering tolerance) for all TMAP8 validation and verification cases. This is the
primary metric of this design effort. "Poor-man's" row scaling (post-hoc `scaleResidual`
applied to physical-unit residuals) cannot guarantee this because it leaves the Jacobian
condition number sensitive to floating-point evaluation order, which differs between
serial and parallel partitionings.

Only a Jacobian whose entries are O(1) by construction — achieved through genuinely
dimensionless variables and kernel equations — provides the conditioning necessary to
make serial-parallel differences fall below solver tolerance.

---

## Implementation Roadmap

### Backward-compatibility strategy

Existing TMAP8 inputs and tests must not be broken during this feature addition.
The approach is to introduce **new dimensionless kernel classes** that live alongside
the existing dimensional kernels rather than modifying them in place:

- `TrappingNodalKernelDimensionless` alongside `TrappingNodalKernel`
- `ReleasingNodalKernelDimensionless` alongside `ReleasingNodalKernel`
- (existing `ScaledTimeDerivativeNodalKernel` is replaced by plain `TimeDerivativeNodalKernel`
  since a dimensionless stored variable needs no explicit time-derivative scaling)

The new `SpeciesTrappingPhysics` mode selects the dimensionless kernel classes and
computes all Damköhler numbers automatically. Users never specify `Da_t`, `Da_r`,
or any other dimensionless parameter by hand — the Physics action derives them from the
physical parameters already required.

A new test directory `test/tests/val-2f-dimensionless/` demonstrates the full approach:
val-2f physics via `SpeciesTrappingPhysics` in dimensionless mode, SI-unit parameters
only, no scaling hints, serial = parallel.

### Phase 1 — Dimensionless kernel classes and Physics integration

**New kernel classes** (live alongside existing, do not modify existing):

- `TrappingNodalKernelDimensionless`: accepts `Da_t`, `Da_r`, `S_hat`; residual:
  ```cpp
  // u = Ĉ_t (dimensionless trapped, O(1)), v = Ĉ_m (dimensionless mobile, O(1))
  residual = -Da_t * exp(-E_t / T) * (S_hat - u) * v
           +  Da_r * exp(-E_r / T) * u;
  // Residual is O(1) by construction. No scaleResidual.
  ```
- `ReleasingNodalKernelDimensionless`: `Da_r * exp(-E_r / T) * u`.
  (Consider merging into `TrappingNodalKernelDimensionless` — the release term is
  already present there and `ReleasingNodalKernel` would become trivial.)

**`SpeciesTrappingPhysics` automatic reference computation**:

When `automatic_trapping_scaling = true` (the new default), the Physics action
computes all references without user input:

1. **`C_t_ref_i = N · Ct0_ref_i`**: `Ct0_ref_i` obtained by:
   - Parse `Ct0_i` as a `Real` constant. If successful, use directly.
   - Else `dynamic_cast` to `ParsedFunction`; check for `\bt\b` time dependence
     (emit `paramError` if found); evaluate spatial max over mesh nodes at `t = 0`.
   - Emit `paramError` for non-`ParsedFunction` types.

2. **`C_m_ref = max(C_m_BC, C_m_IC, C_m_trap)`**:
   - `C_m_BC`: max Dirichlet BC value for the mobile species (constant or
     `ParsedFunction` spatial max at `t = 0`).
   - `C_m_IC`: IC value or spatial max for the mobile species.
   - `C_m_trap`: `max_i[(α_r_i / α_t_i) · exp(−(E_r_i − E_t_i) / T_ref) · N]`
     from the weakest trap (zero if no traps).
   - Emit `paramError` if all three are zero (source-driven Neumann-only problem
     where the scale must be inferred from the flux — not yet automatic).

3. From the above, compute and pass to dimensionless kernels:
   - `Da_t_i = α_t_i · t_ref · C_m_ref / N`
   - `Da_r_i = α_r_i · t_ref`
   - `S_hat_i = N · Ct0_i / C_t_ref_i`
   - Coupling coefficient for mobile equation: `C_t_ref_i / C_m_ref`
     (passed as `coef` to `CoupledTimeDerivative`)

**`test/tests/val-2f-dimensionless/`**: val-2f physics specified entirely through
`SpeciesTrappingPhysics` with physical SI parameters. No `trap_per_free`,
no `trap_concentration_reference`, no Damköhler numbers in the input file.

**Success criterion**: `val-2f-dimensionless` serial and parallel results match to
within solver tolerance. `show_var_residual_norms = true` shows all 7 variable
residuals O(1).

### Phase 2 — Heat conduction non-dimensionalization

Extend automatic dimensionless treatment to `HeatConductionCG`.

**References** (all derived without user input):
- `T_ref`: initial temperature from the temperature variable's IC or an existing
  `initial_temperature` parameter.
- `L_ref`: characteristic length from the mesh bounding box.
- `k_ref`: thermal conductivity at `T_ref`.

**Dimensionless heat equation**: `T̂ = T / T_ref`, residual O(1) when row-scaled by
`k_ref · T_ref / L_ref²`. The Arrhenius factors in the trapping kernels become
`exp(−E / (T_ref · T̂))` — no change to kernel expressions, only the preconditioner.

### Phase 3 — Migrate existing kernels and delete `TMAPScaling` (long-term)

Once dimensionless kernels are validated and all tests migrated to the Physics layer:

- Deprecate then delete `TrappingNodalKernel`, `ReleasingNodalKernel`,
  `ScaledTimeDerivativeNodalKernel`, `ScaledCoupledTimeDerivative`.
- Delete `include/utils/TMAPScaling.h`, `src/utils/TMAPScaling.C`.
- Remove all `trap_per_free`, `trap_concentration_reference`,
  `mobile_concentration_reference`, `site_density_reference`, `time_reference`,
  `temperature_reference` parameters from all input files.
- `SpeciesTrappingPhysics` becomes the sole supported entry point for trapping physics.

### Phase 4 — Migrate remaining repo to dimensionless Physics layer (long-term)

`val-2f-dimensionless` achieves zero-parameter non-dimensionalization in Phase 1 by
using `SpeciesTrappingPhysics`. Phase 4 extends this to the rest of the repository:
all existing validation, verification, and example cases are migrated to the Physics
layer so that no non-dimensionalization parameters appear anywhere in the codebase.
This is when the old dimensional kernels and `TMAPScaling` infrastructure (Phase 3)
can be safely deleted.

---

## Correctness Guarantees

1. Storing `Ĉ_t_i = C_t_i / C_t_ref_i` and `Ĉ_m = C_m / C_m_ref` is a change of
   internal variable representation only. With consistent initial conditions and
   coupling coefficients (`C_t_ref_i / C_m_ref`), the physical solution is identical
   to the dimensional formulation.
2. MOOSE variable scaling (the preconditioner column scaling) applies only to the
   preconditioner, not the Newton iterate — it cannot corrupt the solution.
3. The reference quantities (`C_t_ref_i`, `C_m_ref`, `T_ref`) are constants computed
   once at setup from physical parameters. They do not vary between Newton iterations,
   ensuring a stable, iteration-independent preconditioner.
4. Because dimensionless residuals are O(1) by construction, the Jacobian condition
   number is independent of the choice of physical units and of parallel partitioning.
   This is the property that guarantees serial = parallel results.

---

## Anti-Patterns to Avoid

- **Do not** compute residuals in physical units and apply `scaleResidual` at the end.
  This is row scaling, not non-dimensionalization. Every intermediate quantity in the
  kernel residual should be dimensionless. When done correctly, `scaleResidual` is
  unnecessary — the residual is O(1) by construction.

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
