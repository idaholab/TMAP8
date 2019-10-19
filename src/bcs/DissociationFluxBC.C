//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DissociationFluxBC.h"

registerADMooseObject("TMAPApp", DissociationFluxBC);

defineADValidParams(
    DissociationFluxBC,
    ADIntegratedBC,
    params.addRequiredCoupledVar("v",
                                 "The (scalar) variable that is dissociating on this boundary to "
                                 "form the mobile species (specified with the variable param)");
    params.addParam<Real>("Kd", 1, "The dissociation coefficient"););

template <ComputeStage compute_stage>
DissociationFluxBC<compute_stage>::DissociationFluxBC(const InputParameters & parameters)
  : ADIntegratedBC<compute_stage>(parameters), _v(adCoupledValue("v")), _Kd(getParam<Real>("Kd"))
{
}

template <ComputeStage compute_stage>
ADReal
DissociationFluxBC<compute_stage>::computeQpResidual()
{
  return -_test[_i][_qp] * _Kd * _v[_qp];
}
