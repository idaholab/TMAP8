//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "BinaryRecombinationBC.h"

registerADMooseObject("TMAPApp", BinaryRecombinationBC);

defineADValidParams(
    BinaryRecombinationBC,
    ADIntegratedBC,
    params.addRequiredCoupledVar("v", "The other mobile variable that takes part in recombination");
    params.addParam<Real>("Kr", 1, "The recombination coefficient"););

template <ComputeStage compute_stage>
BinaryRecombinationBC<compute_stage>::BinaryRecombinationBC(const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters), _v(adCoupledValue("v")), _Kr(getParam<Real>("Kr"))
{
}

template <ComputeStage compute_stage>
ADReal
BinaryRecombinationBC<compute_stage>::computeQpResidual()
{
  return _test[_i][_qp] * _Kr * _u[_qp] * _v[_qp];
}
