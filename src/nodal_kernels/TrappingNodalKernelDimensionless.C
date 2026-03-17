/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TrappingNodalKernelDimensionless.h"
#include "Function.h"

registerMooseObject("TMAP8App", TrappingNodalKernelDimensionless);

InputParameters
TrappingNodalKernelDimensionless::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addClassDescription(
      "Implements the trapping source term for a dimensionless trapped-species variable "
      "Ĉ_t = C_t / C_t_ref. "
      "The mobile concentration may be either physical or dimensionless. "
      "No equation scaling is applied; the residual is O(k_t_hat).");
  params.addRequiredParam<Real>(
      "dimensionless_trapping_rate",
      "Dimensionless trapping rate k_t_hat = t_ref * alpha_t * C_m_ref / N.");
  params.addParam<Real>("trapping_energy", 0, "The trapping activation energy (K)");
  params.addRequiredParam<Real>("N", "The atomic number density of the host material (1/m^3)");
  params.addRequiredParam<FunctionName>(
      "Ct0",
      "The fraction of host sites that can contribute to trapping as a function of position (-)");
  params.addRequiredParam<Real>(
      "trap_concentration_reference",
      "Reference concentration C_t_ref for this trap species (same units as N). "
      "Typically set to N * Ct0_max. The variable stores Ĉ_t = C_t / C_t_ref.");
  params.addRequiredCoupledVar(
      "mobile_concentration",
      "The variable representing the mobile concentration of solute particles.");
  params.addParam<bool>("mobile_variable_is_dimensionless",
                        false,
                        "Whether the coupled mobile concentration variable is dimensionless.");
  params.addParam<Real>("mobile_concentration_reference",
                        1.0,
                        "Reference concentration C_m_ref used to convert the mobile variable "
                        "back to physical units when mobile_variable_is_dimensionless = true.");
  params.addCoupledVar("other_trapped_concentration_variables",
                       "Dimensionless trapped-concentration variables (Ĉ_t_j = C_t_j / C_t_ref_j) "
                       "for other trap species that compete for the same trapping sites.");
  params.addParam<std::vector<Real>>(
      "other_trap_concentration_references",
      {},
      "Reference concentrations C_t_ref_j for each variable listed in "
      "other_trapped_concentration_variables, used to convert Ĉ_t_j back to physical C_t_j "
      "when computing available trapping sites. Must match in length.");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

TrappingNodalKernelDimensionless::TrappingNodalKernelDimensionless(
    const InputParameters & parameters)
  : NodalKernel(parameters),
    _dimensionless_trapping_rate(getParam<Real>("dimensionless_trapping_rate")),
    _trapping_energy(getParam<Real>("trapping_energy")),
    _Ct0(getFunction("Ct0")),
    _N(getParam<Real>("N")),
    _trap_concentration_reference(getParam<Real>("trap_concentration_reference")),
    _mobile_concentration_reference(getParam<Real>("mobile_concentration_reference")),
    _mobile_variable_is_dimensionless(getParam<bool>("mobile_variable_is_dimensionless")),
    _mobile_concentration(coupledValue("mobile_concentration")),
    _last_node(nullptr),
    _temperature(coupledValue("temperature"))
{
  _n_other_concs = coupledComponents("other_trapped_concentration_variables");
  _other_trap_concentration_references =
      getParam<std::vector<Real>>("other_trap_concentration_references");

  if (!_other_trap_concentration_references.empty() &&
      _other_trap_concentration_references.size() != _n_other_concs)
    paramError("other_trap_concentration_references",
               "Length (",
               _other_trap_concentration_references.size(),
               ") must match the number of other_trapped_concentration_variables (",
               _n_other_concs,
               ").");

  // Default: treat each missing reference as 1.0 (physical units, backward compat)
  if (_other_trap_concentration_references.empty() && _n_other_concs > 0)
    _other_trap_concentration_references.assign(_n_other_concs, 1.0);

  // Resize to n_other_concs plus the concentration for this kernel's variable
  _other_trapped_concentrations.resize(_n_other_concs);

  // var_numbers: [other_trap_0, ..., other_trap_{n-1}, this_trap, mobile]
  _var_numbers.resize(2 + _n_other_concs);

  for (MooseIndex(_n_other_concs) i = 0; i < _n_other_concs; ++i)
  {
    _other_trapped_concentrations[i] =
        &coupledValue("other_trapped_concentration_variables", /*comp=*/i);
    _var_numbers[i] = coupled("other_trapped_concentration_variables", i);
  }
  _var_numbers[_n_other_concs] = _var.number();
  _var_numbers[_n_other_concs + 1] = coupled("mobile_concentration");
}

