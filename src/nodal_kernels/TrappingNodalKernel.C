/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TrappingNodalKernel.h"
#include "Function.h"

registerMooseObject("TMAP8App", TrappingNodalKernel);

InputParameters
TrappingNodalKernel::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addClassDescription(
      "Implements a residual describing the trapping of a species in a material.");
  params.addRequiredParam<Real>("alpha_t",
                                "The trapping rate coefficient. This has units of 1/s (e.g. no "
                                "number densities are involved)");
  params.addParam<Real>("trapping_energy", 0, "The trapping energy (K)");
  params.addRequiredParam<Real>("N", "The atomic number density of the host material (1/m^3)");
  params.addRequiredParam<FunctionName>(
      "Ct0", "The fraction of host sites that can contribute to trapping as a function (-)");
  params.addParam<Real>(
      "trap_per_free",
      1.,
      "An estimate for the ratio of the concentration magnitude of trapped species to free "
      "species. Setting a value for this can be helpful in producing a well-scaled matrix (-)");
  params.addRequiredCoupledVar(
      "mobile_concentration",
      "The variable representing the mobile concentration of solute particles (1/m^3)");
  params.addCoupledVar("other_trapped_concentration_variables",
                       "Other variables representing trapped particle concentrations.");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

TrappingNodalKernel::TrappingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_t(getParam<Real>("alpha_t")),
    _trapping_energy(getParam<Real>("trapping_energy")),
    _N(getParam<Real>("N")),
    _Ct0(getFunction("Ct0")),
    _mobile_concentration(coupledValue("mobile_concentration")),
    _last_node(nullptr),
    _trap_per_free(getParam<Real>("trap_per_free")),
    _temperature(coupledValue("temperature"))
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
  _var_numbers[_n_other_concs + 1] = coupled("mobile_concentration");
}

Real
TrappingNodalKernel::computeQpResidual()
{
  auto empty_trapping_sites = _Ct0.value(_t, (*_current_node)) * _N;
  for (const auto & trap_conc : _trapped_concentrations)
    empty_trapping_sites -= (*trap_conc)[_qp] * _trap_per_free;

  return -_alpha_t * std::exp(-_trapping_energy / _temperature[_qp]) * empty_trapping_sites *
         _mobile_concentration[_qp] / (_N * _trap_per_free);
}

void
TrappingNodalKernel::ADHelper()
{
  if (_current_node == _last_node)
    return;

  _last_node = _current_node;

  LocalDN empty_trapping_sites = _Ct0.value(_t, (*_current_node)) * _N;
  size_t i = 0;
  for (const auto & trap_conc : _trapped_concentrations)
  {
    LocalDN trap_conc_dn = (*trap_conc)[_qp];
    trap_conc_dn.derivatives().insert(_var_numbers[i]) = 1.;
    empty_trapping_sites -= trap_conc_dn * _trap_per_free;
    ++i;
  }
  LocalDN mobile_concentration = _mobile_concentration[_qp];

  mobile_concentration.derivatives().insert(_var_numbers.back()) = 1.;

  _jacobian = -_alpha_t * std::exp(-_trapping_energy / _temperature[_qp]) * empty_trapping_sites *
              mobile_concentration / (_N * _trap_per_free);
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
