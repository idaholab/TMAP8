#pragma once

#include "LMKernel.h"

class LMTimeKernel : public LMKernel
{
public:
  LMTimeKernel(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  const ADVariableValue & _u_dot;
};
