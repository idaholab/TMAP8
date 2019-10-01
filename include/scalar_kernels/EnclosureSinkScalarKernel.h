//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ODEKernel.h"

class EnclosureSinkScalarKernel;

template <>
InputParameters validParams<EnclosureSinkScalarKernel>();

class EnclosureSinkScalarKernel : public ODEKernel
{
public:
  EnclosureSinkScalarKernel(const InputParameters & parameters);

protected:
  Real computeQpResidual() final;

  const PostprocessorValue & _flux;
  const Real _area;
  const Real _volume;
  const Real _concentration_to_pressure_conversion_factor;
};
