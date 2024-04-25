/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
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
  params.addParam<Real>("trapping_energy", 0, "The trapping energy (K)");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

ReleasingNodalKernel::ReleasingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_r(getParam<Real>("alpha_r")),
    _trapping_energy(getParam<Real>("trapping_energy")),
    _temperature(coupledValue("temperature"))
{
}

Real
ReleasingNodalKernel::computeQpResidual()
{
  return _alpha_r * std::exp(-_trapping_energy / _temperature[_qp]) * _u[_qp];
}

Real
ReleasingNodalKernel::computeQpJacobian()
{
  return _alpha_r * std::exp(-_trapping_energy / _temperature[_qp]);
}
