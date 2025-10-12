# TMAP8 Verification: Tritium Permeation and Trapping

!style halign=center fontsize=120%
From Simple Diffusion to Complex Multi-trap Systems

!---

# Overview: Verification Cases for Permeation

- Progressive complexity in tritium transport modeling

  - +ver-1dd+: Pure diffusion without trapping
  - +ver-1d+: Diffusion with single trap type
  - +ver-1dc+: Diffusion with multiple trap types

- Based on established benchmarks from literature

  - Longhurst (1992, 2005)
  - Ambrosek (2008)
  - Simon (2025)

- Demonstrates TMAP8's capability to handle increasingly complex physics

!---

# Physical Problem: Permeation Through a Membrane

!row!
!col! width=50%

## Configuration

- 1D slab geometry
- Constant source at upstream side (x = 0)
- Permeation flux measured at downstream side
- Breakthrough time characterizes transport

!col-end!

!col! width=50%

## Key Parameters

- Diffusivity: D = 1 m²/s
- Temperature: T = 1000 K
- Upstream concentration: C₀ = 0.0001 atom fraction
- Slab thickness: l = 1 m

!col-end!
!row-end!

!---

# Understanding MOOSE Input File Structure

## Basic Anatomy of a TMAP8 Input File

```
[Section]
  [subsection]
    parameter1 = value1
    parameter2 = value2
  []
[]
```

## Key Sections We'll Explore

- `[Mesh]` - Define geometry
- `[Variables]` - Declare unknowns to solve for
- `[Kernels]` - Physics equations
- `[BCs]` - Boundary conditions
- `[Executioner]` - Solution method
- `[Outputs]` - Results to save

!---

# Case 1: Pure Diffusion (ver-1dd)

## Governing Equation

\begin{equation}
\frac{\partial C_M}{\partial t} = \nabla \cdot (D \nabla C_M)
\end{equation}

- Simplest case: Fickian diffusion only
- No trapping mechanisms
- Baseline for comparison with trap-inclusive models
- Analytical solution available for verification

!---

# Case 1: Input File Structure - Mesh and Variables

```
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 200
  xmax = 1  # 1 meter slab
[]

[Variables]
  [u]  # Mobile concentration
    initial_condition = 0
  []
[]
```

## Key Points

- 1D mesh with 200 elements
- Single variable `u` for mobile concentration
- Starts with zero initial concentration

!---

# Case 1: Input File Structure - Physics

```
[Kernels]
  [diff]
    type = Diffusion
    variable = u
    diffusivity = 1  # D = 1 m²/s
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]
```

## Physics Implementation

- `Diffusion` kernel: ∇·(D∇u)
- `TimeDerivative` kernel: ∂u/∂t
- Together they form the diffusion equation

!---

# Case 1: Input File Structure - Boundary Conditions

```
[BCs]
  [left]  # Upstream side
    type = DirichletBC
    variable = u
    boundary = left
    value = 1  # Normalized concentration
  []
  [right]  # Downstream side
    type = DirichletBC
    variable = u
    boundary = right
    value = 0  # Initially no concentration
  []
[]
```

## Boundary Setup

- Constant source at left (upstream)
- Zero concentration at right (downstream)

!---

# Case 1: Verification Results

!media comparison_ver-1dd.py
       image_name=ver-1dd_comparison_diffusion.png
       style=width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto
       caption=Pure diffusion case: TMAP8 matches analytical solution with RMSPE = 0.14%

- Breakthrough time: τ_b = 0.05 s (both analytical and TMAP8)
- Excellent agreement throughout transient

!---

# Case 2: Single Trap Type (ver-1d)

## Coupled Equations

Mobile species:
\begin{equation}
\frac{\partial C_M}{\partial t} = \nabla \cdot (D \nabla C_M) - \text{trap\_per\_free} \cdot \frac{\partial C_T}{\partial t}
\end{equation}

Trapped species:
\begin{equation}
\frac{\partial C_T}{\partial t} = \alpha_t \frac{C_T^{empty} C_M}{N \cdot \text{trap\_per\_free}} - \alpha_r C_T
\end{equation}

!---

# Case 2: Input File - Variables for Trapping

