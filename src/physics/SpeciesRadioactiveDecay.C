/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "SpeciesRadioactiveDecay.h"
#include "ActionComponent.h"
#include "MooseUtils.h"
#include "FEProblemBase.h"

// Component interaction
#include "Enclosure0D.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "init_physics");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "init_component_physics");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "copy_vars_physics");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "check_integrity");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "check_integrity_early_physics");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "add_variable");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "add_ic");
registerMooseAction("TMAP8App", SpeciesRadioactiveDecay, "add_kernel");

InputParameters
SpeciesRadioactiveDecay::validParams()
{
  InputParameters params = SpeciesPhysicsBase::validParams();
  params.addClassDescription("Add Physics for the radioactive decay of species.");

  params.addParam<bool>("separate_variables_per_component",
                        false,
                        "Whether to create new variables for each trapped species on every "
                        "component, or whether to only create variables.");

  // Manual input of decay products, constants and branching ratios
  // We could consider just loading a file from ENDF!
  params.addParam<std::vector<std::vector<std::vector<VariableName>>>>(
      "decay_products",
      {},
      "Decay products. Use '|' to separate inputs for each decaying species. Use ';' to separate "
      "each decay reaction for a given species. Use 'NA' "
      "if tracking the product is not desired. If specified in the Physics, applies to every "
      "component.");
  params.addParam<std::vector<std::vector<Real>>>(
      "decay_constants",
      {},
      "The decay constants for each decay reaction. Use ';' to separate input for each decaying "
      "species. If specified in the Physics, applies to every component.");
  params.addParam<std::vector<std::vector<Real>>>(
      "branching_ratios",
      {},
      "Branching ratios. Use ';' to separate inputs for each decay reaction within each decaying "
      "species. Defaults to 1 if not specified for a given species "
      "or group. If specified in the Physics, applies to every component.");

  params.addRequiredParam<bool>(
      "add_decaying_species_initial_conditions",
      "Whether to set initial conditions from this Physics for the decaying species. This should "
      "be set to false if another Physics is already defining the initial conditions");

  return params;
}

SpeciesRadioactiveDecay::SpeciesRadioactiveDecay(const InputParameters & parameters)
  : SpeciesPhysicsBase(parameters),
    // If specified in the Physics block, all parameters are retrieved here
    _decay_products(
        {getParam<std::vector<std::vector<std::vector<VariableName>>>>("decay_products")}),
    _decay_constants({getParam<std::vector<std::vector<Real>>>("decay_constants")}),
    _branching_ratios({getParam<std::vector<std::vector<Real>>>("branching_ratios")}),
    _single_variable_set(!getParam<bool>("separate_variables_per_component")),
    _add_initial_conditions(getParam<bool>("add_decaying_species_initial_conditions"))
{
  // All the other parameters can vary on each component
  if (_single_variable_set)
    checkVectorParamNotEmpty<NonlinearVariableName>("species");
  if (!_add_initial_conditions)
    errorDependentParameter("add_initial_condition", "true", {"species_initial_concentrations"});

  // Only set the other parameters if setting the species
  checkSecondParamSetOnlyIfFirstOneSet("species", "decay_products");
  checkSecondParamSetOnlyIfFirstOneSet("species", "decay_constants");
  checkSecondParamSetOnlyIfFirstOneSet("species", "branching_ratios");

  // Check sizes
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, MooseFunctorName>(
      "species", "species_initial_concentrations", /*ignore_empty_second*/ true);
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, std::vector<Real>>(
      "species", "decay_constants", true);
  // TODO: add a 3D vector check to the input parameter check util
  if (isParamSetByUser("branching_ratios"))
    checkTwoDVectorParamsSameLength<std::vector<VariableName>, Real>("decay_products",
                                                                     "branching_ratios");
  checkTwoDVectorParamsSameLength<std::vector<VariableName>, Real>("decay_products",
                                                                   "decay_constants");
}

