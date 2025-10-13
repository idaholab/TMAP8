# TMAP8 Verification Walkthrough: \\ Tritium Permeation and Trapping

!style halign=center fontsize=120%
From Simple Diffusion to Multi-trap Systems

!---

# Overview

- +Purpose:+ Modeling tritium transport with progressing complexity.

  - +ver-1dd:+ Pure diffusion without trapping ([Documentation](ver-1dd.md))
  - +ver-1d:+ Diffusion with single trap type ([Documentation](ver-1d.md))
  - +ver-1dc:+ Diffusion with multiple trap types ([Documentation](ver-1dc.md))

- Based on established literature resources from the TMAP4 and TMAP7 eras:

  - [!cite](longhurst1992verification), [!cite](longhurst2005verification)
  - [!cite](ambrosek2008verification)

- Expanded upon & updated in [!cite](Simon2025)
- Demonstrates TMAP8's capability to handle increasingly complex tritium transport scenarios.

!---

# Physical Problem: Permeation Through a Membrane

!row!
!col! width=50%

## Configuration

- 1D slab geometry
- Constant source at upstream side ($x = 0$ m)
- Permeation flux measured at downstream side ($x = 1$ m)
- Breakthrough time characterizes transport

!col-end!

!col! width=50%

## Key Parameters

- Diffusivity: $D = 1$ $\text{m}^{2}$/s
- Temperature: $T = 1000$ K
- Upstream concentration: $C_{0} = 0.0001$ atom fraction
- Slab thickness: $l = 1$ m

!col-end!
!row-end!

!---

# Understanding MOOSE Input File Structure

## Basic Anatomy of a TMAP8 Input File

```
[Block]
  [subblock]
    type = MyObject
    parameter1 = value1
    parameter2 = value2
  []
[]
```

## Key Sections We'll Explore

- `[Mesh]` - Define geometry
- `[Variables]` - Declare unknowns to solve for
- `[Kernels]` - Define physics equations
- `[BCs]` - Define boundary conditions
- `[Executioner]` - Define the solution method
- `[Outputs]` - Setup how results should be saved

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

!row!
!col! width=45%

!listing ver-1dd.i block=Mesh Variables

!col-end!

!col! width=5%

!! This empty columns helps to provide spacing

!col-end!

!col! width=50%

- 1D mesh with 200 elements and a maximum length of 1 m. 

  - `nx_num` is defined as 200 at the top of the file, and `${}` syntax is used to utilize it elsewhere.
  - `xmin` in a `Mesh` object generally defaults to 0.

- Single variable `mobile` for the mobile species concentration
- Starts with zero initial concentration (not giving an `ICs` block and not setting `initial_condition` in this sub-block defaults to zero).

!col-end!
!row-end!

!---

# Case 1: Input File Structure - \\ Physics Implementation

!row!
!col! width=45%

!listing ver-1dd.i block=Kernels

!col-end!

!col! width=5%

!! This empty columns helps to provide spacing

!col-end!

!col! width=50%

- `Diffusion` kernel:

  !equation
  \nabla \cdot (D \nabla C_M)

  where $D = 1$ m$^2$/s.

- `TimeDerivative` kernel:

  !equation
  \frac{\partial C_M}{\partial t}

- Together, they form the diffusion equation that we are aiming to solve.

!col-end!
!row-end!

!---

# Case 1: Input File Structure - \\ Boundary Conditions

!row!
!col! width=45%

!listing ver-1dd.i block=BCs

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- A constant source of `value = 1` is placed at left (upstream), due to normalizing the concentration (`cl = 3.1622e18` atoms/$m^3$).

  - Note the use of the `fparse` system to perform this simple calculation.
  - In this case, the action of calculating the source is simple, but use of the parsing system can, in general, enhance readability of the input file.

- A concentration of zero is set at right (downstream).

!col-end!
!row-end!

!---

# Case 1: Input File Structure - \\ Postprocessors

!row!
!col! width=45%

!listing ver-1dd.i block=Postprocessors

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- Here, postprocessors are used to calculate two quantities:

  - The raw outward flux average on the downstream boundary using the [SideDiffusiveFluxAverage.md] object, given the `diffusivity` from the top of the input.
  - The raw outward flux average is then scaled to its actual value using the [ScalePostprocessor.md], which takes the `outflux` value and scales it by the concentration `cl`.

