/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

// MOOSE includes
#include "SideIntegralVariablePostprocessor.h"

// Forward Declarations
class PressureReleaseFluxIntegral;

template <>
InputParameters validParams<PressureReleaseFluxIntegral>();

class PressureReleaseFluxIntegral : public SideIntegralVariablePostprocessor
{
public:
  PressureReleaseFluxIntegral(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral() override;

  MaterialPropertyName _diffusivity;
  const MaterialProperty<Real> & _diffusion_coef;
  const Real _area;
  const Real _volume;
  const Real _concentration_to_pressure_conversion_factor;
};
