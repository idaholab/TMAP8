#pragma once

#include "LMTimeKernel.h"

template <ComputeStage>
class TimeDerivativeLM;

declareADValidParams(TimeDerivativeLM);

template <ComputeStage compute_stage>
class TimeDerivativeLM : public LMTimeKernel<compute_stage>
{
public:
  TimeDerivativeLM(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  usingLMTimeKernelMembers;
};
