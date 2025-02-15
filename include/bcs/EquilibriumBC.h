/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ADNodalBC.h"

class EquilibriumBC : public ADNodalBC
{
public:
  EquilibriumBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  /// The solubility coefficient
  const Moose::Functor<ADReal> & _Ko;
  /// The solubility coefficient as a constant
  Real _Ko_const;

  /// The solubility activation energy (J/mol)
  const Moose::Functor<ADReal> & _Ea;
  /// The solubility activation energy (J/mol)
  Real _Ea_const;

  /// The exponent of the solution law
  const Real _p;

  /// The enclosure variable
  const bool _enclosure_var_bool_scalar;
  const ADVariableValue & _enclosure_var;
  /// The subdomain of the enclosure
  subdomain_id_type _subdomain;

  /// The temperature as a variable (K)
  const ADVariableValue * const _T;

  /// The temperature as a function (K)
  const Function * _T_function;

  /// The number of atoms that compose our arbitrary unit for quantity
  const Real _var_scaling_factor;
  /// A scaling factor on the solubility, convenient for unit conversions
  const Real _K_scaling_factor;
};