```
[Variables]
  [mobile]
    initial_condition = 0
  []
[]

[AuxVariables]
  [trapped_c]
    family = SCALAR
    order = FIRST
    initial_condition = 0
  []
  [trapped_c_node]  # For visualization
    order = FIRST
    family = LAGRANGE
  []
[]
```

## Two-Species System

- Primary variable: `mobile` concentration
- Auxiliary scalar variable: `trapped_c` for ODE
- Nodal auxiliary: `trapped_c_node` for plotting

!---

# Case 2: Input File - Trapping Physics

```
[ScalarKernels]
  [scalar_time_deriv]
    type = ODETimeDerivative
    variable = trapped_c
  []
  [scalar_trapping_equilibrium]
    type = ScalarTrappingEquilibriumEquation
    variable = trapped_c
    v = mobile_node
    n_traps = 0.1  # 10% trap sites
    vi = 1.3e13     # Debye frequency
    alphar = 1e13
    trap_per_free = 100000
    n_sol = 5e28    # Host density
    temperature = 1000
    trap_energy_depth = ${trap_depth}
  []
[]
```

!---

# Case 2: Input File - Coupling Mobile and Trapped

```
[Kernels]
  [time_deriv]
    type = TimeDerivativeTrapping
    variable = mobile
    property = trap_per_free
    prop_values = '100000'
    aux_variables = 'trapped_c_node'
    aux_var_derivatives = 'trapped_deriv'
    aux_coupled_var_derivs = true
  []
[]

[UserObjects]
  [trapped_c_node_uo]
    type = ProjectionAux
    variable = trapped_c_node
    v = trapped_c
    execute_on = 'TIMESTEP_BEGIN LINEAR'
  []
[]
```

!---

# Case 2: Trapping Parameter Study

## Key Discriminant

\begin{equation}
\zeta = \frac{\lambda^2 \nu}{\rho D_0} \exp \left( \frac{E_d - \epsilon}{kT} \right) + \frac{c}{\rho}
\end{equation}

!row!
!col! width=50%

### Effective Diffusivity Regime
- When ζ >> c/ρ
- Set: `trap_energy_depth = 100`
- ζ = 91.47 c/ρ

!col-end!

!col! width=50%

### Deep Trapping Regime

- When ζ ≈ c/ρ
- Set: `trap_energy_depth = 10000`
- ζ = 1.00454 c/ρ

!col-end!
!row-end!

!---

# Case 2: Diffusion-Limited Results

!media comparison_ver-1d.py
       image_name=ver-1d_comparison_diffusion.png
       style=width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto
       caption=Effective diffusivity regime: Gradual breakthrough with RMSPE = 0.96%

- Trapping slows but doesn't stop diffusion
- Smooth permeation curve

!---

# Case 2: Trap-Limited Results

!media comparison_ver-1d.py
       image_name=ver-1d_comparison_trapping.png
       style=width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto
       caption=Deep trapping regime: Sharp breakthrough after trap saturation

- Must fill traps before significant permeation
- Sharp transition at breakthrough

!---

# Case 2: Numerical Considerations

## Input File Settings for Stability

```
[Executioner]
  type = Transient
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       NONZERO'

  # Adaptive time stepping
  dt = 1e-6  # Start very small
  adapt_type = IterationAdaptiveTS
  optimal_iterations = 3
  growth_factor = 1.2

  end_time = 2000
[]
```

## Ramped Boundary Condition

```
[Functions]
  [ramp]
    type = ParsedFunction
    expression = 'tanh(3*t)'  # Smooth ramp-up
  []
[]
```

!---

# Case 3: Multiple Trap Types (ver-1dc)

## Extended System of Equations

Mobile species with three trap interactions:
\begin{equation}
\frac{\partial C_M}{\partial t} = \nabla \cdot (D \nabla C_M) - \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t}
\end{equation}

Each trap evolves independently (i = 1, 2, 3)

!---

# Case 3: Base Input File Strategy

```
# ver-1dc_base.i - Shared components
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  xmax = 1
[]

[Variables]
  [mobile]
    initial_condition = 0
  []
[]
```

```
# ver-1dc.i - Specific case
[GlobalParams]
  !include ver-1dc_base.i
[]

[ScalarKernels]
  # Add three trap definitions
[]
```

## Modular Design

