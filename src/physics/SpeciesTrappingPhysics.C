//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SpeciesTrappingPhysics.h"
#include "MooseUtils.h"
#include "ComponentAction.h"
#include "Enclosure0D.h"

// For connecting to multi-D diffusion on other components
#include "Structure1D.h"
#include "DiffusionPhysicsBase.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "init_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_scalar_kernel");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_bc");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_variable");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_ic");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_function");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_postprocessor");

InputParameters
SpeciesTrappingPhysics::validParams()
{
  InputParameters params = PhysicsBase::validParams();
  params.addClassDescription("Add Physics for the trapping of species on components.");

  // Not defined on blocks, but rather on components
  params.suppressParameter<std::vector<SubdomainName>>("block");
  params.addParam<std::vector<ComponentName>>(
      "components",
      {},
      "Components on which the Physics is active. Which Physics is active on a component can also "
      "be specified on the component");
  // Note: equilibrium constants is required because we don't want to specify different values on
  // each component. And because of this, species is also required. This means we can avoid
  // specifying the species on each components as well, only their IC and scaling factor.
  params.addRequiredParam<std::vector<std::vector<NonlinearVariableName>>>(
      "species",
      "Species that can be trapped on each component. If a single vector is specified, the same "
      "species will be used on every component");
  params.addParam<std::vector<std::vector<Real>>>(
      "species_scaling_factors",
      {},
      "Scaling factors for each species equation on each component. If a single vector is "
      "specified, the same scaling factors will be used on every component");
  params.addParam<std::vector<std::vector<Real>>>(
      "species_initial_pressures",
      {},
      "Initial values for each species equation on each component. If a single vector is "
      "specified, the same initial conditions will be used on every component");
  params.addParam<std::vector<Real>>(
      "temperatures", {}, "Temperatures for each enclosure component");
  params.addRequiredParam<std::vector<std::vector<Real>>>(
      "equilibrium_constants",
      "The equilibrium constants between gas partial pressure and adsorbed solute concentration "
      "for each species on each component. Note that they will be scaled using the scaling "
      "parameters specified. If a single vector is "
      "specified, the same equilibrium constants will be used on every component");
  // TODO is equilibrium constant same as solubility?

  // Units
  params.addParam<Real>("pressure_unit_scaling", 1, "");
  params.addParam<Real>(
      "length_unit_scaling",
      1,
      "The number of length units in a meter. This allows the user to select length units "
      "other than meters that may lead to better overall scaling of the system.");
  return params;
}

SpeciesTrappingPhysics::SpeciesTrappingPhysics(const InputParameters & parameters)
  : PhysicsBase(parameters),
    _components(getParam<std::vector<ComponentName>>("components")),
    _species(getParam<std::vector<std::vector<NonlinearVariableName>>>("species")),
    _scaling_factors(getParam<std::vector<std::vector<Real>>>("species_scaling_factors")),
    _initial_conditions(getParam<std::vector<std::vector<Real>>>("species_initial_pressures")),
    _enclosure_temperatures(getParam<std::vector<Real>>("temperatures")),
    _species_Ks(getParam<std::vector<std::vector<Real>>>("equilibrium_constants")),
    _length_unit(getParam<Real>("length_unit_scaling")),
    _pressure_unit(getParam<Real>("pressure_unit_scaling"))
{
  // Fill in the species vector of vectors for convenience
  // TODO: do this later so we can turn on this Physics from a component
  if (_species.size() == 1 && _components.size())
    _species.resize(_components.size(), _species[0]);
  // The initial conditions and scaling double-vectors use logic to work with a size 1 vector

  // TODO: check that the components actually exists
  // TODO: choose input from components or input from Physics
}

void
SpeciesTrappingPhysics::addComponent(const ComponentAction & component)
{
  checkComponentType<Enclosure0D>(component);
  const auto & comp = dynamic_cast<const Enclosure0D &>(component);

  // This must be added
  _components.push_back(comp.name());
  if (isParamSetByUser("components"))
    paramError("components",
               "Components can indicate which Physics are active on them or Physics can set to be "
               "active on certain components, but not both");

  const auto n_species_component = comp.species().size();

  // Process each of the component's parameters, adding defaults to avoid breaking the double-vector
  // indexing when needed
  processComponentParameters<std::vector<NonlinearVariableName>>(
      "species", comp.name(), _species, comp.species(), false, {});
  processComponentParameters<std::vector<Real>>("species_scaling_factors",
                                                comp.name(),
                                                _scaling_factors,
                                                comp.scalingFactors(),
                                                true,
                                                std::vector<Real>(1, n_species_component));
  processComponentParameters<std::vector<Real>>("species_initial_conditions",
                                                comp.name(),
                                                _initial_conditions,
                                                comp.ics(),
                                                true,
                                                std::vector<Real>(0, n_species_component));
  processComponentParameters<Real>(
      "temperatures", comp.name(), _enclosure_temperatures, comp.temperature(), false, 0);

  // TODO: check that inputs are consistent once all components have been added.
  // - the pressure, temperature and the scaling factors should be positive (defense in depth from
  // Components)
}

