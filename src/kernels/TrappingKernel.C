/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TrappingKernel.h"
#include "Function.h"

registerMooseObject("TMAP8App", TrappingKernel);

InputParameters
TrappingKernel::validParams()
{
  InputParameters params = ADKernel::validParams();
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
  params.addCoupledVar("trapped_concentration",
                       "The variable representing the trapped concentration of solute particles "
                       "(1/m^3). If unspecified, defaults to the 'variable' parameter");
  params.addCoupledVar("other_trapped_concentration_variables",
                       "Other variables representing trapped particle concentrations.");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

TrappingKernel::TrappingKernel(const InputParameters & parameters)
  : ADKernel(parameters),
    _alpha_t(getParam<Real>("alpha_t")),
    _trapping_energy(getParam<Real>("trapping_energy")),
    _N(getParam<Real>("N")),
    _Ct0(getFunction("Ct0")),
    _mobile_concentration(adCoupledValue("mobile_concentration")),
    _trap_per_free(getParam<Real>("trap_per_free")),
    _temperature(adCoupledValue("temperature"))
{
  _n_other_concs = coupledComponents("other_trapped_concentration_variables");

  // Resize to n_other_concs plus the concentration corresponding to this Kernel's variable
  _trapped_concentrations.resize(1 + _n_other_concs);

  // Keep pointers to references of the trapped species concentrations
  for (MooseIndex(_n_other_concs) i = 0; i < _n_other_concs; ++i)
    _trapped_concentrations[i] =
        &adCoupledValue("other_trapped_concentration_variables", /*comp*/ 0);
  _trapped_concentrations[_n_other_concs] =
      isParamValid("trapped_concentration") ? &adCoupledValue("trapped_concentration") : &_u;
}

ADReal
TrappingKernel::computeQpResidual()
{
  // Remove filled trapping sites from total number of trapping sites
  ADReal empty_trapping_sites = _Ct0.value(_t, _q_point[_qp]) * _N;
  for (const auto & trap_conc : _trapped_concentrations)
    empty_trapping_sites -= (*trap_conc)[_qp] * _trap_per_free;

  return -_alpha_t * std::exp(-_trapping_energy / _temperature[_qp]) * empty_trapping_sites *
         _mobile_concentration[_qp] / (_N * _trap_per_free) * _test[_i][_qp];
}
