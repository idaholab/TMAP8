#pragma once

#include "LMKernel.h"

template <ComputeStage>
class BodyForceLM;
class Function;

declareADValidParams(BodyForceLM);

template <ComputeStage compute_stage>
class BodyForceLM : public LMKernel<compute_stage>
{
public:
  BodyForceLM(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  /// Scale factor
  const Real & _scale;

  /// Optional function value
  const Function & _function;

  /// Optional Postprocessor value
  const PostprocessorValue & _postprocessor;

  usingLMKernelMembers;
  using KernelBase::_q_point;
};
