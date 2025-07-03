/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ADKernel.h"

/**
 * This kernel adds to the residual a contribution of \f$ K*(u0-u)*v \f$ where \f$ K \f$ is a
 * material property, \f$ u \f$ is a variable (nonlinear or coupled), \f$ u0 \f$ is its equilibrium
 * value, and \f$ v \f$ is a coupled variable.
 */
class ADMatCoupledDefectAnnihilation : public ADKernel
{
public:
  static InputParameters validParams();

  ADMatCoupledDefectAnnihilation(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual();

  /**
   * Kernel variable (can be nonlinear or coupled variable)
   * (For constrained Allen-Cahn problems, v = lambda
   * where lambda is the Lagrange multiplier)
   */
  const ADVariableValue & _v;

  /// Equilibrium value for variable
  const ADMaterialProperty<Real> & _u_0;

  /// Reaction rate
  const ADMaterialProperty<Real> & _K;

  /// Coefficient used optionally (useful for sensitivity analysis)
  const Real _coeff;
};
