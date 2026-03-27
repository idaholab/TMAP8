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
      "Ct_hat = C_t / C_t_ref. "
      "The residual R = +k_r_hat * exp(-E_r / T) * Ct_hat is naturally O(k_r_hat) "
      "because Ct_hat is O(1). No equation scaling is applied.");
  params.addRequiredParam<Real>("dimensionless_release_rate",
                                "Dimensionless release rate k_r_hat = t_ref * alpha_r.");
  params.addParam<Real>("detrapping_energy", 0, "The detrapping activation energy (K)");
  params.addRequiredCoupledVar("temperature", "The temperature (K)");
  return params;
}

ReleasingNodalKernelDimensionless::ReleasingNodalKernelDimensionless(
    const InputParameters & parameters)
  : NodalKernel(parameters),
    _dimensionless_release_rate(getParam<Real>("dimensionless_release_rate")),
    _detrapping_energy(getParam<Real>("detrapping_energy")),
    _temperature(coupledValue("temperature"))
{
}

Real
ReleasingNodalKernelDimensionless::computeQpResidual()
{
  const Real residual =
      _dimensionless_release_rate * std::exp(-_detrapping_energy / _temperature[_qp]) * _u[_qp];

  mooseAssert(residual >= 0,
              "ReleasingNodalKernelDimensionless returned a negative residual, which is not "
              "physically expected for a release source.");

  return residual;
}

Real
ReleasingNodalKernelDimensionless::computeQpJacobian()
{
  return _dimensionless_release_rate * std::exp(-_detrapping_energy / _temperature[_qp]);
}
