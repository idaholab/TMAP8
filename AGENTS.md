# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

TMAP8 (Tritium Migration Analysis Program, Version 8) is a MOOSE-based finite element application for tritium transport and fuel cycle modeling. It is built on top of the [MOOSE framework](https://mooseframework.inl.gov), which lives in the sub-directory `moose` (referred to as `MOOSE_DIR`).

## Build & Test Commands

```bash
# Build (from repo root)
METHOD=opt make -j64   # optimized build → tmap8-opt
METHOD=devel make -j64 # debug build → tmap8-devel

# Run all tests
METHOD=opt ./run_tests -j64

# Run tests in a specific directory
METHOD=opt ./run_tests -j64 --re test/tests/kernels/

# Run a single input file manually
./tmap8-opt -i test/tests/kernels/some_test.i

# Build and run unit tests
METHOD=opt make -C unit -j64
./unit/run_tests
```

The `METHOD` environment variable controls the build type: `opt`, `devel`, `oprof`, `dbg`. The default
build type for a developer should be `devel`, as it has optimizations (`-O2`), but also includes assertions.

## Architecture

TMAP8 follows MOOSE's plugin architecture. The key concept: everything is registered to a central factory and instantiated from input (`.i`) files at runtime.

### Registration (src/base/TMAP8App.C)

`TMAP8App::registerAll()` is the single place that wires together:
- `ModulesApp::registerAllObjects<TMAP8App>()` — imports all enabled MOOSE physics modules
- `Registry::registerObjectsTo(f, {"TMAP8App"})` — registers all TMAP8 kernels, BCs, materials, etc.
- `registerSyntax(...)` — maps Physics block names to Action classes

Every new class must have `registerMooseObject("TMAP8App", ClassName)` (or `registerMooseAction`) at file scope in its `.C` file to be usable in input files.

### Object Types

| Directory | Base Class | Purpose |
|-----------|-----------|---------|
| `src/kernels/` | `ADKernel` | PDE residual contributions (volume integrals) |
| `src/nodal_kernels/` | `NodalKernel` | Point-wise ODE terms (trapping/releasing) |
| `src/interfacekernels/` | `ADInterfaceKernel` | Coupling between adjacent subdomains |
| `src/bcs/` | `ADIntegratedBC` | Boundary integral terms |
| `src/materials/` | `ADMaterial` / `InterfaceMaterial` | Constitutive properties computed at quadrature points |
| `src/physics/` | `PhysicsBase` | Actions that auto-create variables + kernels + BCs |
| `src/actioncomponents/` | `ActionComponent` | High-level components (Structure1D, Enclosure0D) |
| `src/auxkernels/` | `AuxKernel` | Derived quantities for output/postprocessing |

### Physics Layer

`SpeciesTrappingPhysics` and `SorptionExchangePhysics` are the primary high-level entry points. Physics classes are MOOSE Actions registered for multiple tasks (`add_variable`, `add_kernel`, `add_ic`, etc.) — they programmatically create all solver variables and kernels when the input file is parsed. This means the `.i` file's `[Physics]` block is translated into many underlying `[Variables]` and `[Kernels]` objects automatically.

### Input File Format (HIT syntax)

```ini
[Physics]
  [SpeciesTrapping]
    [trapping_site_1]
      species = trapped1
      mobile = mobile
      alpha_t = 1e15        # trapping rate (1/s)
      trapping_energy = 0.5 # eV
      N = 3.16e22           # trap site density (at/m^3)
      Ct0 = initial_occupancy_function
      trap_per_free = 1.0
      alpha_r = 1e13
      detrapping_energy = 1.0
    []
  []
[]
```

Physics reference values (`mobileConcentrationReference`, `siteDensityReference`) drive automatic row scaling — important for numerical conditioning of the nonlinear solve.

## Coding Conventions

C++ style is enforced by `.clang-format` (LLVM base, 100-char lines, 2-space indent, Allman braces). Run `clang-format -i` on changed files before committing.

**Standard class pattern:**
```cpp
// In header:
class MyKernel : public ADKernel
{
public:
  static InputParameters validParams();
  MyKernel(const InputParameters & parameters);
protected:
  ADReal computeQpResidual() override;
private:
  const ADMaterialProperty<Real> & _prop;
  const ADVariableValue & _coupled;
};

// In source — registration must appear at file scope:
registerMooseObject("TMAP8App", MyKernel);

InputParameters MyKernel::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("...");
  params.addRequiredParam<MaterialPropertyName>("prop", "...");
  params.addCoupledVar("coupled_var", "...");
  return params;
}
```

**Prefer AD types** (`ADKernel`, `ADMaterialProperty`, `ADVariableValue`) over non-AD equivalents — automatic differentiation provides exact Jacobians with no hand-coding.

## Test Structure

Tests live in `test/tests/` organized by object type and by validation/verification case. Each test directory contains:
- One or more `.i` input files
- A `tests` metadata file (HIT format) listing test specs
- `*_gold/` or `*_out_gold.*` reference outputs for diff comparison

Test types used: `CSVDiff` (compare CSV outputs), `Exodiff` (compare Exodus mesh outputs), `RunException` (expect a specific error).

The `testroot` file enforces `allow_warnings = false`, `allow_unused = false`, `allow_override = false` — all tests must pass with zero warnings.

## Enabled MOOSE Modules

The `Makefile` enables: `CHEMICAL_REACTIONS`, `HEAT_TRANSFER`, `FLUID_PROPERTIES`, `NAVIER_STOKES`, `PHASE_FIELD`, `SCALAR_TRANSPORT`, `SOLID_PROPERTIES`, `SOLID_MECHANICS`, `THERMAL_HYDRAULICS`, `RAY_TRACING`, `RDG`, `STOCHASTIC_TOOLS`.

When adding kernels that depend on a module's base classes, confirm the module is listed in the `Makefile`.

## MOOSE Framework Reference

The MOOSE framework source is at `../cuda-mpich-moose`. Key locations:
- `framework/include/physics/PhysicsBase.h` — base class for all Physics actions
- `framework/include/base/MooseApp.h` — app base class
- `modules/` — source for all optional physics modules
- `examples/ex02_kernel/` — minimal kernel example showing the full pattern
