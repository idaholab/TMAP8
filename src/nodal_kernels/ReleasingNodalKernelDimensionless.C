/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ReleasingNodalKernelDimensionless.h"

registerMooseObject("TMAP8App", ReleasingNodalKernelDimensionless);

InputParameters
ReleasingNodalKernelDimensionless::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addClassDescription(
      "Implements the release source term for a dimensionless trapped-species variable "
      "Ĉ_t = C_t / C_t_ref. "
      "The residual R = +α_r · exp(-E_r / T) · Ĉ_t is naturally O(α_r) "
      "because Ĉ_t is O(1). No equation scaling is applied.");
  params.addRequiredParam<Real>("alpha_r", "The release rate coefficient (1/s)");
  params.addParam<Real>("detrapping_energy", 0, "The detrapping activation energy (K)");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

ReleasingNodalKernelDimensionless::ReleasingNodalKernelDimensionless(
    const InputParameters & parameters)
  : NodalKernel(parameters),
    _alpha_r(getParam<Real>("alpha_r")),
    _detrapping_energy(getParam<Real>("detrapping_energy")),
    _temperature(coupledValue("temperature"))
{
}

Real
ReleasingNodalKernelDimensionless::computeQpResidual()
{
  const Real residual = _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]) * _u[_qp];

  mooseAssert(residual >= 0,
              "ReleasingNodalKernelDimensionless returned a negative residual, which is not "
              "physically expected for a release source.");

  return residual;
}

Real
ReleasingNodalKernelDimensionless::computeQpJacobian()
{
  return _alpha_r * std::exp(-_detrapping_energy / _temperature[_qp]);
}
