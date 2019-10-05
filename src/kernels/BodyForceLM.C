#include "BodyForceLM.h"

#include "Function.h"

registerADMooseObject("TMAPApp", BodyForceLM);

defineADValidParams(
    BodyForceLM,
    LMKernel,
    params.addParam<Real>("value", 1.0, "Coefficient to multiply by the body force term");
    params.addParam<FunctionName>("function", "1", "A function that describes the body force");
    params.addParam<PostprocessorName>(
        "postprocessor", 1, "A postprocessor whose value is multiplied by the body force");
    params.declareControllable("value"););

template <ComputeStage compute_stage>
BodyForceLM<compute_stage>::BodyForceLM(const InputParameters & parameters)
  : LMKernel<compute_stage>(parameters),
    _scale(getParam<Real>("value")),
    _function(getFunction("function")),
    _postprocessor(getPostprocessorValue("postprocessor"))
{
}

template <ComputeStage compute_stage>
ADReal
BodyForceLM<compute_stage>::precomputeQpResidual()
{
  return -_scale * _postprocessor * _function.value(_t, _q_point[_qp]);
}
