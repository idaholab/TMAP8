//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "RequirePositiveNCP.h"

registerMooseObject("TMAPApp", RequirePositiveNCP);

template <>
InputParameters
validParams<RequirePositiveNCP>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("v", "The coupled variable we require to be non-negative");
  params.addParam<Real>("u_mult", 1., "A multiplier for the u term");
  return params;
}

RequirePositiveNCP::RequirePositiveNCP(const InputParameters & parameters)
  : Kernel(parameters),
    _v_var(coupled("v")),
    _v(coupledValue("v")),
    _u_mult(getParam<Real>("u_mult"))
{
  if (_var.number() == _v_var)
    mooseError("Coupled variable 'v' needs to be different from 'variable' with "
               "RequirePositiveNCP");
}

Real
RequirePositiveNCP::computeQpResidual()
{
  return _test[_i][_qp] * std::min(_u_mult * _u[_qp], _v[_qp]);
}

Real
RequirePositiveNCP::computeQpJacobian()
{
  if (_u[_qp] <= _v[_qp])
    return _test[_i][_qp] * _u_mult * _phi[_j][_qp];
  return 0;
}

Real
RequirePositiveNCP::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_var)
    if (_v[_qp] < _u[_qp])
      return _test[_i][_qp] * _phi[_j][_qp];
  return 0.0;
}
