/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TrappingNodalKernelDimensionless.h"

registerMooseObject("TMAP8App", TrappingNodalKernelDimensionless);

InputParameters
TrappingNodalKernelDimensionless::validParams()
{
  InputParameters params = TrappingNodalKernelBase::validParams();
  params.addClassDescription(
      "Implements the trapping source term for a dimensionless trapped-species variable "
      "Ct_hat = C_t / C_t_ref. "
      "The mobile concentration may be either physical or dimensionless. "
      "No equation scaling is applied; the residual is O(k_t_hat).");
  params.addRequiredParam<Real>(
      "dimensionless_trapping_rate",
      "Dimensionless trapping rate k_t_hat = t_ref * alpha_t * C_m_ref / N.");
  params.addRequiredParam<Real>(
      "trap_concentration_reference",
      "Reference concentration C_t_ref for this trap species (same units as N). "
      "Typically set to N * Ct0_max. The variable stores Ct_hat = C_t / C_t_ref.");
  params.addCoupledVar("other_trapped_concentration_variables",
                       "Dimensionless trapped-concentration variables (Ct_hat_j = C_t_j / "
                       "C_t_ref_j) "
                       "for other trap species that compete for the same trapping sites.");
  params.addParam<std::vector<Real>>(
      "other_trap_concentration_references",
      {},
      "Reference concentrations C_t_ref_j for each variable listed in "
      "other_trapped_concentration_variables, used to convert Ct_hat_j back to physical C_t_j "
      "when computing available trapping sites. Must match in length.");
  return params;
}

TrappingNodalKernelDimensionless::TrappingNodalKernelDimensionless(
    const InputParameters & parameters)
  : TrappingNodalKernelBase(parameters,
                            parameters.get<Real>("dimensionless_trapping_rate"),
                            parameters.get<Real>("trap_concentration_reference"))
{
  std::vector<Real> other_trap_concentration_references =
      getParam<std::vector<Real>>("other_trap_concentration_references");

  if (!other_trap_concentration_references.empty() &&
      other_trap_concentration_references.size() != _n_other_concs)
    paramError("other_trap_concentration_references",
               "Length (",
               other_trap_concentration_references.size(),
               ") must match the number of other_trapped_concentration_variables (",
               _n_other_concs,
               ").");

  // Default: treat each missing reference as 1.0 (physical units, backward compat)
  if (other_trap_concentration_references.empty() && _n_other_concs > 0)
    other_trap_concentration_references.assign(_n_other_concs, 1.0);

  initializeOccupancyTracking(other_trap_concentration_references,
                              getParam<Real>("trap_concentration_reference"));
}
