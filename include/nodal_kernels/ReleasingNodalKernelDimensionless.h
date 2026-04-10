/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ReleasingNodalKernelBase.h"

/**
 * Releasing NodalKernel for a dimensionless trapped-species variable
 * Ct_hat = C_t / C_t_ref.
 *
 * The residual is:
 *   R = +k_r_hat * exp(-E_r / T) * Ct_hat
 *
 * where k_r_hat = t_ref * alpha_r.
 *
 * The quadrature point residual should be dimensionless and O(k_r_hat) because Ct_hat should be
 * dimensionless and O(1).
 */
class ReleasingNodalKernelDimensionless : public ReleasingNodalKernelBase
{
public:
  ReleasingNodalKernelDimensionless(const InputParameters & parameters);

  static InputParameters validParams();
};
