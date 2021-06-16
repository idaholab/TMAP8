/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "Enclosure0D.h"
#include "TMAPUtils.h"

registerMooseObject("TMAPApp", Enclosure0D);

InputParameters
Enclosure0D::validParams()
{
  auto params = Component::validParams();
  params += TMAP::enclosureCommonParams();
  return params;
}

Enclosure0D::Enclosure0D(const InputParameters & params)
  : Component(params),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _scaling_factors(isParamValid("species_scaling_factors")
                         ? getParam<std::vector<Real>>("species_scaling_factors")
                         : std::vector<Real>(_species.size(), 1)),
    _ics(isParamValid("species_initial_pressures")
             ? getParam<std::vector<Real>>("species_initial_pressures")
             : std::vector<Real>()),
    _temperature(getParam<Real>("temperature")),
    _length_unit(getParam<Real>("length_unit")),
    _pressure_unit(getParam<Real>("pressure_unit")),
    _surface_area(getParam<Real>("surface_area")),
    _volume(getParam<Real>("volume"))
{
  for (auto & specie : _species)
    specie += ("_" + name());

  if (_species.size() != _scaling_factors.size())
    paramError("species_scaling_factors",
               "The number of species scaling factors must match the number of species.");

  if (_ics.size() && (_ics.size() != _species.size()))
    paramError("species_initial_pressures",
               "The number of species partial pressures must match the number of species.");
}
