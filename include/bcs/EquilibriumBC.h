//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADNodalBC.h"

template <ComputeStage>
class EquilibriumBC;

declareADValidParams(EquilibriumBC);

template <ComputeStage compute_stage>
class EquilibriumBC : public ADNodalBC<compute_stage>
{
public:
  EquilibriumBC(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  /// The equilibrium coefficient
  const Real _K;

  const Real _p;

  /// The enclosure variable
  const ADVariableValue & _enclosure_var;

  const Real _temp;

  /// Boltzmann's constant
  const Real _kb;

  /// The number of atoms that compose our arbitrary unit for quantity
  const Real _var_scaling_factor;

  const Real _penalty;

  usingNodalBCMembers;
};
