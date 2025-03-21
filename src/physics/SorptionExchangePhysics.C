/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "SorptionExchangePhysics.h"
#include "MooseUtils.h"
#include "ActionComponent.h"
#include "Enclosure0D.h"

// For connecting to multi-D diffusion on other components
#include "Structure1D.h"
#include "DiffusionPhysicsBase.h"
#include "ComponentPhysicsInterface.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", SorptionExchangePhysics, "init_physics");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "add_variable");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "add_ic");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "add_scalar_kernel");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "add_bc");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "check_integrity_early_physics");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "check_integrity");
registerMooseAction("TMAP8App", SorptionExchangePhysics, "copy_vars_physics");

InputParameters
SorptionExchangePhysics::validParams()
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

SorptionExchangePhysics::SorptionExchangePhysics(const InputParameters & parameters)
  : SpeciesPhysicsBase(parameters),
    _initial_conditions({getParam<std::vector<Real>>("species_initial_pressures")}),
    _species_Ks({getParam<std::vector<MooseFunctorName>>("equilibrium_constants")}),
    _length_unit(getParam<Real>("length_unit_scaling")),
    _pressure_unit(getParam<Real>("pressure_unit_scaling"))
{
  // Check sizes, though some parameters may be set on components
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>(
      "species", "species_initial_pressures", true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, MooseFunctorName>(
      "species", "equilibrium_constants", true);
}

void
SorptionExchangePhysics::addComponent(const ActionComponent & component)
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
  // Index of the component in all the component-indexed vectors
  const auto comp_index = _components.size() - 1;

  // Process each of the component's parameters, adding defaults to avoid breaking the double-vector
  // indexing when needed
  processComponentValues<std::vector<NonlinearVariableName>>(
      "species", comp.name(), comp_index, _species, comp.species(), false, {});
  processComponentValues<std::vector<Real>>("species_scaling_factors",
                                            comp.name(),
                                            comp_index,
                                            _scaling_factors,
                                            comp.scalingFactors(),
                                            true,
                                            std::vector<Real>(1, n_species_component));
  processComponentValues<std::vector<Real>>("species_initial_pressures",
                                            comp.name(),
                                            comp_index,
                                            _initial_conditions,
                                            comp.ics(),
                                            false,
                                            {});
  processComponentValues<std::vector<MooseFunctorName>>("equilibrium_constants",
                                                        comp.name(),
                                                        comp_index,
                                                        _species_Ks,
                                                        comp.equilibriumConstants(),
                                                        false,
                                                        {});
  processComponentValues<MooseFunctorName>("temperatures",
                                           comp.name(),
                                           comp_index,
                                           _component_temperatures,
                                           comp.temperature(),
                                           false,
                                           "");

  addBlocks(component.blocks());
}

void
SorptionExchangePhysics::addSolverVariables()
{
  const std::string variable_type = "MooseVariableScalar";
  InputParameters params = getFactory().getValidParams(variable_type);
  params.set<MooseEnum>("family") = "SCALAR";
  params.set<MooseEnum>("order") = FIRST;

  // Check component-indexed parameters
  checkSizeComponentSpeciesIndexedVectorOfVector(_scaling_factors, "species_scaling_factors", true);

  for (const auto c_i : index_range(_components))
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + _components[c_i];
      // Set a default of 1, if the scaling factors are incomplete
      params.set<std::vector<Real>>("scaling") = {
          (_scaling_factors.size() > 1)
              ? _scaling_factors[c_i][s_j]
              : ((_scaling_factors.size() == 1 && s_j < _scaling_factors[0].size())
                     ? _scaling_factors[0][s_j]
                     : 1)};
      params.set<SolverSystemName>("solver_sys") = getSolverSystem(species_name);
      getProblem().addVariable(variable_type, species_name, params);

      // Keep track of variable
      saveSolverVariableName(species_name);
    }
}

