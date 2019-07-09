//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EquilibriumBC.h"

registerADMooseObject("TMAPApp", EquilibriumBC);

defineADValidParams(
    EquilibriumBC,
    ADNodalBC,
    params.addRequiredParam<Real>(
        "K", "The equilibrium coefficient $K$ for the relationship $C_i = KP_i^p$");
    params.addParam<Real>("p", 1, "The exponent $p$ in the relationship $C_i = KP_i^p$");
    params.addRequiredCoupledVar("enclosure_scalar_var", "The coupled enclosure variable");
    params.addRequiredParam<Real>("temp", "The temperature");
    params.addParam<Real>("var_scaling_factor",
                          1,
                          "The number of atoms that compose our arbitrary unit for quantity");
    params.addParam<Real>("penalty", 1e6, "The penalty factor for enforcing value matching"););

template <ComputeStage compute_stage>
EquilibriumBC<compute_stage>::EquilibriumBC(const InputParameters & parameters)
  : ADNodalBC<compute_stage>(parameters),
    _K(getParam<Real>("K")), // To-do: use an interface material
    _p(getParam<Real>("p")),
    _enclosure_var(adCoupledScalarValue("enclosure_scalar_var")),
    _temp(getParam<Real>("temp")),
    _kb(1.38e-23),
    _var_scaling_factor(getParam<Real>("var_scaling_factor")),
    _penalty(getParam<Real>("penalty"))
{
}

template <ComputeStage compute_stage>
ADReal
EquilibriumBC<compute_stage>::computeQpResidual()
{
  return /*_penalty * */ (_u /*[_qp]*/ - _K * std::pow(_enclosure_var[0], _p));
}
