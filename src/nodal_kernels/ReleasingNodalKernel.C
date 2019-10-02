//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ReleasingNodalKernel.h"

registerMooseObject("TMAPApp", ReleasingNodalKernel);

template <>
InputParameters
validParams<ReleasingNodalKernel>()
{
  InputParameters params = validParams<NodalKernel>();
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
