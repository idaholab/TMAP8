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

typedef DualNumber<Real, DynamicSparseNumberArray<Real, unsigned int>> LocalDN;

class TrappingNodalKernelBase : public NodalKernel
{
public:
  static InputParameters validParams();

protected:
  TrappingNodalKernelBase(const InputParameters & parameters,
                          Real trapping_rate,
                          Real residual_denominator);

  void initializeOccupancyTracking(const std::vector<Real> & other_weights, Real self_weight);

  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _trapping_rate;
  const Real _trapping_energy;
  const Real _N;
  const Function & _Ct0;
  const VariableValue & _mobile_concentration;
  unsigned int _n_other_concs;
  std::vector<const VariableValue *> _occupancy_concentrations;
  std::vector<Real> _occupancy_weights;
  std::vector<unsigned int> _var_numbers;
  const Node * _last_node;
  const VariableValue & _temperature;
  const Real _residual_denominator;
  LocalDN _jacobian;

private:
  void ADHelper();
};
