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
  params.addParam<std::vector<BoundaryName>>(
      "exclude_boundaries",
      "Boundaries on which not to execute the NCP NodalKernel. This can be useful for avoiding "
      "singuarlity in the matrix in case a constraint is active in the same place that a "
      "DirichletBC is set");
  return params;
}

RequirePositiveNCPNodalKernel::RequirePositiveNCPNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters), _v_var(coupled("v")), _v(coupledValue("v"))
{
  if (_var.number() == _v_var)
    mooseError("Coupled variable 'v' needs to be different from 'variable' with "
               "RequirePositiveNCPNodalKernel");

  const auto & bnd_names = getParam<std::vector<BoundaryName>>("exclude_boundaries");
  for (const auto & bnd_name : bnd_names)
    _bnd_ids.insert(_mesh.getBoundaryID(bnd_name));
}

Real
RequirePositiveNCPNodalKernel::computeQpResidual()
{
  for (auto bnd_id : _bnd_ids)
    if (_mesh.isBoundaryNode(_current_node->id(), bnd_id))
      return _u[_qp];

  return std::min(_u[_qp], _v[_qp]);
}

Real
RequirePositiveNCPNodalKernel::computeQpJacobian()
{
  for (auto bnd_id : _bnd_ids)
    if (_mesh.isBoundaryNode(_current_node->id(), bnd_id))
      return 1;

  if (_u[_qp] <= _v[_qp])
    return 1;
  return 0;
}

Real
RequirePositiveNCPNodalKernel::computeQpOffDiagJacobian(unsigned int jvar)
{
  for (auto bnd_id : _bnd_ids)
    if (_mesh.isBoundaryNode(_current_node->id(), bnd_id))
      return 0;

  if (jvar == _v_var)
    if (_v[_qp] < _u[_qp])
      return 1;

  return 0.0;
}