!col-end!
!row-end!

!---

# Case 1: Input File Structure - \\ Preconditioning and Solving

!row!
!col! width=40%

!listing ver-1dd.i block=Preconditioning Executioner

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=55%

- For preconditioning, we have a [SingleMatrixPreconditioner.md] (Single Matrix Preconditioner).

  - SMP builds a preconditioning matrix using user-defined off-diagonal parts of the Jacobian matrix.
  - Use of `full = true` uses *all* of the off-diagonal blocks, but tuning of the preconditioning can allow focus on one or more physics in your system.

- Given the time derivative term, we use a Transient executioner with a Newton solver.
- Other solver parameters - including total simulation time, the timestep, and the minimum timestep allowed - is set using parser syntax.

!col-end!
!row-end!

!---

# Case 1: Input File Structure - Outputs

!row!
!col! width=45%

!listing ver-1dd.i block=Outputs

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- Here, we want both [Exodus.md] and [CSV.md] output. By simply setting:

  ```
  exodus = true
  csv = true
  ```

- We also turn on [DOFMapOutput.md], only executing it on the initial timestep (after the matrix is constructed). This provides output information on how the matrix is constructed, which is helpful for complicated models.
- Finally, we turn on a simple performance table in the Console output.

!col-end!
!row-end!

!---

# Case 1: Let's Run It!

If using a cloned and locally-built copy of TMAP8:

```bash
cd test/tests/ver-1dd/
../../../tmap8-opt -i ver-1dd.i
```

If using a Docker container:

```bash
cd /tmap8-workdir/tmap8/ver-1dd
tmap8-opt -i ver-1dd.i
```

The output can then be visualized using ParaView, or by using the `comparison_ver-1dd.py` script with some light modifications (change the location of the data file to the output you just generated).

## What to Look For

- Convergence messages in terminal
- Exodus output files with field data (.e extension)
- CSV files with Postprocessor data

!---

# Case 1: Verification Results

!media comparison_ver-1dd.py
       image_name=ver-1dd_comparison_diffusion.png
       style=display:block;box-shadow:none;width:55%;margin-left:auto;margin-right:auto;

- Breakthrough time: $\tau_b = 0.05$ seconds (both analytical and TMAP8)
- Excellent agreement throughout transient

!---

# Case 2: Single Trap Type (ver-1d)

In this case, we are modeling permeation through a membrane with a constant source in which traps are operative. We solve the following equations:

!row!
!col! width=50%

For mobile species:

!equation
\frac{\partial C_M}{\partial t} = \nabla \cdot (D \nabla C_M) - \text{trap\_per\_free} \cdot \frac{\partial C_T}{\partial t}

For trapped species:

!equation
\frac{\partial C_T}{\partial t} = \alpha_t \frac{C_T^{empty} C_M}{N \cdot \text{trap\_per\_free}} - \alpha_r C_T

For empty trapping sites:

!equation
C_T^{empty} = C_{T0} \cdot N - \text{trap\_per\_free} \cdot C_T

!col-end!

!col! width=50%

where:

- $C_M$ and $C_T$ are the concentrations of the mobile and trapped species respectively
- $D$ is the diffusivity of the mobile species
- $\alpha_t$ and $\alpha_r$ are the trapping and release rate coefficients
- $\text{trap\_per\_free}$ is a factor converting the magnitude of $C_T$ to be closer to $C_M$ for better numerical convergence
- $C_{T0}$ is the fraction of host sites that can contribute to trapping
- $C_T^{empty}$ is the concentration of empty trapping sites
- $N$ is the host density.

!col-end!
!row-end!

!---

# Trapping parameter

The breakthrough time may have one of two limiting values depending on whether the trapping is in the effective diffusivity or strong-trapping regimes. A trapping parameter is defined by:

\begin{equation}
    \zeta = \frac{\lambda^2 \nu}{\rho D_0} \exp \left( \frac{E_d - \epsilon}{kT} \right) + \frac{c}{\rho}
\end{equation}

where:

