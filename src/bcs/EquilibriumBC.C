/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "EquilibriumBC.h"
#include "PhysicalConstants.h"
#include "Function.h"

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
      "The activation energy $Ea$ for the relationship $C_i = Ko exp{-Ea/RT} P_i^p$ (J/mol)");
  params.addParam<Real>(
      "p", 1.0, "The exponent $p$ in the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addRequiredCoupledVar("enclosure_var",
                               "The coupled enclosure variable $P_i$ in the relationship $C_i = Ko "
                               "exp{-Ea/RT} P_i^p$. Can be a either a field or scalar variable.");
  params.addCoupledVar(
      "enclosure_scalar_var",
      "The coupled enclosure variable $P_i$ in the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addCoupledVar("temp", "The temperature");
  params.addParam<FunctionName>("temperature", "The boundary temperature");
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
    _T(isParamValid("temp") ? &adCoupledValue("temp") : nullptr),
    _T_function(isParamValid("temperature") ? &getFunction("temperature") : nullptr),
    _var_scaling_factor(getParam<Real>("var_scaling_factor"))
{
  if (!isParamValid("temp") && !isParamValid("temperature"))
    paramError("temp", "The temperature must be specified.");
}

ADReal
EquilibriumBC::computeQpResidual()
{
  ADReal K;
  if (_T)
    K = _Ko * std::exp(-1.0 * _Ea / (PhysicalConstants::ideal_gas_constant * (*_T)[0]));
  else
    K = _Ko *
        std::exp(-1.0 * _Ea /
                 (PhysicalConstants::ideal_gas_constant * _T_function->value(_t, *_current_node)));
  return (_u * _var_scaling_factor - K * std::pow(_enclosure_var[0], _p));
}
