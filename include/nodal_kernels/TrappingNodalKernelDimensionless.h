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
 * Ct_hat = C_t / C_t_ref, where C_t_ref is the trap concentration reference scale.
 *
 * The residual is:
 *   R = -k_t_hat * exp(-E_t / T) * ((N * Ct0 - C_t_ref * Ct_hat - sum_j C_t_j) / C_t_ref) *
 *       Cm_hat
 *
 * where:
 *   - Ct_hat = dimensionless variable (this kernel's variable), O(1)
 *   - Cm_hat = dimensionless mobile concentration. The coupled variable may be either physical
 *            or dimensionless, controlled by the mobile_variable_is_dimensionless flag.
 *   - C_t_j = C_t_ref_j * Ct_hat_j, other trap species (dimensionless variable + reference,
 *             optional)
 *   - C_t_ref = trap_concentration_reference parameter
 *   - k_t_hat = t_ref * alpha_t * C_m_ref / N
 *
 * The residual is naturally O(k_t_hat).
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

  const Real _dimensionless_trapping_rate;
  const Real _trapping_energy;
  const Function & _Ct0;
  const Real _N;
  /// C_t_ref: reference concentration for THIS trap (used to convert Ct_hat back to physical)
  const Real _trap_concentration_reference;
  /// Dimensionless mobile concentration
  const VariableValue & _mobile_concentration;
  unsigned int _n_other_concs;
  /// Dimensionless concentrations of other trap types (Ct_hat_j = C_t_j / C_t_ref_j)
  std::vector<const VariableValue *> _other_trapped_concentrations;
  /// Reference concentrations C_t_ref_j for each other trap, to convert Ct_hat_j -> physical
  /// C_t_j
  std::vector<Real> _other_trap_concentration_references;
  /// Variable numbers: [other_trap_0, ..., other_trap_n, this_trap, mobile]
  std::vector<unsigned int> _var_numbers;
  const Node * _last_node;
  const VariableValue & _temperature;
  LocalDN _jacobian;

private:
  void ADHelper();
};
