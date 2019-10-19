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
class DissociationFluxBC;

declareADValidParams(DissociationFluxBC);

template <ComputeStage compute_stage>
class DissociationFluxBC : public ADIntegratedBC<compute_stage>
{
public:
  DissociationFluxBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _v;

  const Real & _Kd;

  usingIntegratedBCMembers;
};
