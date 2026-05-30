/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
/*TEst*/
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======

>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
=======
>>>>>>> 01afd064 (Zr2Fe Hydride PCT Modelling Files)
=======
=======

>>>>>>> b4a96a35 (Formatting modification and simplifiying python codes)
>>>>>>> 97a609b1 (Formatting modification and simplifiying python codes)
=======
>>>>>>> dba0bff8 (Adding test files, adding data, applying recommende changes)
#include "ADMatInterfaceReactionZr2FeHxPCT.h"

#include "PhysicalConstants.h"

registerMooseObject("TMAP8App", ADMatInterfaceReactionZr2FeHxPCT);

InputParameters
ADMatInterfaceReactionZr2FeHxPCT::validParams()
<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======
>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
  params.addParam<bool>(
      "silence_warnings", false, "Whether to silence correlation out of bound warnings");
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======
>>>>>>> 284d7cfb (Modification to Zr2FeHx PCT Modelling)
  return params;
}

ADMatInterfaceReactionZr2FeHxPCT::ADMatInterfaceReactionZr2FeHxPCT(
    const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _neighbor_temperature(this->template coupledGenericValue<true>("neighbor_temperature")),
    _density(getADMaterialProperty<Real>("density")),
    _kf(getADMaterialProperty<Real>("forward_rate")),
<<<<<<< HEAD
<<<<<<< HEAD
    _kb(getNeighborADMaterialProperty<Real>("backward_rate"))
=======
    _kb(getNeighborADMaterialProperty<Real>("backward_rate")),
    _silence_warnings(getParam<bool>("silence_warnings"))
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======
    _kb(getNeighborADMaterialProperty<Real>("backward_rate"))
>>>>>>> 284d7cfb (Modification to Zr2FeHx PCT Modelling)
{
}

ADReal
ADMatInterfaceReactionZr2FeHxPCT::computeQpResidual(Moose::DGResidualType type)
{
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  // Variables
  ADReal limit_pressure = 5.; // lower pressure limit of fit
  ADReal r = 0.;

=======
>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
=======
  // Variables
  ADReal limit_pressure = 5; // lower pressure limit of fit
  ADReal r = 0;


>>>>>>> 284d7cfb (Modification to Zr2FeHx PCT Modelling)
  using std::exp;
  using std::log;
  using std::max;

<<<<<<< HEAD
<<<<<<< HEAD
  // Gas pressure (Pa): R * T * c / 2 (two atoms per molecule)
  auto neighbor_pressure =
      PhysicalConstants::ideal_gas_constant * _neighbor_temperature[_qp] * _neighbor_value[_qp] / 2;

  // Give a warning if the initial or computed neighbor pressure is out of the analytical model
  if (((neighbor_pressure < 7) || (neighbor_pressure > 5e5)))
=======
=======
>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
  ADReal r = 0;
=======
>>>>>>> 284d7cfb (Modification to Zr2FeHx PCT Modelling)

  // Gas pressure (Pa): R * T * c / 2 (two atoms per molecule)
  auto neighbor_pressure =
      PhysicalConstants::ideal_gas_constant * _neighbor_temperature[_qp] * _neighbor_value[_qp] / 2;

<<<<<<< HEAD
  // Calculate the value of the pressures-limiter
  auto limit_pressure = exp(-4.12 + 1.03e-2 * _neighbor_temperature[_qp]);

<<<<<<< HEAD
  // return warning if the PCT curves is used out of bounds (pressure in Pa)
  if (!_silence_warnings && ((neighbor_pressure < limit_pressure) || (neighbor_pressure > 1.e6)))
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======
  // Give a warning if the initial or computed neighbor pressure is out of the analytical model
  if ((neighbor_pressure > 9.e06) || (neighbor_pressure < 0.011))
>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
=======
  // Give a warning if the initial or computed neighbor pressure is out of the analytical model
  if (((neighbor_pressure < 7) || (neighbor_pressure > 5e5)))
>>>>>>> 284d7cfb (Modification to Zr2FeHx PCT Modelling)
    mooseDoOnce(mooseWarning("In Zr2FeHxPCT: pressure ",
                             neighbor_pressure,
                             "Pa and temperature ",
                             _neighbor_temperature[_qp],
                             "K are outside the bounds of the atomic fraction correlation. See "
                             "documentation for Zr2FeHxPCT material."));

  // Calculate the atomic fraction based on the PCT curve
<<<<<<< HEAD
<<<<<<< HEAD
  auto atomic_fraction =
      5.0 - 8.32e-03 / (1.e-03 + exp(-2.49 - 7.62e-03 * _neighbor_temperature[_qp] +
                                     (5.63e-02 + 1.72e-04 * _neighbor_temperature[_qp]) *
                                         log(max(neighbor_pressure - limit_pressure, 1.e-10))));
=======

  auto atomic_fraction =
      4.30 - 1.8103 / (0.5 + exp(5.4074 - 1.3571e-02 * _neighbor_temperature[_qp] +
                                 (2.3190e-01 + 1.5078e-04 * _neighbor_temperature[_qp]) *
                                     log(max(neighbor_pressure - limit_pressure, 1e-10))));
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======
  auto atomic_fraction =
<<<<<<< HEAD
      4.30 - 1.81 / (0.5 + exp(5.41 - 1.36e-02 * _neighbor_temperature[_qp] +
<<<<<<< HEAD
                                 (2.32e-01 + 1.51e-04 * _neighbor_temperature[_qp]) *
                                     log(max(neighbor_pressure - limit_pressure, 1.e-10))));
>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
=======
                               (2.32e-01 + 1.51e-04 * _neighbor_temperature[_qp]) *
=======
      5.0 - 8.32e-03 / (1e-03 + exp(-2.49 - 7.61e-03 * _neighbor_temperature[_qp] +
                               (5.63e-02 + 1.72e-04 * _neighbor_temperature[_qp]) *
>>>>>>> 284d7cfb (Modification to Zr2FeHx PCT Modelling)
                                   log(max(neighbor_pressure - limit_pressure, 1.e-10))));
>>>>>>> 79918106 (Applying python and source file formatting patches)

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
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

=======
>>>>>>> 39e67609 (Zr2Fe Hydride PCT Modelling Files)
=======

>>>>>>> 30788c75 (Formatting modification and simplifiying python codes)
=======
>>>>>>> 01afd064 (Zr2Fe Hydride PCT Modelling Files)
=======

>>>>>>> 97a609b1 (Formatting modification and simplifiying python codes)
  return r;
}
