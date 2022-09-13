/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "CoupledForceLM.h"

registerMooseObject("TMAPApp", CoupledForceLM);

InputParameters
CoupledForceLM::validParams()
{
  auto params = LMKernel::validParams();
  params.addRequiredCoupledVar("v", "The coupled variable which provides the force");
  params.addParam<Real>(
      "coef", 1.0, "Coefficent ($\\sigma$) multiplier for the coupled force term.");
  return params;
}

CoupledForceLM::CoupledForceLM(const InputParameters & parameters)
  : LMKernel(parameters),
    _v_var(coupled("v")),
    _v(adCoupledValue("v")),
    _coef(getParam<Real>("coef"))
{
  if (_var.number() == _v_var)
    mooseError("Coupled variable 'v' needs to be different from 'variable' with CoupledForce, "
               "consider using Reaction or somethig similar");
}

ADReal
CoupledForceLM::precomputeQpResidual()
{
  return -_coef * _v[_qp];
}
