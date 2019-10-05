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
class CoupledForceNodalKernel;

template <>
InputParameters validParams<CoupledForceNodalKernel>();

class CoupledForceNodalKernel : public NodalKernel
{
public:
  CoupledForceNodalKernel(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  const unsigned int _v_var;
  const VariableValue & _v;
  const Real _coef;
};
