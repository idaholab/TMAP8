/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "EquilibriumBC.h"
#include "PhysicalConstants.h"

registerMooseObject("TMAP8App", EquilibriumBC);

InputParameters
EquilibriumBC::validParams()
{
  auto params = ADNodalBC::validParams();
  params.addClassDescription("Enforces a species equilibrium condition between an enclosure and an "
                             "adjacent diffusion structure.");
  params.addRequiredParam<Real>(
      "Ko", "The solubility coefficient $Ko$ for the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addParam<Real>(
      "activation_energy",
      0.0,
      "The activation energy $Ea$ for the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addParam<Real>(
      "p", 1.0, "The exponent $p$ in the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addRequiredCoupledVar(
      "enclosure_scalar_var",
      "The coupled enclosure variable $P_i$ in the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addRequiredCoupledVar("temp", "The temperature");
  params.addParam<Real>(
      "var_scaling_factor", 1, "The number of atoms that compose our arbitrary unit for quantity");
  return params;
}

EquilibriumBC::EquilibriumBC(const InputParameters & parameters)
  : ADNodalBC(parameters),
    _Ko(getParam<Real>("Ko")),
    _Ea(getParam<Real>("activation_energy")),
    _p(getParam<Real>("p")),
    _enclosure_var(adCoupledScalarValue("enclosure_scalar_var")),
    _T(adCoupledValue("temp")),
    _var_scaling_factor(getParam<Real>("var_scaling_factor"))
{
}

ADReal
EquilibriumBC::computeQpResidual()
{
  ADReal K = _Ko * std::exp(-1.0 * _Ea / (PhysicalConstants::ideal_gas_constant * _T[0]));
  return (_u * _var_scaling_factor - K * std::pow(_enclosure_var[0], _p));
}
