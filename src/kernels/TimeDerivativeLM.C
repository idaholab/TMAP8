#include "TimeDerivativeLM.h"

#include "Function.h"

registerADMooseObject("TMAPApp", TimeDerivativeLM);

defineADValidParams(TimeDerivativeLM, LMTimeKernel, );

template <ComputeStage compute_stage>
TimeDerivativeLM<compute_stage>::TimeDerivativeLM(const InputParameters & parameters)
  : LMTimeKernel<compute_stage>(parameters)
{
}

template <ComputeStage compute_stage>
ADReal
TimeDerivativeLM<compute_stage>::precomputeQpResidual()
{
  return _u_dot[_qp];
}
