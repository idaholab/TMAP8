/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/
/*TEst*/
#include "ADMatInterfaceReactionZr2FeHxPCT.h"

#include "PhysicalConstants.h"

registerMooseObject("TMAP8App", ADMatInterfaceReactionZr2FeHxPCT);

InputParameters
ADMatInterfaceReactionZr2FeHxPCT::validParams()

{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription(
      "Implements a reaction to establish ReactionRate=k_f*u-k_b*v to compute the surface H "
      "concentration in Zr2FeHx from the temperature and partial pressure based on the PCT curves "
      "with "
      "u the concentration in the solid and v (neighbor) the concentration in the gas in mol/m^3.");
  params.addRequiredCoupledVar(
      "neighbor_temperature",
      "The variable on the other side of the interface for temperature (K).");
  params.addParam<MaterialPropertyName>("density", "density", "Density of the solid in (mol/m^3).");
  params.addParam<MaterialPropertyName>(
      "forward_rate", "kf", "Forward reaction rate coefficient (1/s).");
  params.addParam<MaterialPropertyName>(
      "backward_rate", "kb", "Backward reaction rate coefficient (1/s).");
  params.addParam<bool>(
      "silence_warnings", false, "Whether to silence correlation out of bound warnings");
  return params;
}

ADMatInterfaceReactionZr2FeHxPCT::ADMatInterfaceReactionZr2FeHxPCT(
    const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _neighbor_temperature(this->template coupledGenericValue<true>("neighbor_temperature")),
    _density(getADMaterialProperty<Real>("density")),
    _kf(getADMaterialProperty<Real>("forward_rate")),
    _kb(getNeighborADMaterialProperty<Real>("backward_rate")),
    _silence_warnings(getParam<bool>("silence_warnings"))
{
}

ADReal
ADMatInterfaceReactionZr2FeHxPCT::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0;

  // Calculate the equilibrium concentration value based on PCT curve
  // (/2 because two atoms for a molecule) (pressure in Pa)
  auto neighbor_pressure =
      PhysicalConstants::ideal_gas_constant * _neighbor_temperature[_qp] * _neighbor_value[_qp] / 2;

  // Calculate the value of the pressures-limiter
  auto limit_pressure = exp(-4.1226 + 1.0288e-2 * _neighbor_temperature[_qp]);

  // return warning if the PCT curves is used out of bounds (pressure in Pa)
  if (!_silence_warnings && ((neighbor_pressure < limit_pressure) || (neighbor_pressure > 1.e6)))
    mooseDoOnce(mooseWarning("In Zr2FeHxPCT: pressure ",
                             neighbor_pressure,
                             "Pa and temperature ",
                             _neighbor_temperature[_qp],
                             "K are outside the bounds of the atomic fraction correlation. See "
                             "documentation for Zr2FeHxPCT material."));

  // Calculate the atomic fraction based on the PCT curve

  auto atomic_fraction =
      4.30 - 1.8103 / (0.5 + exp(5.4074 - 1.3571e-02 * _neighbor_temperature[_qp] +
                                 (2.3190e-01 + 1.5078e-04 * _neighbor_temperature[_qp]) *
                                     log(max(neighbor_pressure - limit_pressure, 1e-10))));

  // Convert to concentration
  auto _surface_equilibrium_concentration = atomic_fraction * _density[_qp];

  switch (type)
  {
    // Move all the terms to the LHS to get residual, for primary domain
    // Residual = kf*u - kb*v
    // Weak form for primary domain is: (test, kf*u - kb*v)
    case Moose::Element:
      r = _test[_i][_qp] * (_kf[_qp] * _u[_qp] - _kb[_qp] * _surface_equilibrium_concentration);
      break;

    // Similarly, weak form for secondary domain is: -(test, kf*u - kb*v),
    // flip the sign because the direction is opposite.
    case Moose::Neighbor:
      r = -_test_neighbor[_i][_qp] *
          (_kf[_qp] * _u[_qp] - _kb[_qp] * _surface_equilibrium_concentration);
      break;
  }
  return r;
}
