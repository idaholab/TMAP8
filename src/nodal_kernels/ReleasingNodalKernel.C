/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ReleasingNodalKernel.h"

registerMooseObject("TMAP8App", ReleasingNodalKernel);

InputParameters
ReleasingNodalKernel::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addClassDescription(
      "Implements a residual describing the release of trapped species in a material.");
  params.addRequiredParam<Real>("alpha_r", "The release rate coefficient (1/s)");
  params.addCoupledVar("v",
                       "If specified, variable to compute the release rate with. "
                       "Else, uses the 'variable' argument");
  params.deprecateCoupledVar("v", "trapped_concentration", "1/1/2026");
  params.addParam<Real>("detrapping_energy", 0, "The detrapping energy (K)");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");

  // Optional mass lumping
  params.addParam<bool>(
      "use_mass_lumping",
      false,
      "Whether to use mass lumping to make this kernel compatible with volumetric kernels");
  params.addCoupledVar("nodal_mass", "The local nodal mass");
  params.addParamNamesToGroup("use_mass_lumping nodal_mass", "Mass lumping");
  return params;
}

ReleasingNodalKernel::ReleasingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_r(getParam<Real>("alpha_r")),
    _detrapping_energy(getParam<Real>("detrapping_energy")),
    _temperature(coupledValue("temperature")),
    _v(isParamValid("trapped_concentration") ? coupledValue("trapped_concentration") : _u),
    _v_index(coupled("trapped_concentration")),
    _v_is_u(!isCoupled("trapped_concentration") || (_v_index == variable().number())),
    _mass_lumped(getParam<bool>("use_mass_lumping")),
    _nodal_mass(_mass_lumped ? coupledValue("nodal_mass") : _one),
    _one(1)
{
}

Real
ReleasingNodalKernel::computeQpResidual()
{
  const auto mass = _mass_lumped ? _nodal_mass[_qp] : 1.;
  // std::cout << "Nodal " << _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * _v[_qp]
  //           << std::endl;
  return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * _v[_qp] * mass;
}

Real
ReleasingNodalKernel::computeQpJacobian()
{
  const auto mass = _mass_lumped ? _nodal_mass[_qp] : 1.;
  if (_v_is_u)
    return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * mass;
  else
    return 0;
}

Real
ReleasingNodalKernel::computeQpOffDiagJacobian(unsigned int jvar)
{
  const auto mass = _mass_lumped ? _nodal_mass[_qp] : 1.;
  if (!_v_is_u && jvar == _v_index)
    return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * mass;
  else
    return 0;
  // TODO: add temperature off-diagonal term
}
