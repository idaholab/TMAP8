/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "EmptySitesAux.h"

registerMooseObject("MooseApp", EmptySitesAux);

template <>
InputParameters
validParams<EmptySitesAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredParam<Real>("N", "The atomic number density of the host material");
  params.addRequiredParam<Real>("Ct0",
                                "The fraction of host sites that can contribute to trapping");
  params.addParam<Real>(
      "trap_per_free",
      1.,
      "An estimate for the ratio of the concentration magnitude of trapped species to free "
      "species. Setting a value for this can be helpful in producing a well-scaled matrix");
  params.addRequiredCoupledVar("trapped_concentration_variables",
                               "Variables representing trapped particle concentrations.");
  return params;
}

EmptySitesAux::EmptySitesAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    _N(getParam<Real>("N")),
    _Ct0(getParam<Real>("Ct0")),
    _trap_per_free(getParam<Real>("trap_per_free"))
{
  _n_concs = coupledComponents("trapped_concentration_variables");

  // Resize to n_other_concs plus the concentration corresponding to this NodalKernel's variable
  _trapped_concentrations.resize(_n_concs);

  for (MooseIndex(_n_concs) i = 0; i < _n_concs; ++i)
    _trapped_concentrations[i] = &coupledValue("trapped_concentration_variables", i);
}

Real
EmptySitesAux::computeValue()
{
  auto empty_trapping_sites = _Ct0 * _N;
  for (const auto & trap_conc : _trapped_concentrations)
    empty_trapping_sites -= (*trap_conc)[_qp] * _trap_per_free;

  return empty_trapping_sites;
}