void
SorptionExchangePhysics::addInitialConditions()
{
  const std::string ic_type = "ScalarConstantIC";
  InputParameters params = getFactory().getValidParams(ic_type);

  // Check component-indexed parameters
  checkSizeComponentSpeciesIndexedVectorOfVector(
      _initial_conditions, "species_initial_pressures", true);

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
SorptionExchangePhysics::addScalarKernels()
{
  // Check component-indexed parameters
  checkSizeComponentIndexedVector(_component_temperatures, "temperature", false);

  // Loop over enclosures (for now only component supported)
  for (const auto c_i : index_range(_components))
  {
    // Get the boundary from the component
    const auto & enc_name = _components[c_i];
    const auto & component = getActionComponent(enc_name);

    // Create the kernels for each species' equation
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

      for (const auto & connected_name : getConnectedStructures(enc_name))
      {
        const auto & structure_boundary = getConnectedStructureBoundary(enc_name, connected_name);
        const auto scaled_volume = component.volume() * Utility::pow<3>(_length_unit);
        const auto scaled_area = getConnectedStructureConnectionArea(enc_name, connected_name) *
                                 Utility::pow<2>(_length_unit);

        // This is hard-coding a convention for the name of the flux PP. The Physics creating this
        // flux PP must match this same convention.
        const auto flux_name =
            getConnectedStructurePhysics(connected_name, _species[c_i][s_j])->name() +
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
              -kb * libMesh::Utility::pow<3>(_length_unit) *
              std::stod(_component_temperatures[c_i]) * _pressure_unit * conv_factor;
          params.set<PostprocessorName>("flux") = flux_name;
          params.set<Real>("surface_area") = scaled_area;
          params.set<Real>("volume") = scaled_volume;
          getProblem().addScalarKernel(kernel_type, species_name + "_enc_sink_sk", params);
        }
      }
    }
  }
}

void
SorptionExchangePhysics::addFEBCs()
{
  // Check component-indexed parameters
  checkSizeComponentIndexedVector(_component_temperatures, "temperature", false);
  checkSizeComponentSpeciesIndexedVectorOfVector(_species_Ks, "equilibrium_constants", false);

  for (const auto c_i : index_range(_components))
  {
    const auto & comp_name = _components[c_i];

    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = _species[c_i][s_j] + "_" + comp_name;

      for (const auto & connected_name : getConnectedStructures(comp_name))
      {
        // This could be done in the Diffusion/Migration Physics instead
        // That Physics could add this term when coupled to a SorptionExchangePhysics
        const auto & structure_boundary = getConnectedStructureBoundary(comp_name, connected_name);
        const auto multi_D_species_name =
            getConnectedStructureVariableName(c_i, connected_name, s_j);

        {
          const std::string bc_type = "EquilibriumBC";
          auto params = _factory.getValidParams(bc_type);
          params.set<NonlinearVariableName>("variable") = multi_D_species_name;
          params.set<std::vector<VariableName>>("enclosure_var") = {species_name};
          if (getActionComponent(comp_name).blocks().empty())
            mooseError("Should have a block in the component");
          params.set<SubdomainName>("enclosure_block") = getActionComponent(comp_name).blocks()[0];
          params.set<MooseFunctorName>("Ko") = _species_Ks[c_i][s_j];
          params.set<Real>("Ko_scaling_factor") =
              1 / Utility::pow<3>(_length_unit) / _pressure_unit;
          params.set<FunctionName>("temperature_function") = _component_temperatures[c_i];
          params.set<std::vector<BoundaryName>>("boundary") = {structure_boundary};
          getProblem().addBoundaryCondition(bc_type, species_name + "_equi_bc", params);
        }
      }
    }
  }
}

void
SorptionExchangePhysics::checkSingleBoundary(const std::vector<BoundaryName> & boundaries,
                                             const ComponentName & comp_name) const
{
  if (boundaries.size() != 1)
    paramError("components",
               "Only implemented for a single boundary and component '" + comp_name + "' has " +
                   std::to_string(boundaries.size()) + " boundaries.");
}

const std::vector<ComponentName> &
SorptionExchangePhysics::getConnectedStructures(const MooseFunctorName & enc_name) const
{
  // Only 0D enclosure supported at this time
  checkComponentType<Enclosure0D>(getActionComponent(enc_name));
  const auto & component = dynamic_cast<const Enclosure0D *>(&getActionComponent(enc_name));
  return component->connectedStructures();
}