void
SpeciesTrappingPhysics::addNonlinearVariables()
{
  const std::string variable_type = "MooseVariableScalar";
  InputParameters params = getFactory().getValidParams(variable_type);
  params.set<MooseEnum>("family") = "SCALAR";
  params.set<MooseEnum>("order") = FIRST;

  for (const auto c_i : index_range(_components))
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + _components[c_i];
      params.set<std::vector<Real>>("scaling") = {
          (_scaling_factors.size() > 1)
              ? _scaling_factors[c_i][s_j]
              : ((_scaling_factors.size() == 1) ? _scaling_factors[0][s_j] : 1)};
      getProblem().addVariable(variable_type, species_name, params);
    }
}

void
SpeciesTrappingPhysics::addInitialConditions()
{
  const std::string ic_type = "ScalarConstantIC";
  InputParameters params = getFactory().getValidParams(ic_type);

  for (const auto c_i : index_range(_components))
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + _components[c_i];
      params.set<VariableName>("variable") = species_name;
      params.set<Real>("value") =
          ((_initial_conditions.size() > 1)
               ? _initial_conditions[c_i][s_j]
               : ((_initial_conditions.size() == 1) ? _initial_conditions[0][s_j] : 1)) *
          _pressure_unit;
      getProblem().addInitialCondition(ic_type, "IC_" + species_name, params);
    }
}

void
SpeciesTrappingPhysics::addScalarKernels()
{
  for (const auto c_i : index_range(_components))
  {
    // Get the boundary from the component
    const auto & comp_name = _components[c_i];
    const auto & component = getComponent(comp_name);
    const auto & structure_boundary = getConnectedStructureBoundary(c_i);
    const auto scaled_volume = component.volume() * Utility::pow<3>(_length_unit);
    const auto scaled_area = component.outerSurfaceArea() * Utility::pow<3>(_length_unit);

    // Create the kernel for each species
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + _components[c_i];

      // Time derivative
      if (isTransient())
      {
        const std::string kernel_type = "ODETimeDerivative";
        InputParameters params = getFactory().getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        getProblem().addScalarKernel(kernel_type, prefix() + species_name + "_time", params);
      }

      const auto flux_name =
          getConnectedStructurePhysics(c_i)[0]->name() + "_diffusive_flux_" + structure_boundary;
      static constexpr Real kb = 1.38e-23;

      // Sink term
      {
        const std::string kernel_type = "EnclosureSinkScalarKernel";
        auto params = _factory.getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        params.set<Real>("concentration_to_pressure_conversion_factor") =
            kb * libMesh::Utility::pow<3>(_length_unit) * _enclosure_temperatures[c_i] *
            _pressure_unit;
        params.set<PostprocessorName>("flux") = flux_name;
        params.set<Real>("surface_area") = scaled_area;
        params.set<Real>("volume") = scaled_volume;
        getProblem().addScalarKernel(kernel_type, species_name + "_enc_sink_sk", params);
      }
    }
  }
}

void
SpeciesTrappingPhysics::addFEBCs()
{
  for (const auto c_i : index_range(_components))
  {
    const auto & structure_boundary = getConnectedStructureBoundary(c_i);

    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + _components[c_i];
      const auto multi_D_species_name = getConnectedStructureVariableName(c_i, s_j);
      {
        const std::string bc_type = "EquilibriumBC";
        auto params = _factory.getValidParams(bc_type);
        params.set<NonlinearVariableName>("variable") = multi_D_species_name;
        params.set<std::vector<VariableName>>("enclosure_scalar_var") = {species_name};
        params.set<Real>("Ko") =
            ((_species_Ks.size() > 1) ? _species_Ks[c_i][s_j] : _species_Ks[0][s_j]) * 1 /
            Utility::pow<3>(_length_unit) / _pressure_unit;
        params.set<FunctionName>("temperature") = std::to_string(_enclosure_temperatures[c_i]);
        params.set<std::vector<BoundaryName>>("boundary") = {structure_boundary};
        getProblem().addBoundaryCondition(bc_type, species_name + "_equi_bc", params);
      }
    }
  }
}

