/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "SpeciesSolubilityPhysics.h"
#include "MooseUtils.h"
#include "ActionComponent.h"
#include "Enclosure0D.h"

// For connecting to multi-D diffusion on other components
#include "Structure1D.h"
#include "DiffusionPhysicsBase.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "init_physics");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "add_variable");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "add_ic");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "add_scalar_kernel");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "add_bc");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "check_integrity_early_physics");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "check_integrity");
registerMooseAction("TMAP8App", SpeciesSolubilityPhysics, "copy_vars_physics");

InputParameters
SpeciesSolubilityPhysics::validParams()
{
  InputParameters params = SpeciesPhysicsBase::validParams();
  params.addClassDescription(
      "Creates all the objects needed to solve for the concentration of one or more species in "
      "each 0D enclosure in which the species can go into solution / release from.");

  // Not defined on blocks, but rather on components
  params.suppressParameter<std::vector<SubdomainName>>("block");

  // These parameters can be specified if all components have the same values
  params.addParam<std::vector<Real>>(
      "species_initial_pressures",
      {},
      "Initial values for each species. If specified, will be used for every component.");
  params.addParam<std::vector<MooseFunctorName>>(
      "equilibrium_constants",
      "The equilibrium constants between gas partial pressure and adsorbed solute concentration "
      "for each species. Note that they will be scaled using the scaling "
      "parameters specified. If specified, will be used for every component.");

  // Units
  params.addParam<Real>("pressure_unit_scaling", 1, "");
  params.addParam<Real>(
      "length_unit_scaling",
      1,
      "The number of length units in a meter. This allows the user to select length units "
      "other than meters that may lead to better overall scaling of the system.");
  return params;
}

SpeciesSolubilityPhysics::SpeciesSolubilityPhysics(const InputParameters & parameters)
  : SpeciesPhysicsBase(parameters),
    _initial_conditions({getParam<std::vector<Real>>("species_initial_pressures")}),
    _species_Ks({getParam<std::vector<MooseFunctorName>>("equilibrium_constants")}),
    _length_unit(getParam<Real>("length_unit_scaling")),
    _pressure_unit(getParam<Real>("pressure_unit_scaling"))
{
}

void
SpeciesSolubilityPhysics::addComponent(const ActionComponent & component)
{
  // TODO: handle other types of ActionComponents
  // We need some sort of "connectedStructure / connectedComponent ?" concept
  checkComponentType<Enclosure0D>(component);
  const auto & comp = dynamic_cast<const Enclosure0D &>(component);

  // Keep track of the names of the components
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
  processComponentParameters<std::vector<Real>>(
      "species_initial_conditions", comp.name(), _initial_conditions, comp.ics(), false, {});
  processComponentParameters<std::vector<MooseFunctorName>>(
      "equilibrium_constants", comp.name(), _species_Ks, comp.equilibriumConstants(), false, {});
  processComponentParameters<MooseFunctorName>("temperatures",
                                               comp.name(),
                                               _component_temperatures,
                                               std::to_string(comp.temperature()),
                                               false,
                                               "");

  addBlocks(component.blocks());
}

void
SpeciesSolubilityPhysics::addSolverVariables()
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
      params.set<SolverSystemName>("solver_sys") = getSolverSystem(species_name);
      getProblem().addVariable(variable_type, species_name, params);

      // Keep track of variable
      saveSolverVariableName(species_name);
    }
}

void
SpeciesSolubilityPhysics::addInitialConditions()
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
               : ((_initial_conditions.size() == 1) ? _initial_conditions[0][s_j] : 0)) *
          _pressure_unit;
      getProblem().addInitialCondition(ic_type, "IC_" + species_name, params);
    }
}

void
SpeciesSolubilityPhysics::addScalarKernels()
{
  for (const auto c_i : index_range(_components))
  {
    // Get the boundary from the component
    const auto & comp_name = _components[c_i];
    const auto & component = getActionComponent(comp_name);
    const auto & structure_boundary = getConnectedStructureBoundary(comp_name);
    const auto scaled_volume = component.volume() * Utility::pow<3>(_length_unit);
    const auto scaled_area = component.outerSurfaceArea() * Utility::pow<2>(_length_unit);

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

      const auto flux_name = getConnectedStructurePhysics(comp_name)[0]->name() +
                             "_diffusive_flux_" + structure_boundary;
      static constexpr Real kb = 1.380649e-23;
      // m3 to mum3
      static constexpr Real conv_factor = 1e18;

      // Sink term
      {
        const std::string kernel_type = "EnclosureSinkScalarKernel";
        auto params = _factory.getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        // Note the additional minus sign added because the flux is measured outwards
        if (!MooseUtils::parsesToReal(_component_temperatures[c_i]))
          paramError("temperatures", "Only real values are supported");
        params.set<Real>("concentration_to_pressure_conversion_factor") =
            -kb * libMesh::Utility::pow<3>(_length_unit) * std::stod(_component_temperatures[c_i]) *
            _pressure_unit * conv_factor;
        params.set<PostprocessorName>("flux") = flux_name;
        params.set<Real>("surface_area") = scaled_area;
        params.set<Real>("volume") = scaled_volume;
        getProblem().addScalarKernel(kernel_type, species_name + "_enc_sink_sk", params);
      }
    }
  }
}

