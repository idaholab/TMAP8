/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "BodyForceLM.h"

#include "Function.h"

registerMooseObject("TMAPApp", BodyForceLM);

InputParameters
BodyForceLM::validParams()
{
  auto params = LMKernel::validParams();
  params.addParam<Real>("value", 1.0, "Coefficient to multiply by the body force term");
  params.addParam<FunctionName>("function", "1", "A function that describes the body force");
  params.addParam<PostprocessorName>(
      "postprocessor", 1, "A postprocessor whose value is multiplied by the body force");
  params.declareControllable("value");
  return params;
}

BodyForceLM::BodyForceLM(const InputParameters & parameters)
  : LMKernel(parameters),
    _scale(getParam<Real>("value")),
    _function(getFunction("function")),
    _postprocessor(getPostprocessorValue("postprocessor"))
{
}

ADReal
BodyForceLM::precomputeQpResidual()
{
  return -_scale * _postprocessor * _function.value(_t, _q_point[_qp]);
}
