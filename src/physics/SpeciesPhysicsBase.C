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
  params.addParam<std::vector<MooseFunctorName>>(
      "species_initial_concentrations",
      {},
      "Initial values for each species. If specified, will be used for every component.");
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
    _initial_conditions(
        {getParam<std::vector<MooseFunctorName>>("species_initial_concentrations")}),
    _component_temperatures({getParam<MooseFunctorName>("temperature")})
{
  addRequiredPhysicsTask("check_integrity");
  addRequiredPhysicsTask("add_variable");
  addRequiredPhysicsTask("add_ic");

  // Cant add kernels twice to the same species
  checkVectorParamsNoOverlap<NonlinearVariableName>({"species"});

  // Check sizes
  checkVectorParamsSameLengthIfSet<NonlinearVariableName, Real>(
      "species", "species_scaling_factors", /*ignore_empty_second*/ true);
}

void
SpeciesPhysicsBase::checkIntegrity() const
{
  // No need to check scaling factors, range checked in parameters in both components and Physics

  for (const auto i : index_range(_initial_conditions))
    for (const auto j : index_range(_initial_conditions[i]))
      if (MooseUtils::parsesToReal(_initial_conditions[i][j]) &&
          MooseUtils::convert<Real>(_initial_conditions[i][j]) < 0)
        mooseError("Initial condition '",
                   _initial_conditions[i][j],
                   "' for species '",
                   _species[i][j],
                   "'",
                   getOnComponentString(i),
                   " inferior to 0");

  for (const auto i : index_range(_component_temperatures))
  {
    const auto temp = _component_temperatures[i];
    if (MooseUtils::parsesToReal(temp) && MooseUtils::convert<Real>(temp) <= 0)
      mooseError("Temperature '", temp, "'", getOnComponentString(i), " inferior or equal to 0");
  }
}

std::string
SpeciesPhysicsBase::getOnComponentString(unsigned int comp_index) const
{
  // Get the name of the component for an error
  if (_components.empty())
    return "";
  else
    return " on component '" + _components[comp_index] + "'";
}
