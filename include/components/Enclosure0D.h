/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "Component.h"

class Enclosure0D : public Component
{
public:
  Enclosure0D(const InputParameters & params);

  static InputParameters validParams();

protected:
  Real scaledVolume() const;
  Real scaledSurfaceArea() const;

  std::vector<NonlinearVariableName> _species;
  std::vector<Real> _scaling_factors;
  std::vector<Real> _ics;
  const Real _temperature;
  const Real _length_unit;
  const Real _pressure_unit;
  const Real _surface_area;
  const Real _volume;
};

inline Real
Enclosure0D::scaledVolume() const
{
  return _volume * Utility::pow<3>(_length_unit);
}

inline Real
Enclosure0D::scaledSurfaceArea() const
{
  return _surface_area * Utility::pow<2>(_length_unit);
}
