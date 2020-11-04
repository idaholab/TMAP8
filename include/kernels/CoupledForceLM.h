#pragma once

#include "LMKernel.h"

class CoupledForceLM : public LMKernel
{
public:
  CoupledForceLM(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal precomputeQpResidual() override;

  const unsigned int _v_var;
  const ADVariableValue & _v;
  const Real _coef;
};
