//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADKernelValue.h"

#define usingLMKernelMembers usingKernelValueMembers

template <ComputeStage>
class LMKernel;

declareADValidParams(LMKernel);

template <ComputeStage compute_stage>
class LMKernel : public ADKernelValue<compute_stage>
{
public:
  LMKernel(const InputParameters & parameters);

  virtual void computeResidual() override;
  virtual void computeJacobian() override;
  virtual void computeADOffDiagJacobian() override;

protected:
  MooseVariable & _lm_var;
  const ADVariableValue & _lm;
  const VariableTestValue & _lm_test;
  const Real _lm_sign;

  usingKernelValueMembers;
};