- $\lambda$ = lattice parameter
- $\nu$ = Debye frequency ($\approx$ $10^{13} \; s^{-1}$)
- $\rho$ = trapping site fraction
- $D_0$ = diffusivity pre-exponential
- $E_d$ = diffusion activation energy
- $\epsilon$ = trap energy
- $k$ = Boltzmann's constant
- $T$ = temperature
- $c$ = dissolved gas atom fraction

!---

# Effective Diffusivity Regime

The discriminant for which regime is dominant is the ratio of $\zeta$ to c/$\rho$. If $\zeta$ $\gg$ c/$\rho$, then the effective diffusivity regime applies, and the permeation transient is identical to the standard diffusion transient, with the diffusivity replaced by an effective diffusivity

!equation
D_{eff} = \frac{D}{1 + \frac{1}{\zeta}}

to account for the fact that trapping leads to slower transport.

In this limit, the breakthrough time, defined as the intersection of the steepest tangent to the diffusion transient with the time axis, will be

\begin{equation}
    \tau_{b_e} = \frac{l^2}{2 \; \pi^2 \; D_{eff}}
\end{equation}

where $l$ is the thickness of the slab and D is the diffusivity of the gas through the material.

!---

# Strong-trapping Regime

In the deep-trapping limit, $\zeta$ $\approx$ c/$\rho$, and no permeation occurs until essentially all the traps have been filled. Then the system quickly reaches steady-state. The breakthrough time is given by

\begin{equation}
    \tau_{b_d} = \frac{l^2 \rho}{2 \; C_0 \; D}
\end{equation}

where $C_0$ is the steady dissolved gas concentration at the upstream (x = 0) side.

!---

# Case Description

In this scenario, examine reach regime using two input files:

- +ver-1d-diffusion.i:+ where diffusion is the rate-limiting step
- +ver-1d-trapping.i:+ where trapping is the rate-limiting step.

This is the same domain configuration as in Case 1.

### Key Parameters

!row!
!col! width=50%

- Diffusivity: $D = 1$ m$^2$/s
- Temperature: $T = 1000$ K
- Upstream concentration: $C_{0} = 0.0001$ atom fraction
- Slab thickness: $l = 1$ m
- Trapping site fraction: 10$\%$ (0.1)

!col-end!

!col! width=50%

- Lattice parameter: $\lambda^2 = 10^{-15}$ m$^2$
- $\text{trap\_per\_free} = 1$ (Diffusion), $10^3$ (Trapping)
- Trapping rate coefficient: $\alpha_t = 10^{15}$ 1/s
- Release rate coefficient: $\alpha_r = 10^{13}$ 1/s
- Host density: $N = 3.1622 \times 10^{22}$ atoms / m$^3$

!col-end!
!row-end!

!---

# Case 2: Diffusion Limit Input File - Variables

In this case, we'll be highlighting the main changes from Case 1, where we only had diffusion for a single mobile species.

!listing ver-1d-diffusion.i block=Variables

- Now, we have two species, `trapped` and `mobile`. Similar to Case 1, the `mobile` variable is our primary variable, as we'll plot the downstream flux for comparison to analytical solutions.
- Both use the default initial concentrations of zero, as well as the default FEM families/order.

!---

# Case 2: Diffusion Limit Input File - Trapping Physics

!listing ver-1d-diffusion.i block=NodalKernels

!---

# A Note on ReferenceResidualProblem

- The [ReferenceResidualProblem.md] MOOSE Problem type is designed to allow custom criteria for convergence for separate, coupled physics by using tagged vectors to designate portions of the system matrix.
- These tags are set in the `[Problem]` block using `reference vector` and `extra_tag_vectors` and then used in the *Kernel blocks (of all types).

!listing ver-1d-diffusion.i block=Problem Kernels/diff

!---

# Case 2: Diffusion Limit Input File - Coupling Mobile and Trapped

!row!
!col! width=45%

!listing ver-1d-diffusion.i block=Kernels

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- We now have a new Kernel in the PDE corresponding to `mobile`:

  !equation
  \frac{\partial C_T}{\partial t}

  represented by [CoupledTimeDerivative.md].
- Note that "v" is a common parameter name representing the coupled variable in many MOOSE objects.

!col-end!
!row-end!

!---

# Case 2: Diffusion Limit Input File - Trapped Physics

!row!
!col! width=45%

