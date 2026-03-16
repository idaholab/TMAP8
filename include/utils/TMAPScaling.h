/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "InputParameters.h"

namespace TMAP
{
namespace Scaling
{
void addTrappingEquationScaleParams(InputParameters & params);
void addMobileEquationScaleParams(InputParameters & params);

class TrappingEquationScaling
{
public:
  explicit TrappingEquationScaling(const InputParameters & parameters);

  template <typename T>
  T scaleResidual(const T & value) const
  {
    return value / residualReference();
  }

  Real trapConcentrationReference() const { return _trap_concentration_reference; }
  Real mobileConcentrationReference() const { return _mobile_concentration_reference; }
  Real siteDensityReference() const { return _site_density_reference; }
  Real timeReference() const { return _time_reference; }
  Real temperatureReference() const { return _temperature_reference; }
  Real residualReference() const { return _trap_concentration_reference / _time_reference; }

private:
  const Real _trap_concentration_reference;
  const Real _mobile_concentration_reference;
  const Real _site_density_reference;
  const Real _time_reference;
  const Real _temperature_reference;
};

class MobileEquationScaling
{
public:
  explicit MobileEquationScaling(const InputParameters & parameters);

  template <typename T>
  T scaleResidual(const T & value) const
  {
    return value / residualReference();
  }

  Real primaryConcentrationReference() const { return _primary_concentration_reference; }
  Real coupledConcentrationReference() const { return _coupled_concentration_reference; }
  Real timeReference() const { return _time_reference; }
  Real residualReference() const { return _primary_concentration_reference / _time_reference; }

private:
  const Real _primary_concentration_reference;
  const Real _coupled_concentration_reference;
  const Real _time_reference;
};
}
}
