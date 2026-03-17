# User-Managed Non-Dimensionalization Design

## Problem Statement

The `val-2f` validation case (self-damaged tungsten, 6 trap species) exhibits significant
serial-vs-parallel solution differences. The root cause is poor scaling across the coupled
mobile and trapped-species equations, especially when a single scaling choice is reused for
trap species that live on very different physical concentration ranges.

The earlier design for this effort proposed solver-managed non-dimensionalization: TMAP8
would infer reference quantities, derive dimensionless groups, and solve an internally
non-dimensional system while allowing users to keep writing fully dimensional inputs.

That approach is no longer the target.

## Design Decision

Non-dimensionalization should happen entirely at the user input level.

TMAP8 should not attempt to automatically:
- infer the full set of reference quantities,
- derive dimensionless numbers behind the scenes,
- convert meshes from physical coordinates to dimensionless coordinates,
- create a separate dimensionless `Executioner` or time integrator,
- solve in an internal dimensionless space and then map the solution back for output.

Instead, the user will prepare a self-consistent dimensionless problem definition in the
input file. TMAP8 will then solve that problem as written.

## Why The Design Changed

The original automation concept breaks down once the full problem is considered rather than
just the trapping kernels.

### Mesh coordinates are physical inputs

Length scales enter through the mesh itself. A truly solver-managed dimensionless
formulation would require converting the mesh coordinates from physical units to
non-dimensional coordinates in a consistent and reversible way. That is not a local kernel
change; it is a global transformation of the problem definition.

### Time integration is also physical

The `Executioner`, time stepping controls, end time, postprocessors, and output schedules all
assume physical time units as provided by the user. A fully internal non-dimensional solve
would require a parallel dimensionless time-management layer or equivalent translation at
multiple interfaces.

### Partial automation is inconsistent

Automatically non-dimensionalizing only some equations while leaving the mesh, time
integrator, and other physics in dimensional form produces a mixed formulation. That is
worse than requiring the user to provide a fully dimensionless problem explicitly, because it
hides assumptions and makes the resulting scales difficult to reason about.

### The infrastructure cost is too high

Doing this correctly would likely require new behind-the-scenes representations of:
- the mesh,
- time-related execution objects,
- selected physics objects,
- output transformations back to physical units.

That level of indirection is too invasive for the expected benefit.

## Revised Goal

The goal is now:
- make it straightforward for a user to formulate a dimensionless TMAP8 problem,
- keep the formulation explicit in the input file,
- avoid hidden solver-side transformations,
- preserve consistency across mesh, time, variables, material properties, sources, and
  boundary conditions.

This is a usability and formulation problem, not an internal automation problem.

## Scope

This design is specifically about how TMAP8 should support non-dimensionalization going
forward.

In scope:
- documenting the recommended input-level workflow,
- defining what remains the user's responsibility,
- identifying optional helper tooling that may improve usability,
- aligning future examples and validation cases with the explicit dimensionless workflow.

Out of scope:
- automatic derivation of reference quantities inside C++,
- automatic computation of dimensionless groups inside Physics actions,
- hidden runtime conversion between dimensional user inputs and dimensionless internal
  solves,
- automatic conversion between dimensional and non-dimensional meshes or time domains.

## Core Principle

If a problem is to be solved in dimensionless form, then the entire problem description
should already be dimensionless when it reaches the solver.

This includes the mobile concentration equation as well as the trapped-species equations.
The goal is a fully nondimensional coupled system, not a partially nondimensional trapping
subsystem attached to a dimensional mobile transport equation.

That includes:
- mesh coordinates,
- time domain and timestep controls,
- primary variables,
- coefficients and constitutive parameters,
- source terms,
- initial conditions,
- boundary conditions,
- postprocessing choices.

TMAP8 should read and solve that system directly rather than trying to reinterpret a
physical-unit problem as a dimensionless one internally.

## Implications For TMAP8

### Keep kernel physics explicit

The code should not hide dimensionless-group derivation behind existing dimensional
parameter names in a way that suggests TMAP8 is doing a full automatic conversion. If a
kernel expects a dimensionless coefficient, the input should provide that coefficient
explicitly.

### Avoid mixed dimensional/dimensionless APIs

We should avoid interfaces where the user provides some physical parameters and some
already-nondimensional parameters unless the contract is extremely clear. Mixed modes are
hard to validate and easy to misuse.

### Prefer transparency over convenience

A user-visible dimensionless input file is preferable to a more convenient but partially
opaque automatic workflow. The input file should make the chosen reference scales and
resulting dimensionless groups inspectable.

## Recommended User Workflow

A user who wants a dimensionless solve should:

1. Choose reference quantities outside TMAP8.
2. Non-dimensionalize the governing equations consistently.
3. Convert all geometry, times, variables, and coefficients into that dimensionless system.
4. Build the mesh and execution settings using those dimensionless quantities.
5. Supply only those dimensionless values to the TMAP8 input file.
6. Convert outputs back to physical units externally if needed for interpretation or plots.

This workflow makes the scaling assumptions explicit and keeps the model internally
consistent.

## Reference Quantities Remain User Responsibilities

TMAP8 should not attempt to decide these automatically. Depending on the problem, the user
may need to choose:
- reference length `L_ref`,
- reference time `t_ref`,
- reference mobile concentration `C_m_ref`,
- reference trapped concentration for each trap or a consistent family of concentration
  references,
- reference temperature `T_ref`,
- reference flux, source, or pressure scales as needed by the model.

The appropriate choices are problem-dependent and often depend on the specific operating
regime the user wants to resolve accurately.