!listing ver-1d-diffusion.i block=NodalKernels

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- To represent the trapping physics on the nodes, we can use the [syntax/NodalKernels/index.md].
- [TimeDerivativeNodalKernel.md] is used for:

  !equation
  \frac{dC_T}{dt}
- [TrappingNodalKernel.md] is used for:

  !equation
  -\alpha_t  \frac {C_T^{empty} C_M } {(N \cdot \text{trap\_per\_free})}

- Finally, [ReleasingNodalKernel.md] is used for:

  !equation
  \alpha_r C_T

!col-end!
!row-end!

!---

# Case 2: Diffusion Limit Input File - Executioner

!row!
!col! width=45%

!listing ver-1d-diffusion.i block=Executioner

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- The executioner in this case is similar to that in Case 1.
- Note that a different [TimeStepper/index.md] is used (the default, `implicit-euler`).
- The absolute non-linear tolerance is also using the smaller default value (`1e-50`).

!col-end!
!row-end!

!---

# Case 2: Strong Trapping Input File - \\ AuxVariables and AuxKernels

For the deep trapping limit case, we'll cover the additions of objects to determine the empty trapping site concentration.

!row!
!col! width=45%

!listing ver-1d-trapping.i block=AuxVariables AuxKernels

!col-end!

!col! width=5%

!! This empty column helps to provide spacing

!col-end!

!col! width=50%

- Because the empty trapping concentration is not a differential equation, we can solve for it using the [AuxKernels/index.md]:

  !equation
  C_T^{empty} = C_{T0} \cdot N - \text{trap\_per\_free} \cdot C_T

- AuxKernels are also used (in the case of `scaled_empty` and `trapped_sites`) to calculate the total number of trapping sites in the model.

!col-end!
!row-end!

!---

# Case 2: Numerical Considerations

- The trapping test input file can generate oscillations in the solution due to the feedback loop between the diffusion PDE and trap evolution ODE. Two strategies are used:

!row!
!col! width=48%

### Finer Mesh and Time Step

!listing ver-1d-trapping.i block=Mesh Executioner/TimeStepper

!col-end!

!col! width=4%

!! This empty column helps to provide spacing

!col-end!

!col! width=48%

### Ramped Boundary Condition

!listing ver-1d-trapping.i block=BCs/left Functions

!col-end!
!row-end!

!---

# Case 2: Trapping Parameter Study

As a reminder, the trapping parameter $\zeta$ is the key discriminant to which regime is dominating.

!row!
!col! width=50%

### Effective Diffusivity \\ Regime

- When $\zeta$ $\gg$ c/$\rho$
- Set: $\epsilon = 100$
- $\zeta = 91.47$ c/$\rho$

!col-end!

!col! width=50%

### Strong-Trapping Regime / Deep Trapping Limit

- When $\zeta$ $\approx$ c/$\rho$
- Set $\epsilon = 10000$
- $\zeta = 1.00454$ c/$\rho$

!col-end!
!row-end!

!---

# Case 2: Diffusion-Limited Results

!media comparison_ver-1d.py
       image_name=ver-1d_comparison_diffusion.png
       style=display:block;box-shadow:none;width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto

- Trapping slows but doesn't stop diffusion
- Smooth permeation curve

!---

# Case 2: Trap-Limited Results

!media comparison_ver-1d.py
       image_name=ver-1d_comparison_trapping.png
       style=display:block;box-shadow:none;width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto

- Must fill traps before significant permeation
- Sharp transition at breakthrough

!---

# Case 3: Multiple Trap Types (ver-1dc)

## Extended System of Equations

This case is very similar to Case 2, except there are now three different types of traps.

Mobile species with three trap interactions:

!equation
\frac{\partial C_M}{\partial t} = \nabla \cdot (D \nabla C_M) - \text{trap\_per\_free} \cdot \sum_{i=1}^{3} \frac{\partial C_{T_i}}{\partial t}

!equation
\frac{dC_{T_i}}{dt} = \alpha_t^i  \frac {C_{T_i}^{empty} C_M } {(N \cdot \text{trap\_per\_free})} - \alpha_r^i C_{T_i}

Each trap evolves independently (i = 1, 2, 3). Finally, for the empty trapping sites:

!equation
C_{T_i}^{empty} = (C_{{T_i}0} \cdot N - \text{trap\_per\_free} \cdot C_{T_i}  )

!---