void
SpeciesSolubilityPhysics::addFEBCs()
{
  for (const auto c_i : index_range(_components))
  {
    const auto & comp_name = _components[c_i];
    // This could be done in the Diffusion/Migration Physics instead
    // That Physics could add this term when coupled to a SpeciesSolubilityPhysics
    const auto & structure_boundary = getConnectedStructureBoundary(comp_name);

    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + comp_name;
      const auto multi_D_species_name = getConnectedStructureVariableName(c_i, s_j);
      {
        const std::string bc_type = "EquilibriumBC";
        auto params = _factory.getValidParams(bc_type);
        params.set<NonlinearVariableName>("variable") = multi_D_species_name;
        params.set<std::vector<VariableName>>("enclosure_var") = {species_name};
        if (getActionComponent(comp_name).blocks().empty())
          mooseError("Should have a block in the component");
        params.set<SubdomainName>("enclosure_block") = getActionComponent(comp_name).blocks()[0];
        params.set<MooseFunctorName>("Ko") = _species_Ks[c_i][s_j];
        params.set<Real>("Ko_scaling_factor") = 1 / Utility::pow<3>(_length_unit) / _pressure_unit;
        params.set<FunctionName>("temperature_function") = _component_temperatures[c_i];
        params.set<std::vector<BoundaryName>>("boundary") = {structure_boundary};
        getProblem().addBoundaryCondition(bc_type, species_name + "_equi_bc", params);
      }
    }
  }
}

void
SpeciesSolubilityPhysics::checkSingleBoundary(const std::vector<BoundaryName> & boundaries,
                                              const ComponentName & comp_name) const
{
  if (boundaries.size() != 1)
    paramError("components",
               "Only implemented for a single boundary and component '" + comp_name + "' has " +
                   std::to_string(boundaries.size()) + " boundaries.");
}

const VariableName &
SpeciesSolubilityPhysics::getConnectedStructureVariableName(unsigned int c_i,
                                                            unsigned int s_j) const
{
  const auto & comp_name = _components[c_i];
  const auto & component = getActionComponent(comp_name);
  const auto multi_D_physics = getConnectedStructurePhysics(comp_name);
  if (multi_D_physics.empty())
    component.paramError("connected_structure",
                         "Connected structure does not have any Physics defined");
  // TODO: handle multiple multi_D_physics being defined
  if (!dynamic_cast<DiffusionPhysicsBase *>(multi_D_physics[0]))
    component.paramError(
        "connected_structure",
        "Connected structure does not have a diffusion Physics defined as its first 'physics'");
  // Note that DiffusionPhysicsBase only support one variable currently
  if (multi_D_physics[0]->solverVariableNames().size() != _species[c_i].size())
    component.paramError(
        "connected_structure",
        "The connected structure does not have the same number of nonlinear variables (" +
            std::to_string(multi_D_physics[0]->solverVariableNames().size()) +
            ") as the number of species (" + std::to_string(_species[c_i].size()) + ")");
  return multi_D_physics[0]->solverVariableNames()[s_j];
}

const BoundaryName &
SpeciesSolubilityPhysics::getConnectedStructureBoundary(const ComponentName & comp_name) const
{
  const auto & component = getActionComponent(comp_name);
  const auto & boundaries = component.outerSurfaceBoundaries();
  checkSingleBoundary(boundaries, comp_name);
  return boundaries[0];
}

const std::vector<PhysicsBase *>
SpeciesSolubilityPhysics::getConnectedStructurePhysics(const ComponentName & comp_name) const
{
  const auto & component = dynamic_cast<const Enclosure0D &>(getActionComponent(comp_name));
  const auto & structure = getActionComponent(component.connectedStructure());
  checkComponentType<Structure1D>(structure);
  return dynamic_cast<const Structure1D &>(structure).getPhysics();
}

void
SpeciesSolubilityPhysics::checkIntegrity() const
{
  for (const auto & vec : _scaling_factors)
    for (const auto scale : vec)
      if (scale <= 0)
        mooseError("Scaling factor '", scale, "' inferior or equal to 0");

  for (const auto & vec : _initial_conditions)
    for (const auto ic : vec)
      if (ic < 0)
        mooseError("Initial condition '", ic, "' inferior to 0");

  for (const auto & vec : _species_Ks)
    for (const auto & K : vec)
      if (MooseUtils::parsesToReal(K) && MooseUtils::convert<Real>(K) <= 0)
        mooseError("Equilibrium constant '", K, "' inferior or equal to 0");

  for (const auto & temp : _component_temperatures)
    if (MooseUtils::parsesToReal(temp) && MooseUtils::convert<Real>(temp) <= 0)
      mooseError("Temperature '", temp, "' inferior or equal to 0");
}