void
SpeciesRadioactiveDecay::addComponent(const ActionComponent & component)
{
  for (const auto & block : component.blocks())
    _blocks.push_back(block);
  _components.push_back(component.name());

  // Index of the component in all the component-indexed vectors
  const auto comp_index = _components.size() - 1;

  // Process each of the component's parameters, adding defaults to avoid breaking the double-vector
  // indexing when acceptable
  // These parameters are known to be defined for a Structure1D, so we retrieve them from the
  // component's parameters. If they are not defined on the Physics or the component, we error
  processComponentParameters<std::vector<NonlinearVariableName>>(
      "species", component.name(), comp_index, _species, "species", false, {});
  processComponentParameters<std::vector<Real>>("species_scaling_factors",
                                                component.name(),
                                                comp_index,
                                                _scaling_factors,
                                                "species_scaling_factors",
                                                true,
                                                std::vector<Real>(_species[comp_index].size(), 1));
  processComponentParameters<std::vector<MooseFunctorName>>("species_initial_concentrations",
                                                            component.name(),
                                                            comp_index,
                                                            _initial_conditions,
                                                            "species_initial_concentrations",
                                                            false,
                                                            {});

  // We dont support Enclosures yet
  if (dynamic_cast<const Enclosure0D *>(&component))
    mooseError("This Physics has not been implemented for 0D enclosures");
  mooseWarning(
      "Processing parameters from Components has not been implemented yet for this Physics");

  // These parameters should be defined as material properties by the user on the Component
  // or on the Physics.
  // We only support Real numbers for now as the consuming kernels only support Real
  // TODO: decay constants, branching ratios and decay products
  // processComponentMatprop<std::vector<Real>>(
  //     "decay_constants", component, comp_index, _species.back(), _decay_constants);
}

VariableName
SpeciesRadioactiveDecay::getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const
{
  mooseAssert(c_i < _species.size(), "component index higher than number of components");
  mooseAssert(s_j < _species[c_i].size(), "species index higher than number of species");
  if (_single_variable_set)
    return _species[0][s_j];
  else
    // Add the component name if defining variables on a per-component basis
    return _species[c_i][s_j] + "_" + _components[c_i];
}

void
SpeciesRadioactiveDecay::addSolverVariables()
{
  // TODO: this should be a scalar variable for a 0D component

  const std::string variable_type = "MooseVariable";
  InputParameters params = getFactory().getValidParams(variable_type);
  params.set<MooseEnum>("family") = "LAGRANGE";
  params.set<MooseEnum>("order") = FIRST;

  // Allow using blocks even with the loops on components
  if (_components.empty())
  {
    if (_single_variable_set)
    {
      _components.push_back("");
      if (_species[0].empty())
        paramError("species", "Should not be empty if not using Components");
      if (_scaling_factors[0].empty())
        _scaling_factors[0] = std::vector<Real>(_species.size(), 1);
    }
    else
      paramError("separate_variables_per_component",
                 "Physics is not defined on any Component, this parameter should be set to false");
  }
  else
  {
    // Check component-indexed parameters
    checkSizeComponentSpeciesIndexedVectorOfVector(
        _scaling_factors, "species_scaling_factors", true);
    checkSizeComponentSpeciesIndexedVectorOfVector(_decay_products, "decay_products", true);
  }

  for (const auto c_i : index_range(_components))
  {
    // Use the whole phyiscs block restriction if using the same species variable everywhere
    if (_single_variable_set)
      assignBlocks(params, _blocks);
    else
      assignBlocks(params, getActionComponent(_components[c_i]).blocks());

    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      if (isParamSetByUser("species_scaling_factor") || !_single_variable_set)
        params.set<std::vector<Real>>("scaling") = {
            (_scaling_factors.size() > 1)
                ? _scaling_factors[c_i][s_j]
                : ((_scaling_factors.size() == 1) ? _scaling_factors[0][s_j] : 1)};
      params.set<SolverSystemName>("solver_sys") = getSolverSystem(species_name);

      // TODO: add a check in PhysicsBase for avoiding defining variables with different scaling
      // factors from multiple Physics Species is already likely added by another Physics
      if (!getProblem().hasVariable(species_name))
        getProblem().addVariable(variable_type, species_name, params);

      // Keep track of variables
      saveSolverVariableName(species_name);
    }
    if (_single_variable_set)
      break;
  }
}