const VariableName &
SorptionExchangePhysics::getConnectedStructureVariableName(unsigned int c_i,
                                                           const ComponentName & connected_struct,
                                                           unsigned int s_j) const
{
  const auto & comp_name = _components[c_i];
  const auto & component = getActionComponent(comp_name);
  const auto multi_D_physics = getConnectedStructurePhysics(connected_struct, _species[c_i][s_j]);

  // TODO: handle multiple multi_D_physics being defined with the same variable.
  if (!dynamic_cast<DiffusionPhysicsBase *>(multi_D_physics))
    component.paramError(
        "connected_structure",
        "Connected structure does not have a diffusion Physics defined as its first 'physics'");
  // Note that DiffusionPhysicsBase only support one variable currently
  if (multi_D_physics->solverVariableNames().size() != _species[c_i].size())
    component.paramError(
        "connected_structure",
        "The connected structure does not have the same number of nonlinear variables (" +
            std::to_string(multi_D_physics->solverVariableNames().size()) +
            ") as the number of species (" + std::to_string(_species[c_i].size()) + ")");
  return multi_D_physics->solverVariableNames()[s_j];
}

const BoundaryName &
SorptionExchangePhysics::getConnectedStructureBoundary(
    const ComponentName & comp_name, const ComponentName & connected_structure_name) const
{
  // Only 0D enclisure supported at this time
  checkComponentType<Enclosure0D>(getActionComponent(comp_name));
  const auto & component = dynamic_cast<const Enclosure0D *>(&getActionComponent(comp_name));
  const auto & boundary = component->connectedStructureBoundary(connected_structure_name);
  return boundary;
}

Real
SorptionExchangePhysics::getConnectedStructureConnectionArea(
    const ComponentName & comp_name, const ComponentName & connected_structure_name) const
{
  // Only 0D enclisure supported at this time
  checkComponentType<Enclosure0D>(getActionComponent(comp_name));
  const auto & component = dynamic_cast<const Enclosure0D *>(&getActionComponent(comp_name));
  const auto boundary_area = component->connectedStructureBoundaryArea(connected_structure_name);
  return boundary_area;
}

const std::vector<PhysicsBase *>
SorptionExchangePhysics::getConnectedStructurePhysics(
    const ComponentName & connected_structure_name) const
{
  const auto & structure = getActionComponent(connected_structure_name);
  // Only 1D structure supported at this time
  checkComponentType<Structure1D>(structure);
  return dynamic_cast<const Structure1D &>(structure).getPhysics();
}

PhysicsBase *
SorptionExchangePhysics::getConnectedStructurePhysics(
    const ComponentName & connected_structure_name, const VariableName & species_name) const
{
  const auto & structure = getActionComponent(connected_structure_name);
  checkComponentType<ComponentPhysicsInterface>(structure);
  const auto & structure_physics =
      dynamic_cast<const ComponentPhysicsInterface &>(structure).getPhysics();

  // Check the physics defined for a variable with the same name as the species
  for (const auto & physics : structure_physics)
  {
    const auto & solver_vars = physics->solverVariableNames();
    if (std::find(solver_vars.begin(), solver_vars.end(), species_name) != solver_vars.end())
      return physics;

    const auto & aux_vars = physics->auxVariableNames();
    if (std::find(aux_vars.begin(), aux_vars.end(), species_name) != aux_vars.end())
      return physics;
  }

  // If a single physics with a single variable, no ambiguity either
  if (structure_physics.size() == 1 && structure_physics[0]->solverVariableNames().size() == 1)
    return structure_physics[0];

  // No obvious connection, just error
  // TODO: add a parameter to indicate which species to connect to
  mooseError("On connected structure '",
             connected_structure_name,
             "', it was not clear in what equation the release term for species '",
             species_name,
             "' should be added. Use the species name as the variable name on the relevant "
             "Physics.");
}

void
SorptionExchangePhysics::checkIntegrity() const
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
