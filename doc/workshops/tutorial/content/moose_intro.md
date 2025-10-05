# Introduction to MOOSE

!---

# MOOSE Framework: Overview

!row!
!col! width=50%

!media large_media/tutorials/darcy_thermo_mech/moose_intro.png

!col-end!

!col! width=50%

- Developed by Idaho National Laboratory since 2008
- Used for studying and analyzing nuclear reactor problems
- Free and open source (LGPLv2 license)
- Large user community (5000+ unique visitors/month)
- Highly parallel and HPC capable
- Developed and supported by full time INL staff - long-term support
- https://www.mooseframework.inl.gov

!col-end!
!row-end!

!---

# MOOSE Framework: Key features

!row!
!col! width=50%

!media large_media/tutorials/darcy_thermo_mech/moose_intro.png

!col-end!

!col! width=50%

- Massively parallel computation - successfully run on >100,000 processor cores
- Multiphysics solve capability - fully coupled and implicit solver
- Multiscale solve capability - multiple applications can perform computation for a problem simultaneously
- Provides high level interface to implement customized physics, geometries, boundary conditions, and material models
- Initially developed to support nuclear R&D but now widely used for non-nuclear R&D also

!col-end!
!row-end!

!---

# MOOSE Framework: Core Philosophy

- +Object-oriented design+: Everything is an object with clear interfaces
- +Modular architecture+: Mix and match components to achieve simulation goals
- +Physics-agnostic+: Framework handles numerics, you focus on physics
- +Dimension-independent+: Write once, run in 1D, 2D, or 3D
- +Automatic differentiation+: No need to compute Jacobians manually
- +Strict separation of concerns+: Systems don't communicate directly

!---

# MOOSE Framework: Applications

!media large_media/tutorials/darcy_thermo_mech/moose_herd_2019.png style=width:100%;margin-left:auto;margin-right:auto;display:block;

!---

# MOOSE Systems Architecture

!row!
!col! width=40%

+Core Systems:+

- Mesh
- Variables
- Kernels
- BCs
- Materials
- AuxKernels
- Functions

!col-end!

!col! width=60%

+Advanced Systems:+

- MultiApps (multi-scale coupling)
- Transfers (data exchange)
- Postprocessors (scalar values)
- VectorPostprocessors (vector values)
- UserObjects (custom algorithms)
- Controls (runtime parameter modification)
- Executioner (solve control)

!col-end!
!row-end!

- Each system has specific responsibilities
- Systems interact through well-defined interfaces
- Objects can be mixed and matched

!---

# The Finite Element Method in MOOSE

MOOSE solves PDEs using the Galerkin finite element method

+Key steps:+

1. Write strong form of PDE
2. Convert to weak form (multiply by test function, integrate by parts)
3. Discretize with shape functions
4. Form residual vector and Jacobian matrix
5. Solve nonlinear system with Newton's method

+MOOSE handles:+

- Mesh management
- Shape functions
- Quadrature rules
- Assembly process
- Parallel decomposition

!---

# Kernels System: Building PDEs

!row!
!col! width=70%

```cpp
class DiffusionKernel : public ADKernel
{
protected:
  virtual ADReal computeQpResidual() override
  {
    return _grad_test[_i][_qp] * _grad_u[_qp];
  }
};
```

!col-end!

!col! width=30%

- Kernels represent volume terms in PDEs
- Each kernel computes one term
- Automatic differentiation for Jacobians
- Mix kernels to build complex equations

!col-end!
!row-end!

+Available variables:+

- `_u`, `_grad_u`: Variable value and gradient
- `_test`, `_grad_test`: Test function value and gradient
- `_qp`: Quadrature point index
- `_q_point`: Physical coordinates

!---

# Materials System: Property Management

!row!
!col! width=60%

+Producer/Consumer Pattern:+

- Materials produce properties
- Other objects consume properties
- Properties can vary in space and time
- Properties can be coupled to variables

+Key Methods:+

- `declareProperty<Type>()` - produce
- `getMaterialProperty<Type>()` - consume
- `getADMaterialProperty<Type>()` - consume with derivatives

!col-end!

!col! width=40%

```cpp
// Producer
_permeability = 
  declareADProperty<Real>
    ("permeability");

// Consumer  
_permeability = 
  getADMaterialProperty<Real>
    ("permeability");
```

!col-end!
!row-end!

!---

# Auxiliary System: Derived Quantities

- +Purpose+: Compute derived quantities from primary variables
- +Use cases+: Postprocessing, visualization, coupling

!row!
!col! width=50%

+Auxiliary Variables:+

- Not solved for directly
- Computed from other variables
- Can be nodal or elemental

!col-end!

!col! width=50%

+Example: Velocity from Pressure+

```
v = -K/μ * ∇p
```

- Pressure (p) is nonlinear variable
- Velocity (v) is auxiliary variable
- Computed via AuxKernel

!col-end!
!row-end!

!---

# Input File System: HIT Format

!row!
!col! width=60%

```
[Mesh]
  type = GeneratedMeshGenerator
  dim = 2
  nx = 100
  ny = 10
[]

[Variables]
  [pressure]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  [diffusion]
    type = ADDiffusion
    variable = pressure
  []
[]
```

!col-end!

!col! width=40%

+Hierarchical Input Text (HIT):+

- Block-based structure
- Parameters in key=value format
- Strong typing
- Extensive error checking
- Documentation built-in

+Required blocks:+

