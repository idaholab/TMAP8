//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "RequirePositiveNCPNodalKernel.h"

registerMooseObject("TMAPApp", RequirePositiveNCPNodalKernel);

template <>
InputParameters
validParams<RequirePositiveNCPNodalKernel>()
{
  InputParameters params = validParams<NodalKernel>();
  params.addRequiredCoupledVar("v", "The coupled variable we require to be non-negative");
  return params;
}

RequirePositiveNCPNodalKernel::RequirePositiveNCPNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters), _v_var(coupled("v")), _v(coupledValue("v"))
{
  if (_var.number() == _v_var)
    mooseError("Coupled variable 'v' needs to be different from 'variable' with "
               "RequirePositiveNCPNodalKernel");
}

Real
RequirePositiveNCPNodalKernel::computeQpResidual()
{
  return std::min(_u[_qp], _v[_qp]);
}

Real
RequirePositiveNCPNodalKernel::computeQpJacobian()
{
  if (_u[_qp] <= _v[_qp])
    return 1;
  return 0;
}

Real
RequirePositiveNCPNodalKernel::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_var)
    if (_v[_qp] < _u[_qp])
      return 1;
  return 0.0;
}
