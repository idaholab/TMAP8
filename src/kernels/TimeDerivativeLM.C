#include "TimeDerivativeLM.h"
#include "Function.h"

registerMooseObject("TMAPApp", TimeDerivativeLM);

InputParameters
TimeDerivativeLM::validParams()
{
  return LMTimeKernel::validParams();
}

TimeDerivativeLM::TimeDerivativeLM(const InputParameters & parameters) : LMTimeKernel(parameters) {}

ADReal
TimeDerivativeLM::precomputeQpResidual()
{
  return _u_dot[_qp];
}
