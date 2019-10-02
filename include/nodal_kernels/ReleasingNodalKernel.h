//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "NodalKernel.h"

// Forward Declarations
class ReleasingNodalKernel;

template <>
InputParameters validParams<ReleasingNodalKernel>();

class ReleasingNodalKernel : public NodalKernel
{
public:
  ReleasingNodalKernel(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const Real _alpha_r;
  const VariableValue & _temp;
  const Real _trapping_energy;
};
