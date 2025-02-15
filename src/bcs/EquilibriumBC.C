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
#include "MooseFunctorArguments.h"
#include "FEProblemBase.h"

registerMooseObject("TMAP8App", EquilibriumBC);

InputParameters
EquilibriumBC::validParams()
{
  auto params = ADNodalBC::validParams();
  params.addClassDescription("Enforces a species equilibrium condition between an enclosure and an "
                             "adjacent diffusion structure.");
  params.addRequiredParam<MooseFunctorName>(
      "Ko", "The solubility coefficient $Ko$ for the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addParam<MooseFunctorName>(
      "activation_energy",
      "0.0",
      "The activation energy $Ea$ for the relationship $C_i = Ko exp{-Ea/RT} P_i^p$ (J/mol)");
  params.addParam<Real>(
      "p", 1.0, "The exponent $p$ in the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.addParam<SubdomainName>("enclosure_block", "Subdomain name of the enclosure");

  // Enclosure variable as a variable or a scalar variable
  params.addRequiredCoupledVar("enclosure_var",
                               "The coupled enclosure variable $P_i$ in the relationship $C_i = Ko "
                               "exp{-Ea/RT} P_i^p$. Can be a either a field or scalar variable.");
  params.addCoupledVar(
      "enclosure_scalar_var",
      "The coupled enclosure variable $P_i$ in the relationship $C_i = Ko exp{-Ea/RT} P_i^p$");
  params.deprecateCoupledVar("enclosure_scalar_var", "enclosure_var", "12/30/2024");

  // Temperature as a variable or a function
  params.addCoupledVar("temperature", "The boundary temperature as a variable");
  params.addParam<FunctionName>("temperature_function", "The boundary temperature");

  params.addParam<Real>(
      "var_scaling_factor", 1, "The number of atoms that compose our arbitrary unit for quantity");
  params.addParam<Real>("Ko_scaling_factor", 1, "Scaling factor on the solubility coefficient");
  return params;
}

EquilibriumBC::EquilibriumBC(const InputParameters & parameters)
  : ADNodalBC(parameters),
    _Ko(getFunctor<ADReal>("Ko")),
    _Ea(getFunctor<ADReal>("activation_energy")),
    _p(getParam<Real>("p")),
    _enclosure_var_bool_scalar(isCoupledScalar("enclosure_scalar_var")),
    _enclosure_var(_enclosure_var_bool_scalar ? adCoupledScalarValue("enclosure_var")
                                              : adCoupledValue("enclosure_var")),
    _T(isParamValid("temperature") ? &adCoupledValue("temperature") : nullptr),
    _T_function(isParamValid("temperature_function") ? &getFunction("temperature_function")
                                                     : nullptr),
    _var_scaling_factor(getParam<Real>("var_scaling_factor")),
    _K_scaling_factor(getParam<Real>("Ko_scaling_factor"))
{
  if (!isParamValid("temperature_function") && !isParamValid("temperature"))
    paramError("temperature", "The temperature must be specified.");

  // Use the enclosure subdomain if specified
  if (isParamValid("enclosure_block"))
  {
    _subdomain = _fe_problem.mesh().getSubdomainID(getParam<SubdomainName>("enclosure_block"));
  }
  else if (MooseUtils::parsesToReal(getParam<MooseFunctorName>("Ko")) &&
           MooseUtils::parsesToReal(getParam<MooseFunctorName>("activation_energy")))
  {
    _subdomain = Moose::INVALID_BLOCK_ID;
    _Ko_const = MooseUtils::convert<Real>(getParam<MooseFunctorName>("Ko"));
    _Ea_const = MooseUtils::convert<Real>(getParam<MooseFunctorName>("activation_energy"));
  }
  else
    paramError("enclosure_block",
               "The subdomain of the enclosure should be specified if Ko and Ea are not constants");
}

ADReal
EquilibriumBC::computeQpResidual()
{
  ADReal Ko, Ea;
  // Use the functors if a subdomain has been provided for the nodal evaluation
  if (_subdomain != Moose::INVALID_BLOCK_ID)
  {
    std::set<SubdomainID> subdomain_set = {_subdomain};
    const Moose::NodeArg node_arg = {_current_node, &subdomain_set};
    const auto state = determineState();
    Ko = _Ko(node_arg, state);
    Ea = _Ea(node_arg, state);
  }
  // Use the constant. Impossible to distinguish between enclosures without subdomains
  else
  {
    Ko = _Ko_const;
    Ea = _Ea_const;
  }

  ADReal K;
  if (_T)
    K = Ko * std::exp(-Ea / (PhysicalConstants::ideal_gas_constant * (*_T)[0]));
  else
    K = Ko * std::exp(-Ea / (PhysicalConstants::ideal_gas_constant *
                             _T_function->value(_t, *_current_node)));
  return (_u * _var_scaling_factor - _K_scaling_factor * K * std::pow(_enclosure_var[0], _p));
}
