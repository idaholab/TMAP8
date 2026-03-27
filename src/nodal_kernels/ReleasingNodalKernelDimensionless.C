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
  InputParameters params = ReleasingNodalKernelBase::validParams();
  params.addClassDescription(
      "Implements the release source term for a dimensionless trapped-species variable "
      "Ct_hat = C_t / C_t_ref. "
      "The residual R = +k_r_hat * exp(-E_r / T) * Ct_hat is naturally O(k_r_hat) "
      "because Ct_hat is O(1). No equation scaling is applied.");
  params.addRequiredParam<Real>("dimensionless_release_rate",
                                "Dimensionless release rate k_r_hat = t_ref * alpha_r.");
  return params;
}

ReleasingNodalKernelDimensionless::ReleasingNodalKernelDimensionless(
    const InputParameters & parameters)
  : ReleasingNodalKernelBase(parameters, parameters.get<Real>("dimensionless_release_rate"))
{
}
