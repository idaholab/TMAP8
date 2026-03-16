/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ADScaledCoefCoupledTimeDerivative.h"

registerMooseObject("TMAP8App", ADScaledCoefCoupledTimeDerivative);

InputParameters
ADScaledCoefCoupledTimeDerivative::validParams()
{
  auto params = ADCoupledTimeDerivative::validParams();
  params.addClassDescription(
      "AD scaled coupled time derivative using physically named concentration and time references.");
  params.addParam<Real>(
      "coef",
      1.0,
      "Coefficient for the coupled time derivative. This matches ADCoefCoupledTimeDerivative.");
  params.addParam<Real>(
      "factor",
      1.0,
      "Alias for coef retained for compatibility with ScaledCoupledTimeDerivative-style inputs.");
  TMAP::Scaling::addMobileEquationScaleParams(params);
  return params;
}

ADScaledCoefCoupledTimeDerivative::ADScaledCoefCoupledTimeDerivative(
    const InputParameters & parameters)
  : ADCoupledTimeDerivative(parameters),
    _coef(isParamSetByUser("coef") ? getParam<Real>("coef") : getParam<Real>("factor")),
    _equation_scaling(parameters)
{
}

ADReal
ADScaledCoefCoupledTimeDerivative::precomputeQpResidual()
{
  return _equation_scaling.scaleResidual(ADCoupledTimeDerivative::precomputeQpResidual() * _coef);
}
