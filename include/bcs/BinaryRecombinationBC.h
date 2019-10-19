//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADIntegratedBC.h"

template <ComputeStage>
class BinaryRecombinationBC;

declareADValidParams(BinaryRecombinationBC);

template <ComputeStage compute_stage>
class BinaryRecombinationBC : public ADIntegratedBC<compute_stage>
{
public:
  BinaryRecombinationBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _v;

  const Real & _Kr;

  usingIntegratedBCMembers;
};
