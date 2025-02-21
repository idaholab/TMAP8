/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

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
  // Cant add kernels twice to the same species
  checkVectorParamsNoOverlap<NonlinearVariableName>({"species"});

  // Check sizes
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>(
      "species", "species_scaling_factors", /*ignore_empty_second*/ true);
}
