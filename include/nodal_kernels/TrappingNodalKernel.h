/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

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
  const Real _trap_per_free;
  LocalDN _jacobian;

private:
  void ADHelper();
};
