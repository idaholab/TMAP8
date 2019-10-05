#pragma once

#include "LMKernel.h"

template <ComputeStage>
class CoupledForceLM;

declareADValidParams(CoupledForceLM);

template <ComputeStage compute_stage>
class CoupledForceLM : public LMKernel<compute_stage>
{
public:
  CoupledForceLM(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  const unsigned int _v_var;
  const ADVariableValue & _v;
  const Real _coef;

  usingLMKernelMembers;
};
