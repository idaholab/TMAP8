#pragma once

#include "Kernel.h"

class LMDiffusion;

template <>
InputParameters validParams<LMDiffusion>();

class LMDiffusion : public Kernel
{
public:
  LMDiffusion(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

private:
  const unsigned int _v_var;
  const VariableSecond & _second_v;
  const VariablePhiSecond & _second_v_phi;
  const Real _lm_sign;
  const Real _diffusivity;
};
