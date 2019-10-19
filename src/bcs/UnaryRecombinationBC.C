//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "UnaryRecombinationBC.h"

registerADMooseObject("TMAPApp", UnaryRecombinationBC);

defineADValidParams(UnaryRecombinationBC,
                    ADIntegratedBC,
                    params.addParam<Real>("Kr", 1, "The recombination coefficient"););

template <ComputeStage compute_stage>
UnaryRecombinationBC<compute_stage>::UnaryRecombinationBC(const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters), _Kr(getParam<Real>("Kr"))
{
}

template <ComputeStage compute_stage>
ADReal
UnaryRecombinationBC<compute_stage>::computeQpResidual()
{
  return _test[_i][_qp] * _Kr * _u[_qp] * _u[_qp];
}
