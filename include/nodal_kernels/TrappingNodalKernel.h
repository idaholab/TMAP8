/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "NodalKernel.h"

#include "metaphysicl/dualdynamicsparsenumberarray.h"

using MetaPhysicL::DualNumber;
using MetaPhysicL::DynamicSparseNumberArray;

class Function;

// Forward Declarations
typedef DualNumber<Real, DynamicSparseNumberArray<Real, unsigned int>> LocalDN;

class TrappingNodalKernel : public NodalKernel
{
public:
  TrappingNodalKernel(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _alpha_t;
  const Real _trapping_energy;
  const Real _N;
  const Function & _Ct0;
  const VariableValue & _mobile_concentration;
  unsigned int _n_other_concs;
  std::vector<const VariableValue *> _trapped_concentrations;
  std::vector<unsigned int> _var_numbers;
  const Node * _last_node;
  const Real _trap_per_free;
  const VariableValue & _temperature;
  LocalDN _jacobian;

private:
  void ADHelper();
};
