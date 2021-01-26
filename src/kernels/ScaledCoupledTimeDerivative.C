/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "ScaledCoupledTimeDerivative.h"

registerMooseObject("TMAPApp", ScaledCoupledTimeDerivative);

template <>
InputParameters
validParams<ScaledCoupledTimeDerivative>()
{
  InputParameters params = validParams<CoupledTimeDerivative>();
  params.addParam<Real>("factor", 1, "The factor by which to scale");
  return params;
}

ScaledCoupledTimeDerivative::ScaledCoupledTimeDerivative(const InputParameters & parameters)
  : CoupledTimeDerivative(parameters), _factor(getParam<Real>("factor"))
{
}

Real
ScaledCoupledTimeDerivative::computeQpResidual()
{
  return _factor * CoupledTimeDerivative::computeQpResidual();
}

Real
ScaledCoupledTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  return _factor * CoupledTimeDerivative::computeQpOffDiagJacobian(jvar);
}
