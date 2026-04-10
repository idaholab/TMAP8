/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TrappingNodalKernel.h"

registerMooseObject("TMAP8App", TrappingNodalKernel);

InputParameters
TrappingNodalKernel::validParams()
{
  InputParameters params = TrappingNodalKernelBase::validParams();
  params.addClassDescription(
      "Implements a residual describing the trapping of a species in a material.");
  params.addRequiredParam<Real>("alpha_t",
                                "The trapping rate coefficient. This has units of 1/s (e.g. no "
                                "number densities are involved)");
  params.addParam<Real>(
      "trap_per_free",
      1.,
      "An estimate for the ratio of the concentration magnitude of trapped species to free "
      "species. Setting a value for this can be helpful in producing a well-scaled matrix (-)");
  return params;
}

TrappingNodalKernel::TrappingNodalKernel(const InputParameters & parameters)
  : TrappingNodalKernelBase(parameters,
                            parameters.get<Real>("alpha_t"),
                            parameters.get<Real>("N") * parameters.get<Real>("trap_per_free"))
{
  const Real trap_per_free = getParam<Real>("trap_per_free");
  initializeOccupancyTracking(std::vector<Real>(_n_other_concs, trap_per_free), trap_per_free);
}
