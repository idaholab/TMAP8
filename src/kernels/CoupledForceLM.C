#include "CoupledForceLM.h"

registerADMooseObject("TMAPApp", CoupledForceLM);

defineADValidParams(
    CoupledForceLM,
    LMKernel,
    params.addRequiredCoupledVar("v", "The coupled variable which provides the force");
    params.addParam<Real>("coef",
                          1.0,
                          "Coefficent ($\\sigma$) multiplier for the coupled force term."););

template <ComputeStage compute_stage>
CoupledForceLM<compute_stage>::CoupledForceLM(const InputParameters & parameters)
  : LMKernel<compute_stage>(parameters),
    _v_var(coupled("v")),
    _v(adCoupledValue("v")),
    _coef(getParam<Real>("coef"))
{
  if (_var.number() == _v_var)
    mooseError("Coupled variable 'v' needs to be different from 'variable' with CoupledForce, "
               "consider using Reaction or somethig similar");
}

template <ComputeStage compute_stage>
ADReal
CoupledForceLM<compute_stage>::precomputeQpResidual()
{
  return -_coef * _v[_qp];
}
