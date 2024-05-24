//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SpeciesTrappingPhysicsBase.h"
#include "MooseUtils.h"

InputParameters
SpeciesTrappingPhysicsBase::validParams()
{
  InputParameters params = PhysicsBase::validParams();
  params.addClassDescription(
      "Base class for Physics modeling the trapping of species on components.");

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
  params.addParam<std::vector<MooseFunctorName>>("temperatures", "Temperatures for each enclosure component");
  return params;
}

SpeciesTrappingPhysicsBase::SpeciesTrappingPhysicsBase(const InputParameters & parameters)
  : PhysicsBase(parameters),
    _components(getParam<std::vector<ComponentName>>("components")),
    _species(getParam<std::vector<std::vector<NonlinearVariableName>>>("species")),
    _scaling_factors(getParam<std::vector<std::vector<Real>>>("species_scaling_factors")),
    _initial_conditions(getParam<std::vector<std::vector<Real>>>("species_initial_pressures")),
    _component_temperatures(getParam<std::vector<MooseFunctorName>>("temperatures"))
{
  // Fill in the species vector of vectors for convenience
  // TODO: do this later so we can turn on this Physics from a component
  if (_species.size() == 1 && _components.size())
    _species.resize(_components.size(), _species[0]);
  // The initial conditions and scaling double-vectors use logic to work with a size 1 vector

  // TODO: check that the components actually exists
  // TODO: choose input from components or input from Physics
}
