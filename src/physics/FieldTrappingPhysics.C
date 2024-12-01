//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FieldTrappingPhysics.h"
#include "ActionComponent.h"
#include "MooseUtils.h"

// Register the actions for the objects actually used
registerMooseAction("TMAP8App", FieldTrappingPhysics, "init_physics");
registerMooseAction("TMAP8App", FieldTrappingPhysics, "init_component_physics");
registerMooseAction("TMAP8App", FieldTrappingPhysics, "copy_vars_physics");
registerMooseAction("TMAP8App", FieldTrappingPhysics, "check_integrity_early_physics");
registerMooseAction("TMAP8App", FieldTrappingPhysics, "add_variable");
registerMooseAction("TMAP8App", FieldTrappingPhysics, "add_ic");
registerMooseAction("TMAP8App", FieldTrappingPhysics, "add_kernel");

InputParameters
FieldTrappingPhysics::validParams()
{
  InputParameters params = SpeciesTrappingPhysicsBase::validParams();
  params.addClassDescription(
      "Add Physics for the trapping of species on multi-dimensional components.");
  params.addParam<std::vector<std::vector<VariableName>>>(
      "mobile",
      "The variable(s) representing the mobile concentration(s) of solute species on each "
      "component."
      " If a single vector is specified, the same mobile species are used on each component.");

  params.addParam<bool>("separate_variables_per_component",
                        false,
                        "Whether to create new variables for each trapped species on every "
                        "component, or whether to only create variables.");

  params.addParam<std::vector<std::vector<Real>>>(
      "alpha_t",
      "The trapping rate coefficient for each component and species. This has units of 1/time "
      "(e.g. no number densities are involved)"
      "If a single vector is specified, the same trapping rate coefficient will be used on every "
      "component");
  params.addParam<std::vector<Real>>(
      "N", "The atomic number density of the host material for each component and species.");
  params.addParam<std::vector<FunctionName>>(
      "Ct0", "The fraction of host sites that can contribute to trapping");
  params.addParam<std::vector<Real>>(
      "trap_per_free",
      {1.},
      "An estimate for the ratio of the concentration magnitude of trapped species to free "
      "species for each component. Setting a value for this can be helpful in producing a "
      "well-scaled matrix");

  params.addParam<std::vector<std::vector<Real>>>(
      "alpha_r",
      "The release rate coefficient. If a single vector is specified, "
      "the same release rate coefficient will be used on every component");
  params.addParam<std::vector<std::vector<Real>>>(
      "trapping_energy",
      "The trapping energy in units of Kelvin. If a single vector is specified, "
      "the same trapping energy will be used on every component");

  // Parameter groups
  params.addParamNamesToGroup("alpha_t N Ct0 trap_per_free", "Trapping");
  params.addParamNamesToGroup("alpha_r temperatures trapping_energy", "Release");

  return params;
}

FieldTrappingPhysics::FieldTrappingPhysics(const InputParameters & parameters)
  : SpeciesTrappingPhysicsBase(parameters),
    _mobile_species_names(getParam<std::vector<std::vector<VariableName>>>("mobile")),
    _alpha_ts(getParam<std::vector<std::vector<Real>>>("alpha_t")),
    _Ns(getParam<std::vector<Real>>("N")),
    _Ct0s(getParam<std::vector<FunctionName>>("Ct0")),
    _trap_per_frees(getParam<std::vector<Real>>("trap_per_free")),
    _alpha_rs(getParam<std::vector<std::vector<Real>>>("alpha_r")),
    _trapping_energies(getParam<std::vector<std::vector<Real>>>("trapping_energy")),
    _single_variable_set(!getParam<bool>("separate_variables_per_component"))
{
  // TODO: do this after components have been processed
  if (_components.size())
    _trap_per_frees.resize(_components.size());
  // TODO: check that there is no overlap between names so we don't add kernels multiple times
}

void
FieldTrappingPhysics::addComponent(const ActionComponent & component)
{
  for (const auto & block : component.blocks())
    _blocks.push_back(block);
  _components.push_back(component.name());
  // TODO: add other quantities
  // TODO: check unique

  mooseAssert(_alpha_ts.size() == _components.size(),
              "Wrong alpha_t size (" + std::to_string(_alpha_ts.size()) +
                  ") Components: " + Moose::stringify(_components));
  mooseAssert(_Ns.size() == _components.size(), "Wrong N size");
  mooseAssert(_Ct0s.size() == _components.size(), "Wrong Ct0 size");
  mooseAssert(_trap_per_frees.size() == _components.size(), "Wrong trap per free size");
  mooseAssert(_alpha_rs.size() == _components.size(), "Wrong alpha_r size");
  mooseAssert(_trapping_energies.size() == _components.size(), "Wrong trapping energy size");
  mooseAssert(_component_temperatures.size() == _components.size(), "Wrong temperature size");
}

VariableName
FieldTrappingPhysics::getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const
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
FieldTrappingPhysics::addSolverVariables()
{
  const std::string variable_type = "MooseVariable";
  InputParameters params = getFactory().getValidParams(variable_type);
  params.set<MooseEnum>("family") = "LAGRANGE";
  params.set<MooseEnum>("order") = FIRST;

  for (const auto c_i : index_range(_components))
  {
    for (const auto s_j : index_range(_species[c_i]))
    {
      const auto species_name = getSpeciesVariableName(c_i, s_j);
      params.set<std::vector<Real>>("scaling") = {
          (_scaling_factors.size() > 1)
              ? _scaling_factors[c_i][s_j]
              : ((_scaling_factors.size() == 1) ? _scaling_factors[0][s_j] : 1)};
      getProblem().addVariable(variable_type, species_name, params);
    }
    if (_single_variable_set)
      break;
  }
}

void
FieldTrappingPhysics::addInitialConditions()
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
FieldTrappingPhysics::addFEKernels()
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
        params.set<Real>("detrapping_energy") = _trapping_energies[c_i][s_j];
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
