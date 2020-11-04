#pragma once

#include "ADIntegratedBC.h"

class DissociationFluxBC : public ADIntegratedBC
{
public:
  DissociationFluxBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  const ADVariableValue & _v;

  const Real & _Kd;
};
