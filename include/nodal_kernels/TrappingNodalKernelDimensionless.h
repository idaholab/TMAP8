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

/// Type alias for AD dual numbers used in the manual Jacobian calculation.
/// Reuse the same underlying type as TrappingNodalKernel.
typedef DualNumber<Real, DynamicSparseNumberArray<Real, unsigned int>> LocalDN;

/**
 * Trapping NodalKernel that operates on a dimensionless trapped-species variable
 * Ĉ_t = C_t / C_t_ref, where C_t_ref is the trap concentration reference scale.
 *
 * The residual is:
 *   R = -(α_t / N) · exp(-E_t / T) · (N·Ct0 - C_t_ref·Ĉ_t - Σ_j C_t_j) · C_m / C_t_ref
 *
 * where:
 *   - Ĉ_t  = dimensionless variable (this kernel's variable), O(1)
 *   - C_m  = physical mobile concentration. The coupled variable may be either physical
 *            or dimensionless, controlled by the mobile_variable_is_dimensionless flag.
 *   - C_t_j = physical concentrations of other trap types (physical units, optional)
 *   - C_t_ref = trap_concentration_reference parameter
 *
 * No TMAPScaling / scaleResidual is used. The residual is naturally O(α_t · C_m / N)
 * and is uniform across all trap types with different densities because the C_t_ref
 * factors cancel in the expression above.
 */
class TrappingNodalKernelDimensionless : public NodalKernel
{
public:
  TrappingNodalKernelDimensionless(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _alpha_t;
  const Real _trapping_energy;
  const Real _N;
  const Function & _Ct0;
  /// C_t_ref: reference concentration for THIS trap (used to convert Ĉ_t back to physical)
  const Real _trap_concentration_reference;
  /// C_m_ref: reference concentration for the mobile species when the coupled variable is dimensionless
  const Real _mobile_concentration_reference;
  const bool _mobile_variable_is_dimensionless;
  const VariableValue & _mobile_concentration;
  unsigned int _n_other_concs;
  /// Physical concentrations of other trap types (NOT dimensionless)
  std::vector<const VariableValue *> _other_trapped_concentrations;
  /// Variable numbers: [other_trap_0, ..., other_trap_n, this_trap, mobile]
  std::vector<unsigned int> _var_numbers;
  const Node * _last_node;
  const VariableValue & _temperature;
  LocalDN _jacobian;

private:
  void ADHelper();
};
