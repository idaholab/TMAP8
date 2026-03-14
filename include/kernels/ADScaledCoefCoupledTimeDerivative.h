/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ADCoupledTimeDerivative.h"
#include "TMAPScaling.h"

class ADScaledCoefCoupledTimeDerivative : public ADCoupledTimeDerivative
{
public:
  ADScaledCoefCoupledTimeDerivative(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal precomputeQpResidual() override;

  const Real _coef;
  const TMAP::Scaling::MobileEquationScaling _equation_scaling;
};