Real
TrappingNodalKernelDimensionless::computeQpResidual()
{
  // Physical empty trapping sites for this trap type:
  //   N * Ct0(x) - C_t_ref * Ĉ_t - sum_j C_t_ref_j * Ĉ_t_j
  Real empty_trapping_sites = _Ct0.value(_t, (*_current_node)) * _N;
  empty_trapping_sites -= _u[_qp] * _trap_concentration_reference;
  for (MooseIndex(_n_other_concs) j = 0; j < _n_other_concs; ++j)
    empty_trapping_sites -=
        (*_other_trapped_concentrations[j])[_qp] * _other_trap_concentration_references[j];

  const Real mobile_dimensionless = _mobile_variable_is_dimensionless
                                        ? _mobile_concentration[_qp]
                                        : _mobile_concentration[_qp] /
                                              _mobile_concentration_reference;

  const Real residual = -_dimensionless_trapping_rate *
                        std::exp(-_trapping_energy / _temperature[_qp]) *
                        (empty_trapping_sites / _trap_concentration_reference) *
                        mobile_dimensionless;
  return residual;
}

void
TrappingNodalKernelDimensionless::ADHelper()
{
  if (_current_node == _last_node)
    return;

  _last_node = _current_node;

  // Compute empty trapping sites with dual-number tracking for AD Jacobian
  LocalDN empty_trapping_sites = _Ct0.value(_t, (*_current_node)) * _N;

  // Other traps: dimensionless Ĉ_t_j, multiplied by C_t_ref_j to get physical units
  for (MooseIndex(_n_other_concs) i = 0; i < _n_other_concs; ++i)
  {
    LocalDN other_dn = (*_other_trapped_concentrations[i])[_qp];
    other_dn.derivatives().insert(_var_numbers[i]) = 1.;
    empty_trapping_sites -= other_dn * _other_trap_concentration_references[i];
  }

  // This trap: variable is dimensionless Ĉ_t, multiply by C_t_ref to get physical
  LocalDN this_trap_dn = _u[_qp];
  this_trap_dn.derivatives().insert(_var_numbers[_n_other_concs]) = 1.;
  empty_trapping_sites -= this_trap_dn * _trap_concentration_reference;

  // Mobile concentration in dimensionless form Ĉ_m
  LocalDN mobile_dn = _mobile_concentration[_qp];
  mobile_dn.derivatives().insert(_var_numbers.back()) = 1.;
  if (!_mobile_variable_is_dimensionless)
    mobile_dn /= _mobile_concentration_reference;

  _jacobian = -_dimensionless_trapping_rate *
              std::exp(-_trapping_energy / _temperature[_qp]) *
              (empty_trapping_sites / _trap_concentration_reference) * mobile_dn;
}

Real
TrappingNodalKernelDimensionless::computeQpJacobian()
{
  ADHelper();
  return _jacobian.derivatives()[_var.number()];
}

Real
TrappingNodalKernelDimensionless::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (std::find(_var_numbers.begin(), _var_numbers.end(), jvar) != _var_numbers.end())
  {
    ADHelper();
    return _jacobian.derivatives()[jvar];
  }
  else
    return 0;
}
