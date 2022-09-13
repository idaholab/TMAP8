/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ReleasingNodalKernel.h"

registerMooseObject("TMAPApp", ReleasingNodalKernel);

InputParameters
ReleasingNodalKernel::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addRequiredParam<Real>("alpha_r", "The release rate coefficient");
  params.addRequiredCoupledVar("temp", "The temperature");
  params.addRequiredParam<Real>("trapping_energy", "The trapping energy in units of Kelvin");
  return params;
}

ReleasingNodalKernel::ReleasingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_r(getParam<Real>("alpha_r")),
    _temp(coupledValue("temp")),
    _trapping_energy(getParam<Real>("trapping_energy"))
{
}

Real
ReleasingNodalKernel::computeQpResidual()
{
  return _alpha_r * std::exp(-_trapping_energy / _temp[_qp]) * _u[_qp];
}

Real
ReleasingNodalKernel::computeQpJacobian()
{
  return _alpha_r * std::exp(-_trapping_energy / _temp[_qp]);
}
