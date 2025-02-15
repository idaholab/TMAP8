//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SpeciesPhysicsBase.h"
#include "MooseUtils.h"

InputParameters
SpeciesPhysicsBase::validParams()
{
  InputParameters params = PhysicsBase::validParams();
  params.addClassDescription(
      "Base class for Physics modeling the trapping of species on components.");

  // These parameters can be specified if all components have the same values
  params.addParam<std::vector<NonlinearVariableName>>(
      "species",
      {},
      "Species that can be trapped on each component. If a single vector is specified, the same "
      "species will be used on every component");
  params.addParam<std::vector<Real>>(
      "species_scaling_factors",
      {},
      "Scaling factors for each species equation on each component. If specified, the same scaling "
      "factors will be used on every component");
  params.addParam<MooseFunctorName>("temperature",
                                    {},
                                    "Functor providing the temperature. If specified, the same "
                                    "functor is used on every component");

  return params;
}

SpeciesPhysicsBase::SpeciesPhysicsBase(const InputParameters & parameters)
  : PhysicsBase(parameters),
    _species({getParam<std::vector<NonlinearVariableName>>("species")}),
    _scaling_factors({getParam<std::vector<Real>>("species_scaling_factors")}),
    _component_temperatures({getParam<MooseFunctorName>("temperature")})
{
}
