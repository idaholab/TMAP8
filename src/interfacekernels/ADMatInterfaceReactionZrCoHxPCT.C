/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ADMatInterfaceReactionZrCoHxPCT.h"

#include "PhysicalConstants.h"

registerMooseObject("TMAP8App", ADMatInterfaceReactionZrCoHxPCT);

InputParameters
ADMatInterfaceReactionZrCoHxPCT::validParams()

{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addClassDescription(
      "Implements a reaction to establish ReactionRate=k_f*u-k_b*v to compute the surface H "
      "concentration in ZrCoHx from the temperature and partial pressure based on the PCT curves "
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
  return params;
}

ADMatInterfaceReactionZrCoHxPCT::ADMatInterfaceReactionZrCoHxPCT(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _neighbor_temperature(this->template coupledGenericValue<true>("neighbor_temperature")),
    _density(getADMaterialProperty<Real>("density")),
    _kf(getADMaterialProperty<Real>("forward_rate")),
    _kb(getNeighborADMaterialProperty<Real>("backward_rate"))
{
}

ADReal
ADMatInterfaceReactionZrCoHxPCT::computeQpResidual(Moose::DGResidualType type)
{
  using std::exp;
  using std::log;
  using std::max;
  using std::pow;
  ADReal r = 0;
  // tolerance for the pressure being closed to the plateau region
  const Real tolerance = 10; // Pa
  // Calculate the equilibrium concentration value based on PCT curve
  // (/2 because two atoms for a molecule) (pressure in Pa)V3_projects/TMAP8/src/bcs
  auto neighbor_pressure =
      PhysicalConstants::ideal_gas_constant * _neighbor_temperature[_qp] * _neighbor_value[_qp] / 2;

  // Calculate the value of the pressures for the phase transition plateau (pressure in Pa)
  auto limit_pressure = exp(12.43 - 4.84e-2 * _neighbor_temperature[_qp] +
                            7.15e-5 * Utility::pow<2>(_neighbor_temperature[_qp]));

  // define atomic fraction variable
  ADReal atomic_fraction = 0.0;

  // Give a warning if the initial or computed neighbor pressure is out of the analytical model
  if (((neighbor_pressure > 9.e06) || (neighbor_pressure < 0.011)))
    mooseDoOnce(mooseWarning("In ZrCoHxPCT: pressure ",
                             neighbor_pressure,
                             "Pa and temperature ",
                             _neighbor_temperature[_qp],
                             "K are outside the bounds of the atomic fraction correlation. See "
                             "documentation for ZrCoHxPCT material."));

  if (neighbor_pressure > limit_pressure && abs(neighbor_pressure - limit_pressure) < tolerance)
  {
    // High pressure region, near limit.
    atomic_fraction = 0.50;
  }
  else if (neighbor_pressure > limit_pressure)
  {
    // High pressure region
    atomic_fraction =
        2.5 - 3.42 / (1.40 + exp(7.97 - 1.99e-02 * _neighbor_temperature[_qp] +
                                 (-1.69e-01 + 1.19e-03 * _neighbor_temperature[_qp]) *
                                     log(max(neighbor_pressure - limit_pressure, 1.e-10))));
  }
  else if (neighbor_pressure < limit_pressure &&
           abs(neighbor_pressure - limit_pressure) < tolerance)
  {
    // Low pressure region, near limit
    atomic_fraction = 1.4;
  }
  else if (neighbor_pressure < limit_pressure)
  {
    // Low pressure region
    atomic_fraction =
        0.5 - 1. / (0.001 + exp(-4.29 + 1.98e-02 * _neighbor_temperature[_qp] +
                                (-1.07 + 5.69e-04 * _neighbor_temperature[_qp]) *
                                    log(max(limit_pressure - neighbor_pressure, 1.e-10))));
  }

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
