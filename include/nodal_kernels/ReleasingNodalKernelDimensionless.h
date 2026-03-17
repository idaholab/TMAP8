/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "NodalKernel.h"

/**
 * Releasing NodalKernel for a dimensionless trapped-species variable
 * Ĉ_t = C_t / C_t_ref.
 *
 * The residual is:
 *   R = +k_r_hat · exp(-E_r / T) · Ĉ_t
 *
 * where k_r_hat = t_ref · α_r.
 *
 * This is trivially dimensionless (O(k_r_hat)) because Ĉ_t is O(1).
 * No TMAPScaling / scaleResidual is used.
 */
class ReleasingNodalKernelDimensionless : public NodalKernel
{
public:
  ReleasingNodalKernelDimensionless(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const Real _dimensionless_release_rate;
  const Real _detrapping_energy;
  const VariableValue & _temperature;
};
