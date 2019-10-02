//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "NodalKernel.h"

#include "metaphysicl/dualdynamicsparsenumberarray.h"

using MetaPhysicL::DualNumber;
using MetaPhysicL::DynamicSparseNumberArray;

// Forward Declarations
class TrappingNodalKernel;
typedef DualNumber<Real, DynamicSparseNumberArray<Real, unsigned int>> LocalDN;

template <>
InputParameters validParams<TrappingNodalKernel>();

class TrappingNodalKernel : public NodalKernel
{
public:
  TrappingNodalKernel(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _alpha_t;
  const Real _N;
  const Real _Ct0;
  const VariableValue & _mobile_conc;
  unsigned int _n_other_concs;
  std::vector<const VariableValue *> _trapped_concentrations;
  std::vector<unsigned int> _var_numbers;
  const Node * _last_node;
  LocalDN _jacobian;

private:
  void ADHelper();
};
