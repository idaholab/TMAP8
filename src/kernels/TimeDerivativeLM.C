/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

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
