#pragma once

#include "LMTimeKernel.h"

class TimeDerivativeLM : public LMTimeKernel
{
public:
  TimeDerivativeLM(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal precomputeQpResidual() override;
};
