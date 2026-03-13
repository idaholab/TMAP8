/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "CoupledTimeDerivative.h"

/**
 * Adds a constant-factor multiple of a coupled variable's time derivative to the
 * residual of the primary variable:
 *
 *   R += factor * (ψ_i, ∂v/∂t)
 *
 * Intended for the dimensionless trapping formulation where the factor is a pure
 * concentration-ratio constant (C_t_ref / C_m_ref) and no equation-level scaling
 * is needed.
 */
class FactoredCoupledTimeDerivative : public CoupledTimeDerivative
{
public:
  FactoredCoupledTimeDerivative(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  Real computeQpResidual() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Real _factor;
};
