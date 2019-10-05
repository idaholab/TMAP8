//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "LMTimeKernel.h"

#include "MooseVariableFE.h"

defineADValidParams(LMTimeKernel, LMKernel, params.set<MultiMooseEnum>("vector_tags") = "time";
                    params.set<MultiMooseEnum>("matrix_tags") = "system time";);

template <ComputeStage compute_stage>
LMTimeKernel<compute_stage>::LMTimeKernel(const InputParameters & parameters)
  : LMKernel<compute_stage>(parameters), _u_dot(_var.template adUDot<compute_stage>())
{
}

template class LMTimeKernel<RESIDUAL>;
template class LMTimeKernel<JACOBIAN>;
