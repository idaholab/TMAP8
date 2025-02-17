/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "SpeciesTrappingPhysics.h"
#include "ActionComponent.h"
#include "MooseUtils.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "init_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "init_component_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "copy_vars_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "check_integrity_early_physics");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_variable");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_ic");
registerMooseAction("TMAP8App", SpeciesTrappingPhysics, "add_kernel");

InputParameters
SpeciesTrappingPhysics::validParams()
{
  InputParameters params = SpeciesPhysicsBase::validParams();
  params.addClassDescription(
      "Add Physics for the trapping of species on multi-dimensional components.");
  params.addParam<std::vector<VariableName>>(
      "mobile",
      {},
      "The variable(s) representing the mobile concentration(s) of solute species on each "
      "component."
      " If a single vector is specified, the same mobile species are used on each component.");

  params.addParam<bool>("separate_variables_per_component",
                        false,
                        "Whether to create new variables for each trapped species on every "
                        "component, or whether to only create variables.");

  params.addParam<std::vector<Real>>(
      "alpha_t",
      {},
      "The trapping rate coefficient for each component and species. This has units of 1/time "
      "(e.g. no number densities are involved)"
      "If a single vector is specified, the same trapping rate coefficient will be used on every "
      "component");
  params.addParam<std::vector<Real>>(
      "N", {}, "The atomic number density of the host material for each component and species.");
  params.addParam<std::vector<FunctionName>>(
      "Ct0", {}, "The fraction of host sites that can contribute to trapping");

  params.addParam<std::vector<Real>>(
      "alpha_r",
      {},
      "The release rate coefficient. If a single vector is specified, "
      "the same release rate coefficient will be used on every component");
  params.addParam<std::vector<Real>>(
      "detrapping_energy",
      {},
      "The trapping energy in units of Kelvin. If a single vector is specified, "
      "the same trapping energy will be used on every component");

  // Parameter groups
  params.addParamNamesToGroup("alpha_t N Ct0 trap_per_free", "Trapping");
  params.addParamNamesToGroup("alpha_r temperatures detrapping_energy", "Releasing");

  return params;
}

SpeciesTrappingPhysics::SpeciesTrappingPhysics(const InputParameters & parameters)
  : SpeciesPhysicsBase(parameters),
    // If specified in the Physics block, all parameters are retrieved here
    _mobile_species_names({getParam<std::vector<VariableName>>("mobile")}),
    _alpha_ts({getParam<std::vector<Real>>("alpha_t")}),
    _Ns({getParam<std::vector<Real>>("N")}),
    _Ct0s({getParam<std::vector<FunctionName>>("Ct0")}),
    _trap_per_frees({getParam<std::vector<Real>>("trap_per_free")}),
    _alpha_rs({getParam<std::vector<Real>>("alpha_r")}),
    _detrapping_energies({getParam<std::vector<Real>>("detrapping_energy")}),
    _single_variable_set(!getParam<bool>("separate_variables_per_component"))
{
  // We allow overlaps between mobile species names because two trapped species could release to the
  // same mobile species and adding the two time derivative kernels is correct

  // All the other parameters can vary on each component
  if (_single_variable_set)
    checkVectorParamNotEmpty<NonlinearVariableName>("species");

  // Only set the other parameters if setting the species
  checkSecondParamSetOnlyIfFirstOneSet("species", "mobile");
  checkSecondParamSetOnlyIfFirstOneSet("species", "alpha_t");
  checkSecondParamSetOnlyIfFirstOneSet("species", "N");
  checkSecondParamSetOnlyIfFirstOneSet("species", "Ct0");
  checkSecondParamSetOnlyIfFirstOneSet("species", "trap_per_free");
  checkSecondParamSetOnlyIfFirstOneSet("species", "alpha_r");
  checkSecondParamSetOnlyIfFirstOneSet("species", "detrapping_energy");

  // Check sizes
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, VariableName>("species", "mobile");
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "alpha_t");
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "N");
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, FunctionName>("species", "Ct0");
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "trap_per_free");
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "alpha_r");
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>("species", "detrapping_energy");
}

void
SpeciesTrappingPhysics::addComponent(const ActionComponent & component)
{
  for (const auto & block : component.blocks())
    _blocks.push_back(block);
  _components.push_back(component.name());
}

VariableName
SpeciesTrappingPhysics::getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const
{
  mooseAssert(c_i < _species.size(), "component index higher than number of components");
  mooseAssert(s_j < _species[c_i].size(), "species index higher than number of species");
  if (_single_variable_set)
    return _species[0][s_j];
  else
    // Add the component name if defining variables on a component-basis
    return _species[c_i][s_j] + "_" + _components[c_i];
}

