#pragma once

#include "CoupledTimeDerivative.h"

// Forward Declaration
class ScaledCoupledTimeDerivative;

template <>
InputParameters validParams<ScaledCoupledTimeDerivative>();

class ScaledCoupledTimeDerivative : public CoupledTimeDerivative
{
public:
  ScaledCoupledTimeDerivative(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _factor;
};