- Mesh
- Variables
- Kernels
- BCs
- Executioner
- Outputs

!col-end!
!row-end!

!---

# Solver System: PJFNK Method

+Preconditioned Jacobian-Free Newton-Krylov (PJFNK)+

!row!
!col! width=50%

+Newton's Method:+

- Solves nonlinear system: R(u) = 0
- Update: u^{n+1} = u^n - J^{-1}R
- Quadratic convergence

+Jacobian-Free:+

- Approximate J*v via finite differences
- No explicit Jacobian formation
- Reduces memory requirements

!col-end!

!col! width=50%

+Krylov Solvers:+

- GMRES (default)
- CG, BiCGStab
- Build Krylov subspace

+Preconditioning:+

- Hypre/BoomerAMG
- Block Jacobi
- ILU/LU
- Essential for performance

!col-end!
!row-end!

!---

# Automatic Differentiation in MOOSE

+Benefits:+

- No manual Jacobian calculations
- Reduces development time
- Eliminates Jacobian bugs
- Maintains accuracy

!row!
!col! width=60%

```cpp
// Traditional approach
virtual Real computeQpResidual() {...}
virtual Real computeQpJacobian() {...}
virtual Real computeQpOffDiagJacobian() {...}

// AD approach - Jacobian automatic!
virtual ADReal computeQpResidual() {...}
```

!col-end!

!col! width=40%

+How it works:+

- Operator overloading
- Chain rule application
- Forward mode AD
- MetaPhysicL library

+Best practice:+

- Use AD kernels/materials
- Let MOOSE handle derivatives

!col-end!
!row-end!

!---

# MultiApp and Transfer Systems

+Solving Multiple Applications Together+

!row!
!col! width=50%

+MultiApp System:+

- Run multiple MOOSE apps
- Different time scales
- Different spatial scales
- Master/sub-app hierarchy

+Use cases:+

- Multiscale modeling
- Micro/macro coupling
- Reduced-order models

!col-end!

!col! width=50%

+Transfer System:+

- Exchange data between apps
- Spatial interpolation
- Temporal interpolation
- Conservative transfers

+Types:+

- Field transfers
- Postprocessor transfers
- VectorPostprocessor transfers

!col-end!
!row-end!

!---

# Testing Framework

+Continuous Integration via Testing+

!row!
!col! width=60%

+Test Types:+

- `Exodiff`: Compare Exodus files
- `CSVDiff`: Compare CSV output
- `RunException`: Test error conditions
- `PetscJacobianTester`: Verify Jacobians
- `RunApp`: Basic execution test

+Test Organization:+
```
tests/
  kernels/
    my_kernel/
      my_kernel.i
      tests
      gold/
        my_kernel_out.e
```

!col-end!

!col! width=40%

+Benefits:+

- Prevent regressions
- Document expected behavior
- Enable refactoring
- Build confidence

+Running tests:+

```bash
./run_tests -j 12
```

+Test spec (HIT format):+

```
[Tests]
  [my_test]
    type = Exodiff
    input = test.i
    exodiff = test_out.e
  []
[]
```

!col-end!
!row-end!

!---

# Output System

+Flexible and Extensible Output+

!row!
!col! width=50%

+Supported Formats:+

- Exodus (recommended)
- VTK/VTU
- CSV (scalar data)
- Console
- Checkpoint (restart)
- Nemesis (parallel)

+Features:+

- Control output frequency
- Select variables to output
- Multiple outputs simultaneously

!col-end!

!col! width=50%

+Input file control:+

```
[Outputs]
  exodus = true
  csv = true
  [custom_out]
    type = Exodus
    interval = 10
    execute_on = 'timestep_end'
  []
[]
```

+Output control:+

- By time
- By timestep
- On events (initial, final, failed)

!col-end!
!row-end!

!---

# MOOSE Development Process

+Nuclear Quality Assurance Level 1 (NQA-1)+

!row!
!col! width=50%

+Version Control:+

- Git/GitHub workflow
- Pull request reviews
- Continuous integration
- Extensive testing (30M tests/week)

+Code Standards:+

- Consistent style (clang-format)
- Documentation required
- Test coverage required

!col-end!

!col! width=50%

+Development Tools:+

- CIVET (testing system)
- Peacock (GUI)
- VSCode integration
- Input file syntax highlighting

+Community:+

- 250+ contributors
- Discussion forum
- Workshops and training
- Extensive documentation

!col-end!
!row-end!

!---

# Getting Help with MOOSE

+Resources Available:+

!row!
!col! width=50%

+Documentation:+

- https://mooseframework.inl.gov
- Syntax documentation
- Theory manuals
- Example problems
- Video tutorials

+Community:+

- GitHub discussions
- User meetings
- Workshops

!col-end!

!col! width=50%

+Development:+

- GitHub issues
- Pull requests
- Code review process
- Contributing guidelines

+Training:+

- Regular workshops
- Online tutorials
- Example repository
- Module-specific guides

!col-end!
!row-end!

!---

# Summary: Why MOOSE for TMAP8?

- +Proven framework+: Used in 500+ publications, tested extensively
- +Parallel scalability+: Handles problems from laptop to supercomputer
- +Multiphysics capable+: Natural coupling of transport phenomena
- +Active development+: Continuous improvements and support
- +Extensible design+: Easy to add new physics for tritium transport
- +Quality assurance+: NQA-1 process ensures reliability
- +Community support+: Large user base and developer team

+TMAP8 leverages all these capabilities for tritium transport modeling!+
