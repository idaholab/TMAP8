/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "TrappingNodalKernelBase.h"

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
class TrappingNodalKernelDimensionless : public TrappingNodalKernelBase
{
public:
  TrappingNodalKernelDimensionless(const InputParameters & parameters);

  static InputParameters validParams();
};
