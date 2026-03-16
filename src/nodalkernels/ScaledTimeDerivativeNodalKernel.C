/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ScaledTimeDerivativeNodalKernel.h"

registerMooseObject("TMAP8App", ScaledTimeDerivativeNodalKernel);

InputParameters
ScaledTimeDerivativeNodalKernel::validParams()
{
  InputParameters params = TimeDerivativeNodalKernel::validParams();
  params.addClassDescription(
      "Scales a nodal time derivative using physically named trapping reference quantities.");
  TMAP::Scaling::addTrappingEquationScaleParams(params);
  return params;
}

ScaledTimeDerivativeNodalKernel::ScaledTimeDerivativeNodalKernel(const InputParameters & parameters)
  : TimeDerivativeNodalKernel(parameters), _equation_scaling(parameters)
{
}

Real
ScaledTimeDerivativeNodalKernel::computeQpResidual()
{
  return _equation_scaling.scaleResidual(TimeDerivativeNodalKernel::computeQpResidual());
}

Real
ScaledTimeDerivativeNodalKernel::computeQpJacobian()
{
  return _equation_scaling.scaleResidual(TimeDerivativeNodalKernel::computeQpJacobian());
}