- Base file contains common elements
- Case-specific files add unique physics
- Reduces redundancy and errors

!---

# Case 3: Defining Multiple Traps

```
[AuxVariables]
  [trapped_1]
    family = SCALAR
    order = FIRST
    initial_condition = 0
  []
  [trapped_2]
    family = SCALAR
    order = FIRST
    initial_condition = 0
  []
  [trapped_3]
    family = SCALAR
    order = FIRST
    initial_condition = 0
  []
[]
```

## Each Trap Gets:

- Its own scalar variable
- Independent evolution equation
- Unique parameters (site fraction, energy)

!---

# Case 3: Three Trap Parameters

```
[ScalarKernels]
  [trap_1]
    type = ScalarTrappingEquilibriumEquation
    variable = trapped_1
    n_traps = 0.1     # 10% sites
    trap_energy_depth = 100  # ε/k = 100 K
    # ... other parameters
  []

  [trap_2]
    # ... similar with
    n_traps = 0.15    # 15% sites
    trap_energy_depth = 500  # ε/k = 500 K
  []

  [trap_3]
    # ... similar with
    n_traps = 0.20    # 20% sites
    trap_energy_depth = 800  # ε/k = 800 K
  []
[]
```

!---

# Case 3: Coupling All Traps to Mobile Species

```
[Kernels]
  [time_deriv_trapping]
    type = TimeDerivativeTrapping
    variable = mobile
    property = trap_per_free
    prop_values = '100000 100000 100000'  # Three values
    aux_variables = 'trapped_1_node trapped_2_node trapped_3_node'
    aux_var_derivatives = 'trap_1_deriv trap_2_deriv trap_3_deriv'
    aux_coupled_var_derivs = true
  []
[]
```

## Key Insight

- Single kernel handles multiple traps
- Lists of auxiliary variables and derivatives
- Automatic summation: Σ(∂C_Ti/∂t)

!---

# Case 3: Verification Results

!media comparison_ver-1dc.py
       image_name=ver-1dc_comparison_diffusion.png
       style=width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto
       caption=Multiple traps: TMAP8 matches theory with RMSPE = 0.41%

- Breakthrough time: 4.04 s (analytical) vs 4.12 s (TMAP8)
- Combined effect of all three traps

!---

# Case 3: MMS Verification Approach

## Input File for MMS

```
[Functions]
  [exact_u]
    type = ParsedFunction
    expression = 'cos(x)*t'  # Manufactured solution
  []
  [forcing_u]
    type = ParsedFunction
    expression = 'cos(x) + D*t*cos(x) + trap_contributions'
  []
[]

[Kernels]
  [mms_source]
    type = BodyForce
    variable = mobile
    function = forcing_u
  []
[]
```

!---

# Case 3: MMS Spatial Convergence

!media spatial_mms.py
       image_name=ver-1dc-mms-spatial.png
       style=width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto
       caption=Spatial convergence study shows expected quadratic convergence of L₂ error

- 10 levels of mesh refinement
- Confirms proper implementation
- Quadratic convergence as expected

!---

# Running Your First TMAP8 Verification Case

## Step-by-Step Process

1. +Navigate to TMAP8 directory+

   ```bash
   cd ~/projects/TMAP8
   ```

2. +Run the simple diffusion case+

   ```bash
   ./tmap8-opt -i test/tests/ver-1dd/ver-1dd.i
   ```

3. +Examine the output+

   ```bash
   peacock -i test/tests/ver-1dd/ver-1dd.i
   ```

## What to Look For

- Convergence messages in terminal
- Exodus output files (.e extension)
- CSV files with flux data

!---

# Modifying Input Files - Exercise

## Try These Changes to ver-1dd.i:

1. +Change mesh resolution+

   ```
   [Mesh]
     nx = 400  # Was 200
   []
   ```

2. +Adjust time stepping+

   ```
   [Executioner]
     dt = 0.0001  # Smaller initial step
   []
   ```

3. +Modified diffusivity+

   ```
   [Kernels]
     [diff]
       diffusivity = 0.5  # Slower diffusion
     []
   []
   ```

!---

# Visualization with Peacock

## MOOSE's GUI for Results

```bash
peacock -i ver-1d-diffusion.i
```

## Features to Explore

