//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "TrappingNodalKernel.h"

registerMooseObject("TMAPApp", TrappingNodalKernel);

template <>
InputParameters
validParams<TrappingNodalKernel>()
{
  InputParameters params = validParams<NodalKernel>();
  params.addRequiredParam<Real>("alpha_t", "The trapping rate coefficient");
  params.addRequiredParam<Real>("N", "The atomic number density of the host material");
  params.addRequiredParam<Real>("Ct0",
                                "The fraction of host sites that can contribute to trapping");
  params.addRequiredCoupledVar(
      "mobile", "The variable representing the mobile concentration of solute particles");
  params.addCoupledVar("other_trapped_concentration_variables",
                       "Other variables representing trapped particle concentrations.");
  return params;
}

TrappingNodalKernel::TrappingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_t(getParam<Real>("alpha_t")),
    _N(getParam<Real>("N")),
    _Ct0(getParam<Real>("Ct0")),
    _mobile_conc(coupledValue("mobile")),
    _last_node(nullptr)
{
  _n_other_concs = coupledComponents("other_trapped_concentration_variables");

  // Resize to n_other_concs plus the concentration corresponding to this NodalKernel's variable
  _trapped_concentrations.resize(1 + _n_other_concs);

  // One size bigger than trapped_concentrations because we have to include the mobile concentration
  _var_numbers.resize(2 + _n_other_concs);

  for (MooseIndex(_n_other_concs) i = 0; i < _n_other_concs; ++i)
  {
    _trapped_concentrations[i] = &coupledValue("other_trapped_concentration_variables", i);
    _var_numbers[i] = coupled("other_trapped_concentration_variables", i);
  }
  _trapped_concentrations[_n_other_concs] = &_u;
  _var_numbers[_n_other_concs] = _var.number();
  _var_numbers[_n_other_concs + 1] = coupled("mobile");
}

Real
TrappingNodalKernel::computeQpResidual()
{
  auto empty_trapping_sites = _Ct0 * _N;
  for (const auto & trap_conc : _trapped_concentrations)
    empty_trapping_sites -= (*trap_conc)[_qp];

  return -_alpha_t * empty_trapping_sites * _mobile_conc[_qp] / _N;
}

void
TrappingNodalKernel::ADHelper()
{
  if (_current_node == _last_node)
    return;

  _last_node = _current_node;

  LocalDN empty_trapping_sites = _Ct0 * _N;
  size_t i = 0;
  for (const auto & trap_conc : _trapped_concentrations)
  {
    LocalDN trap_conc_dn = (*trap_conc)[_qp];
    trap_conc_dn.derivatives().insert(_var_numbers[i]) = 1.;
    empty_trapping_sites -= trap_conc_dn;
    ++i;
  }
  LocalDN mobile_conc = _mobile_conc[_qp];

  mobile_conc.derivatives().insert(_var_numbers.back()) = 1.;

  _jacobian = -_alpha_t * empty_trapping_sites * mobile_conc / _N;
}

Real
TrappingNodalKernel::computeQpJacobian()
{
  ADHelper();

  return _jacobian.derivatives()[_var.number()];
}

Real
TrappingNodalKernel::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (std::find(_var_numbers.begin(), _var_numbers.end(), jvar) != _var_numbers.end())
  {
    ADHelper();

    return _jacobian.derivatives()[jvar];
  }
  else
    return 0;
}
