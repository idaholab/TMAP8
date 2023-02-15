/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TrappingNodalKernel.h"

registerMooseObject("TMAPApp", TrappingNodalKernel);

InputParameters
TrappingNodalKernel::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addRequiredParam<Real>("alpha_t",
                                "The trapping rate coefficient. This has units of 1/time (e.g. no "
                                "number densities are involved)");
  params.addRequiredParam<Real>("N", "The atomic number density of the host material");
  params.addRequiredParam<Real>("Ct0",
                                "The fraction of host sites that can contribute to trapping");
  params.addParam<Real>(
      "trap_per_free",
      1.,
      "An estimate for the ratio of the concentration magnitude of trapped species to free "
      "species. Setting a value for this can be helpful in producing a well-scaled matrix");
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
    _last_node(nullptr),
    _trap_per_free(getParam<Real>("trap_per_free"))
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
    empty_trapping_sites -= (*trap_conc)[_qp] * _trap_per_free;

  return -_alpha_t * empty_trapping_sites * _mobile_conc[_qp] / (_N * _trap_per_free);
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
    empty_trapping_sites -= trap_conc_dn * _trap_per_free;
    ++i;
  }
  LocalDN mobile_conc = _mobile_conc[_qp];

  mobile_conc.derivatives().insert(_var_numbers.back()) = 1.;

  _jacobian = -_alpha_t * empty_trapping_sites * mobile_conc / (_N * _trap_per_free);
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