void
SpeciesTrappingPhysics::addFunctions()
{
  // for (const auto c_i : index_range(_components))
  //   for (const auto s_j : index_range(_species[c_i]))
  //   {
  //     const auto K_name = (_species_Ks.size() > 1) ? _species_Ks[c_i][s_j] : _species_Ks[0][s_j];
  //     const auto scaling_K = 1 / Utility::pow<3>(_length_unit) / _pressure_unit;

  //     const std::string fun_type = "CompositeFunction";
  //     auto params = _factory.getValidParams(fun_type);
  //     params.set<std::vector<FunctionName>>("functions") = {K_name};
  //     params.set<Real>("scale_factor") = scaling_K;
  //     getProblem().addFunction(fun_type, K_name + "_scaled", params);
  //   }
}

void
SpeciesTrappingPhysics::addPostprocessors()
{
  // for (const auto c_i : index_range(_components))
  //   for (const auto s_j : index_range(_species[c_i]))
  //   {
  //     // TODO Replace this with a functor. We are losing derivatives here
  //     const auto & comp_name = _components[c_i];
  //     const auto species_name = _species[c_i][s_j] + "_" + _components[c_i];
  //     const auto & boundaries = getComponent(comp_name).outerSurfaceBoundaries();
  //     checkSingleBoundary(boundaries, comp_name);
  //     const auto & structure_boundary = boundaries[0];
  //     const auto flux_name = species_name + "_" + structure_boundary + "_flux";

  //     // Find the multi-D species from the Physics on the connected structure
  //     const auto multi_D_species_name = getConnectedStructureVariableName(c_i, s_j);

  //     // Create the boundary integration of the flux
  //     const std::string pp_type = "SideDiffusiveFluxIntegral";
  //     auto params = _factory.getValidParams(pp_type);
  //     params.set<std::vector<VariableName>>("variable") = {multi_D_species_name};
  //     params.set<MaterialPropertyName>("diffusivity") = "D_" + species_name;
  //     params.set<std::vector<BoundaryName>>("boundary") = {structure_boundary};
  //     params.set<ExecFlagEnum>("execute_on") = {
  //         EXEC_INITIAL, EXEC_TIMESTEP_END, EXEC_NONLINEAR, EXEC_LINEAR};
  //     getProblem().addPostprocessor(pp_type, flux_name, params);
  //   }
}

void
SpeciesTrappingPhysics::checkSingleBoundary(const std::vector<BoundaryName> & boundaries,
                                            const ComponentName & comp_name) const
{
  if (boundaries.size() != 1)
    paramError("components",
               "Only implemented for a single boundary and component '" + comp_name + "' has " +
                   std::to_string(boundaries.size()) + " boundaries.");
}

const VariableName &
SpeciesTrappingPhysics::getConnectedStructureVariableName(unsigned int c_i, unsigned int s_j)
{
  const auto & comp_name = _components[c_i];
  const auto & component = getComponent(comp_name);
  const auto multi_D_physics = getConnectedStructurePhysics(c_i);
  if (multi_D_physics.empty())
    component.paramError("connected_structure",
                         "Connected structure does not have any Physics defined");
  if (!dynamic_cast<DiffusionPhysicsBase *>(multi_D_physics[0]))
    component.paramError(
        "connected_structure",
        "Connected structure does not have a diffusion Physics defined as its first 'physics'");
  // Note that DiffusionPhysicsBase only support one variable currently
  if (multi_D_physics[0]->nonlinearVariableNames().size() != _species[c_i].size())
    component.paramError(
        "connected_structure",
        "The connected structure does not have the same number of nonlinear variables (" +
            std::to_string(multi_D_physics[0]->nonlinearVariableNames().size()) +
            ") as the number of species (" + std::to_string(_species[c_i].size()) + ")");
  return multi_D_physics[0]->nonlinearVariableNames()[s_j];
}

const BoundaryName &
SpeciesTrappingPhysics::getConnectedStructureBoundary(unsigned int c_i)
{
  const auto & comp_name = _components[c_i];
  const auto & component = getComponent(comp_name);
  const auto & boundaries = component.outerSurfaceBoundaries();
  checkSingleBoundary(boundaries, comp_name);
  return boundaries[0];
}

const std::vector<PhysicsBase *>
SpeciesTrappingPhysics::getConnectedStructurePhysics(unsigned int c_i)
{
  const auto comp_name = _components[c_i];
  const auto & component = dynamic_cast<const Enclosure0D &>(getComponent(comp_name));
  const auto & structure = getComponent(component.connectedStructure());
  checkComponentType<Structure1D>(structure);
  return dynamic_cast<const Structure1D &>(structure).getPhysics();
}