void
SpeciesTrappingPhysics::addSolverVariables()
{
  const std::string variable_type = "MooseVariable";
  InputParameters params = getFactory().getValidParams(variable_type);
  params.set<MooseEnum>("family") = "LAGRANGE";
  params.set<MooseEnum>("order") = FIRST;

  for (const auto c_i : index_range(_components))
  {
    assignBlocks(params, getActionComponent(_components[c_i]).blocks());
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      params.set<std::vector<Real>>("scaling") = {
          (_scaling_factors.size() > 1)
              ? _scaling_factors[c_i][s_j]
              : ((_scaling_factors.size() == 1) ? _scaling_factors[0][s_j] : 1)};
      params.set<SolverSystemName>("solver_sys") = getSolverSystem(species_name);
      getProblem().addVariable(variable_type, species_name, params);

      // Keep track of variables
      saveSolverVariableName(species_name);
    }
    if (_single_variable_set)
      break;
  }
}

void
SpeciesTrappingPhysics::addInitialConditions()
{
  const std::string ic_type = "ConstantIC";
  InputParameters params = getFactory().getValidParams(ic_type);

  for (const auto c_i : index_range(_components))
  {
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      params.set<VariableName>("variable") = species_name;
      params.set<Real>("value") =
          ((_initial_conditions.size() > 1)
               ? _initial_conditions[c_i][s_j]
               : ((_initial_conditions.size() == 1) ? _initial_conditions[0][s_j] : 0));
      getProblem().addInitialCondition(ic_type, "IC_" + species_name, params);
    }
    if (_single_variable_set)
      break;
  }
}

void
SpeciesTrappingPhysics::addFEKernels()
{
  for (const auto c_i : index_range(_components))
  {
    // Create the kernel for each species
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      const auto mobile_species_name = _mobile_species_names[c_i][s_j];

      // Time derivative
      if (isTransient())
      {
        const std::string kernel_type = "TimeDerivativeNodalKernel";
        InputParameters params = getFactory().getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        getProblem().addNodalKernel(kernel_type, prefix() + species_name + "_time", params);
      }

      // Trapping term
      {
        const std::string kernel_type = "TrappingNodalKernel";
        auto params = _factory.getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        params.set<std::vector<VariableName>>("mobile_concentration") = {mobile_species_name};
        mooseAssert(c_i < _component_temperatures.size(), "Should not happen");
        params.set<std::vector<VariableName>>("temperature") = {
            VariableName(_component_temperatures[c_i])};
        params.set<Real>("alpha_t") = _alpha_ts[c_i][s_j];
        params.set<Real>("N") = _Ns[c_i];
        params.set<FunctionName>("Ct0") = _Ct0s[c_i];
        params.set<Real>("trap_per_free") = _trap_per_frees[c_i];

        // Add the other species as occupying traps
        std::vector<VariableName> copy_species;
        for (const auto & sp_name : _species[c_i])
          if (sp_name != species_name)
            copy_species.push_back(sp_name);
        params.set<std::vector<VariableName>>("other_trapped_concentration_variables") =
            copy_species;

        getProblem().addNodalKernel(kernel_type, species_name + "_enc_trapping", params);
      }

      // Release term
      {
        const std::string kernel_type = "ReleasingNodalKernel";
        auto params = _factory.getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = species_name;
        params.set<Real>("alpha_r") = _alpha_rs[c_i][s_j];
        params.set<Real>("detrapping_energy") = _detrapping_energies[c_i][s_j];
        // The default coupled value will not have been created by the Builder since we created
        // the parameter as a MooseFunctorName in the Physics
        if (MooseUtils::parsesToReal(_component_temperatures[c_i]))
        {
          std::istringstream ss(_component_temperatures[c_i]);
          Real value;
          ss >> value;
          params.defaultCoupledValue("temp", value, 0);
          params.set<std::vector<VariableName>>("temperature") = {};
        }
        else
          params.set<std::vector<VariableName>>("temperature") = {_component_temperatures[c_i]};

        getProblem().addNodalKernel(kernel_type, species_name + "_enc_release", params);
      }

      // Release term in the mobile species conservation equation
      {
        const std::string kernel_type = "CoupledTimeDerivative";
        auto params = _factory.getValidParams(kernel_type);
        params.set<NonlinearVariableName>("variable") = mobile_species_name;
        params.set<std::vector<VariableName>>("v") = {species_name};

        getProblem().addKernel(kernel_type, mobile_species_name + "_from_" + species_name, params);
      }
    }
    if (_single_variable_set)
      break;
  }
}
