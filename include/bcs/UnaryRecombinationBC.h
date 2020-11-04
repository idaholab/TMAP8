#pragma once

#include "ADIntegratedBC.h"

class UnaryRecombinationBC : public ADIntegratedBC
{
public:
  UnaryRecombinationBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  const Real & _Kr;
};
