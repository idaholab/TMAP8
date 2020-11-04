#pragma once

#include "ADIntegratedBC.h"

class BinaryRecombinationBC : public ADIntegratedBC
{
public:
  BinaryRecombinationBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  const ADVariableValue & _v;

  const Real & _Kr;
};