- Time slider for transient results
- Line plots along boundaries
- Flux calculations at surfaces
- Comparison with CSV data

## Export Options

- Images for reports
- Data for external analysis
- Animation of transients

!---

# Common Input File Patterns

!row!
!col! width=50%

## Time-Dependent BCs

```
[Functions]
  [time_bc]
    type = ParsedFunction
    expression = '1-exp(-t)'
  []
[]

[BCs]
  [left]
    type = FunctionDirichletBC
    function = time_bc
  []
[]
```

!col-end!

!col! width=50%

## Postprocessors for Flux

```
[Postprocessors]
  [flux_right]
    type = SideDiffusiveFlux
    variable = mobile
    boundary = right
    diffusivity = D
  []
[]

[Outputs]
  csv = true
[]
```

!col-end!
!row-end!

!---

# Troubleshooting Tips

## Common Issues and Solutions

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| Oscillations in solution | Fourier number too large | Decrease dt or refine mesh |
| Slow convergence | Poor initial guess | Use ramped BCs |
| Trap equations unstable | Stiff coupling | Use implicit schemes |
| Results don't match theory | Wrong units | Check diffusivity, concentrations |

## Debug Strategies

- Start with coarse mesh, refine gradually
- Use simple BCs first, add complexity
- Compare with analytical solutions when available

!---

# Building Complex Cases

## Progressive Development Strategy

1. +Start Simple+: Pure diffusion (ver-1dd)
2. +Add One Trap+: Test both regimes (ver-1d)
3. +Multiple Traps+: Build incrementally (ver-1dc)
4. +Validate Each Step+: Compare with theory

## Use Base Input Files

```
# my_base.i - Common settings
[Mesh]
  # Standard mesh
[]

# my_case.i - Specific physics
!include my_base.i
[Kernels]
  # Additional physics
[]
```

!---

# Performance Considerations

## Computational Efficiency Tips

```
[Executioner]
  # For testing - coarse/fast
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6

  # For verification - fine/accurate
  nl_abs_tol = 1e-12
  nl_rel_tol = 1e-10
[]

[Mesh]
  # Testing: nx = 100
  # Verification: nx = 1000
[]
```

## Parallel Execution

```bash
mpirun -np 4 ~/projects/TMAP8/tmap8-opt -i input.i
```

!---

# Advanced Features in TMAP8

## Beyond These Examples

- +2D/3D Geometries+: Change `dim` in `[Mesh]`
- +Multiple Materials+: Use `[Materials]` block
- +Coupled Physics+: Heat transfer, mechanics
- +Custom Kernels+: Extend with C++

## Example: Adding Temperature Dependence

```
[Materials]
  [diffusivity]
    type = ParsedMaterial
    property_name = D
    expression = 'D0*exp(-Ea/R/T)'
    coupled_variables = 'temperature'
  []
[]
```

!---

# Key Takeaways

- +Input File Structure+: Hierarchical blocks define physics
- +Progressive Complexity+: Build from simple to complex
- +Verification Strategy+: Compare with analytical solutions

  - ver-1dd: RMSPE = 0.14%
  - ver-1d: RMSPE = 0.96%
  - ver-1dc: RMSPE = 0.41%

- +Best Practices+:

  - Use base input files for modularity
  - Start with coarse meshes for development
  - Validate each physics addition
  - Document parameter choices

!---

# Hands-On Exercise

## Your Turn: Modify ver-1d

1. Open `ver-1d-diffusion.i` in VSCode
2. Change trap energy: `trap_energy_depth = 200`
3. Run the simulation
4. Compare breakthrough time with original

## Questions to Consider:

- How does breakthrough time change?
- Which regime are we in now?
- What ζ value does this correspond to?

!---

# Resources for Continued Learning

## Input Files to Study

- `/ver-1dd.i` - Start here
- `/ver-1d-diffusion.i` - Single trap
- `/ver-1dc_base.i` - Modular design example
- `/ver-1dc_mms.i` - Advanced verification

## Documentation

- [https://mooseframework.inl.gov/TMAP8/](https://mooseframework.inl.gov/TMAP8/)
- Example problems with full input files
- Syntax documentation for all kernels

## Getting Help

- MOOSE users forum
- TMAP8 GitHub issues
- INL support team