void
SpeciesRadioactiveDecay::addInitialConditions()
{
  if (!_add_initial_conditions)
    return;

  const std::string ic_type = "FunctorIC";
  InputParameters params = getFactory().getValidParams(ic_type);

  // Check component-indexed parameters
  if (_components.size())
    checkSizeComponentSpeciesIndexedVectorOfVector(
        _initial_conditions, "species_initial_concentrations", true);

  for (const auto c_i : index_range(_components))
  {
    // Use the whole phyiscs block restriction if using the same species variable everywhere
    if (_single_variable_set)
      if (isParamSetByUser("species_initial_concentrations"))
        assignBlocks(params, _blocks);
      else
        break;
    else
      assignBlocks(params, getActionComponent(_components[c_i]).blocks());

    // Decaying species
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      params.set<VariableName>("variable") = species_name;
      params.set<MooseFunctorName>("functor") =
          ((_initial_conditions.size() > 1)
               ? _initial_conditions[c_i][s_j]
               : ((_initial_conditions.size() == 1) ? _initial_conditions[0][s_j] : "0"));

      // TODO: add a check in PhysicsBase for avoiding defining variables with different initial
      // conditions from multiple Physics. The species IC is already likely added by another Physics
      if (_add_initial_conditions)
        getProblem().addInitialCondition(
            ic_type, "IC_" + species_name + "_" + Moose::stringify(_blocks), params);
    }
    // TODO: create product species if they dont exist

    if (_single_variable_set)
      break;
  }
}

void
SpeciesRadioactiveDecay::addFEKernels()
{
  // Prefill branching ratios with 1s if it is not specified
  if (_single_variable_set)
    if (!isParamSetByUser("branching_ratios"))
    {
      std::cout << "Resizing " << std::endl;
      _branching_ratios.resize(_decay_products.size());
      for (const auto i_c : index_range(_decay_products))
      {
        std::cout << "Resizing for species " << _decay_products[i_c].size() << std::endl;
        _branching_ratios[i_c].resize(_decay_products[i_c].size());
        for (const auto i_s : index_range(_decay_products[i_c]))
        {
          _branching_ratios[i_c][i_s].resize(_decay_products[i_c][i_s].size(), 1.);
        }
      }
    }

  // Check component-indexed parameters
  checkSizeComponentSpeciesIndexedVectorOfVector(_decay_products, "decay_products", true);
  checkSizeComponentSpeciesIndexedVectorOfVector(_decay_constants, "decay_constants", true);
  checkSizeComponentSpeciesIndexedVectorOfVector(_branching_ratios, "branching_ratios", true);

  for (const auto c_i : index_range(_components))
  {
    // Use the whole phyiscs block restriction if using the same species variable everywhere
    const auto blocks =
        _single_variable_set ? _blocks : getActionComponent(_components[c_i]).blocks();
    const auto & comp_name = _components[c_i];

    // Create the kernel for each species
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);

      // Time derivative
      if (isTransient())
      {
        // TODO: add volumetric discretization option
        const std::string kernel_type = "TimeDerivativeNodalKernel";
        InputParameters params = getFactory().getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        assignBlocks(params, blocks);
        // TODO: add a check in PhysicsBase for avoiding defining time derivatives for variable from
        // multiple Physics on the same blocks, as this term is already likely added by another
        // Physics
        getProblem().addNodalKernel(
            kernel_type, prefix() + comp_name + "_" + species_name + "_time", params);
      }

      // Decay reactions for each species
      for (const auto & r_k : index_range(_decay_products[c_i][s_j]))
      {
        /* Decay of species */
        // TODO: add volumetric discretization option
        const std::string kernel_type = "ReactionNodalKernel";
        auto params = _factory.getValidParams(kernel_type);
        assignBlocks(params, blocks);
        params.set<NonlinearVariableName>("variable") = species_name;
        params.set<Real>("coeff") = _decay_constants[c_i][s_j][r_k];

        // Name should be unique
        getProblem().addNodalKernel(kernel_type,
                                    prefix() + comp_name + "_" + species_name + "_decay_to_" +
                                        Moose::stringify(_decay_products[c_i][s_j][r_k]),
                                    params);

        /* Production of species */
        for (const auto & p_l : index_range(_decay_products[c_i][s_j][r_k]))
        {
          // TODO: add volumetric discretization option
          const std::string kernel_type = "CoupledForceNodalKernel";
          auto params = _factory.getValidParams(kernel_type);
          params.set<NonlinearVariableName>("variable") = _decay_products[c_i][s_j][r_k][p_l];
          params.set<std::vector<VariableName>>("v") = {species_name};
          params.set<Real>("coef") =
              _branching_ratios[c_i][s_j][r_k] * _decay_constants[c_i][s_j][r_k];

          // Add indices to be sure the name is unique
          getProblem().addNodalKernel(kernel_type,
                                      prefix() + comp_name + "_production_of_" +
                                          _decay_products[c_i][s_j][r_k][p_l] + "_from_decay_of_" +
                                          species_name + std::to_string(s_j) + "_" +
                                          std::to_string(r_k) + "_" + std::to_string(p_l),
                                      params);
        }
      }
    }
    if (_single_variable_set)
      break;
  }
}
