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
  const Real _Ko;

  /// The solubility activation energy (J/mol)
  const Real _Ea;

  /// The exponent of the solution law
  const Real _p;

  /// The enclosure variable
  const bool _enclosure_var_bool_scalar;
  const ADVariableValue & _enclosure_var;

  /// The temperature (K)
  const ADVariableValue & _T;

  /// The number of atoms that compose our arbitrary unit for quantity
  const Real _var_scaling_factor;
};
