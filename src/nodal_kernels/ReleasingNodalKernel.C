/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
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
  params.deprecateCoupledVar("v", "trapped_concentration");
  params.addParam<Real>("detrapping_energy", 0, "The detrapping energy (K)");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

ReleasingNodalKernel::ReleasingNodalKernel(const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_r(getParam<Real>("alpha_r")),
    _detrapping_energy(getParam<Real>("detrapping_energy")),
    _temperature(coupledValue("temperature")),
    _v(isParamValid("trapped_concentration") ? coupledValue("trapped_concentration") : _u),
    _v_index(coupled("trapped_concentration")),
    _v_is_u(!isCoupled("trapped_concentration") ||
            (coupled("trapped_concentration") == variable().number()))
{
}

Real
ReleasingNodalKernel::computeQpResidual()
{
  return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * _v[_qp];
}

Real
ReleasingNodalKernel::computeQpJacobian()
{
  if (_v_is_u)
    return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]);
  else
    return 0;
}

Real
ReleasingNodalKernel::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_index)
    return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]);
  else
    return 0;
  // TODO: add temperature off-diagonal term
}
