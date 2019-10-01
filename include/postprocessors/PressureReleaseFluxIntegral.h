//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

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
