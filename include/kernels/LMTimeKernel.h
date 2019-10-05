//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "LMKernel.h"

template <ComputeStage compute_stage>
class LMTimeKernel : public LMKernel<compute_stage>
{
public:
  LMTimeKernel(const InputParameters & parameters);

protected:
  const ADVariableValue & _u_dot;

  usingLMKernelMembers;
};

declareADValidParams(LMTimeKernel);

#define usingLMTimeKernelMembers                                                                   \
  usingLMKernelMembers;                                                                            \
  using LMTimeKernel<compute_stage>::_u_dot
