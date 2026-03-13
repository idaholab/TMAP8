/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ReleasingNodalKernel.h"

registerMooseObject("TMAP8App", ReleasingNodalKernel);

InputParameters
ReleasingNodalKernel::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addClassDescription(
      "Implements a residual describing the release of trapped species in a material.");
  params.addRequiredParam<Real>("alpha_r", "The release rate coefficient (1/s)");
  params.addParam<Real>("detrapping_energy", 0, "The detrapping energy (K)");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  TMAP::Scaling::addTrappingEquationScaleParams(params);
  return params;
}

ReleasingNodalKernel::ReleasingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_r(getParam<Real>("alpha_r")),
    _detrapping_energy(getParam<Real>("detrapping_energy")),
    _temperature(coupledValue("temperature")),
    _equation_scaling(parameters)
{
}

Real
ReleasingNodalKernel::computeQpResidual()
{
  const Real residual = _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * _u[_qp];

  return _equation_scaling.scaleResidual(residual);
}

Real
ReleasingNodalKernel::computeQpJacobian()
{
  return _equation_scaling.scaleResidual(_alpha_r *
                                         std::exp(-_detrapping_energy / _temperature[_qp]));
}