# Case 3: Base Input File Strategy

- This case introduces the "input file include" capability in practice.
- `ver-1dc_base.i` contains the mesh, Problem, Variables, Kernels, NodalKernels, Preconditioning, and Executioner settings for both the standard and MMS input files.
- This is done to enable multiple input files to use the same common elements.
- This modular design:

  - Eases maintainability and repeatability
  - Reduces redundancy and errors
  - Allows for case-specific input files
  - Enables more readable highlight of unique physics

!---

# Case 3: Base Input File

!listing ver-1dc_base.i

!---

# Case 3: Defining Multiple Traps

Multiple sites can have different properties through the use of separate sets of NodalKernels to represent the unique properties of each trap.

!row!
!col! width=45%

For example, for `trapped_1`:

!listing ver-1dc_base.i block=NodalKernels/time_1 NodalKernels/trapping_1 NodalKernels/release_1

!col-end!

!col! width=5%

!! This provides empty space between each column

!col-end!

!col! width=50%

Each Trap Gets:

- Its own solution variable
- Independent evolution equation
- Unique parameters (site fraction, energy)

!col-end!
!row-end!

!---

# Case 3: Three Trap Parameters

Three traps that are relatively weak are assumed to be active in the slab. Other parameters are the same as the trap in the effective diffusivity limit in [ver-1d](ver-1d.md).

- Trap Type 1

  - Trapping site fraction: 0.1
  - $\epsilon/k$ = 100 K

- Trap Type 2

  - Trapping site fraction: 0.15
  - $\epsilon/k$ = 500 K

- Trap Type 3

  - Trapping site fraction: 0.2
  - $\epsilon/k$ = 800 K

!---

# Case 3: Coupling All Traps to Mobile Species

!listing ver-1dc_base.i block=Kernels

!---

# Case 3: Verification Results

!media comparison_ver-1dc.py
       image_name=ver-1dc_comparison_diffusion.png
       style=display:block;box-shadow:none;width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto

- Breakthrough time: 4.04 s (analytical) vs 4.12 s (TMAP8)
- Combined effect of all three traps

!---

# Case 3: MMS Verification Approach

Exact solutions and forcing functions:

!listing ver-1dc/functions.i

!---

# Case 3: MMS Verification Approach (continued)

Application of functions to Kernels/NodalKernels/BCs to "force" exact solution:

!listing ver-1dc_mms.i block=Kernels NodalKernels BCs

!---

# Case 3: MMS Spatial Convergence

!media spatial_mms.py
       image_name=ver-1dc-mms-spatial.png
       style=display:block;box-shadow:none;width:60%;margin-bottom:2%;margin-left:auto;margin-right:auto

- 10 levels of mesh refinement
- Confirms proper implementation
- Quadratic convergence as expected

!---

# Modifying Input Files - Exercise

## Try These Changes to ver-1dd.i:

!row!
!col! width=45%

- +Change mesh resolution+

  ```
  [Mesh]
    nx = 400  # Was 200
  []
  ```

- +Adjust time stepping+

  ```
  [Executioner]
    dt = 0.0001  # Smaller initial step
  []
  ```

!col-end!

!col! width=5%

!! This provides empty space between each column

!col-end!

!col! width=50%

- +Modified diffusivity+

  ```
  [Kernels]
    [diff]
      diffusivity = 0.5  # Slower diffusion
    []
  []
  ```

!col-end!
!row-end!

!---

# Tips and Tricks

## Debug Strategies

- Start with coarse mesh, refine gradually
- Use simple BCs first, add complexity
- Compare with analytical solutions when available

## Building Complex Cases

Use a progressive development strategy:

1. +Start Simple+: Pure diffusion (ver-1dd)
2. +Add One Trap+: Test both regimes (ver-1d)
3. +Multiple Traps+: Build incrementally (ver-1dc)
4. +Validate Each Step+: Compare with theory

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

## Example: Temp. Dependence Directly in Input

!listing ver-1jb.i block=Materials/diffusivity

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

1. Open `ver-1d-diffusion.i` in your editor
2. Change detrapping energy: $\epsilon = 200$
3. Run the simulation
4. Compare breakthrough time with original

## Questions to Consider:

- How does breakthrough time change?
- Which regime are we in now?
- What $\zeta$ value does this correspond to?