## What This Means For Current Trapping Work

The earlier draft assumed that TMAP8 would compute trap-specific concentration references,
mobile concentration references, and Damkohler-like coefficients internally. That is no
longer the plan.

For trapping physics, the revised expectation is:
- if the formulation uses dimensionless trapped and mobile variables, the input file should
  provide the already-dimensionless coefficients needed by the kernels,
- if the formulation stays dimensional, then any scaling support should be treated as
  conventional solver scaling rather than full non-dimensionalization,
- `trap_per_free` should not be presented as part of an automatic nondimensionalization
  strategy.

Dimensionless trapping kernels and Damkohler-number-based formulations can still be useful.
The key constraint is that they should operate on an already-nondimensional problem
definition rather than being used as part of a hidden conversion pipeline from dimensional
inputs.

That requirement applies to the mobile equation too. A valid dimensionless trapping
workflow for TMAP8 is one in which the mobile concentration, trapped concentrations, mesh
coordinates, and time variable are all expressed in the user's chosen reference system.

That means the `val-2f-dimensionless` directory can still serve as the main development and
validation path for this work, provided it is framed as a user-authored dimensionless case
rather than an automatically transformed dimensional one.

In practice, the most useful approach is to let these pieces evolve together:
- develop `val-2f-dimensionless` as the main concrete target,
- add dimensionless kernels where they make that case cleaner or more robust,
- add Python utilities where they reduce the manual burden of preparing the dimensionless
  input.

Those are not competing directions. The example case is the driver, and the kernels and
utilities are supporting mechanisms that exist to make that workflow practical.

Whether `trap_per_free` should eventually be removed, retained, or refactored can be
handled as a separate physics/API question. It is no longer coupled to an automatic
non-dimensionalization design.

## Validation Strategy

The main validation target remains the same: improved numerical robustness, especially for
cases like `val-2f` that currently show serial-vs-parallel sensitivity.

But the mechanism changes.

Instead of testing whether TMAP8 correctly infers scales, we should test whether a fully
user-authored dimensionless formulation:
- reproduces the expected physical behavior once interpreted in the chosen reference system,
- improves conditioning relative to the comparable dimensional formulation,
- reduces serial-vs-parallel divergence.

A useful validation pattern is to maintain paired cases:
- a dimensional reference input,
- a manually nondimensionalized input representing the same physics.

## Possible Helper Tooling

The main place to improve usability is likely outside the core solver.

### Python helper library

A Python utility library is a reasonable companion to the example and kernel work. It could
help users:
- define reference quantities,
- transform dimensional parameters into dimensionless ones,
- convert mesh extents and time horizons,
- emit TMAP8-ready HIT snippets or complete input files,
- convert selected outputs back to physical units for plotting or comparison.

This keeps the solver implementation simple while still reducing user burden, and it gives
us a practical way to support the same workflow that is exercised by
`val-2f-dimensionless`.

### Documentation and examples

We should also provide:
- a worked nondimensionalization example for a trapping problem, with
  `val-2f-dimensionless` as the primary target,
- guidance on choosing reference scales,
- explicit examples showing how mesh length and executioner time settings must also be
  transformed,
- side-by-side dimensional and dimensionless versions of representative validation cases.

### Optional lightweight input helpers

If we want some in-repo convenience without taking on full automation, a limited helper
layer could be considered, but it should remain explicit. For example, a preprocessing step
that writes a final dimensionless input file is acceptable; hidden runtime conversion inside
TMAP8 is not the target.

## Non-Goals

The following are explicitly not part of this design:
- automatic scanning of `Ct0`, ICs, BCs, or material properties to infer scales,
- automatic computation of dimensionless numbers inside `SpeciesTrappingPhysics`,
- automatic nondimensionalization of heat conduction through derived `T_ref`, `L_ref`, or
  `k_ref`,
- runtime creation of alternate meshes or executioners,
- transparent physical-to-dimensionless-to-physical round trips during solve and output.

The non-goal is not "dimensionless kernels" in general. The non-goal is hidden automatic
translation from a dimensional problem statement to those kernels.

## Consequences For The Existing Design Draft

The following parts of the previous proposal should be considered superseded:
- automatic reference quantity derivation,
- automatic Damkohler-number computation,
- solver-side dimensionless kernel integration as a hidden transformation layer for
  dimensional inputs,
- full elimination of user-managed scaling inputs through internal automation,
- heat-equation nondimensionalization derived internally from mesh and initial conditions.

The retained idea is narrower: explicit non-dimensional formulations are still desirable,
and dimensionless kernels may still be part of that implementation, but they should be
driven by user-authored or externally preprocessed dimensionless inputs.

## Proposed Next Steps

1. Update repository documentation to describe input-level nondimensionalization as the
   intended workflow.
2. Reframe any open implementation tasks so they do not assume hidden automatic scale
   derivation.
3. Use `val-2f-dimensionless` as the primary proving ground for the design.
4. Add dimensionless kernels where they directly support that explicit dimensionless
   workflow.
5. Add Python helper utilities where they reduce the manual work needed to prepare and
   interpret those cases.
6. Treat all three efforts as one coordinated path: the example drives requirements, the
   kernels support the solve, and the Python tooling supports the user workflow.

## Bottom Line

Non-dimensionalization is still a good direction for robustness, but TMAP8 should not try
to do it implicitly while the user continues to provide a fully dimensional problem.

If we want a dimensionless solve, the problem definition itself should already be
nondimensional before TMAP8 sees it. Any convenience features should help the user produce
that input, not hide a partial or inconsistent conversion inside the solver.
