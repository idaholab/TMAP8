/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "TimeDerivativeNodalKernel.h"
#include "TMAPScaling.h"

class ScaledTimeDerivativeNodalKernel : public TimeDerivativeNodalKernel
{
public:
  static InputParameters validParams();

  ScaledTimeDerivativeNodalKernel(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const TMAP::Scaling::TrappingEquationScaling _equation_scaling;
};
