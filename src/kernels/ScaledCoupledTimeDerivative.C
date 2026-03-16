/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ScaledCoupledTimeDerivative.h"

registerMooseObject("TMAP8App", ScaledCoupledTimeDerivative);

InputParameters
ScaledCoupledTimeDerivative::validParams()
{
  InputParameters params = CoupledTimeDerivative::validParams();
  params.addParam<Real>("factor", 1, "The factor by which to scale");
  TMAP::Scaling::addMobileEquationScaleParams(params);
  return params;
}

ScaledCoupledTimeDerivative::ScaledCoupledTimeDerivative(const InputParameters & parameters)
  : CoupledTimeDerivative(parameters),
    _factor(getParam<Real>("factor")),
    _equation_scaling(parameters)
{
}

Real
ScaledCoupledTimeDerivative::computeQpResidual()
{
  return _equation_scaling.scaleResidual(_factor * CoupledTimeDerivative::computeQpResidual());
}

Real
ScaledCoupledTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  return _equation_scaling.scaleResidual(_factor * CoupledTimeDerivative::computeQpOffDiagJacobian(jvar));
}
