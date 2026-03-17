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
 *   R = +α_r · exp(-E_r / T) · Ĉ_t
 *
 * This is trivially dimensionless (O(α_r)) because Ĉ_t is O(1).
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

  const Real _alpha_r;
  const Real _detrapping_energy;
  const VariableValue & _temperature;
};
