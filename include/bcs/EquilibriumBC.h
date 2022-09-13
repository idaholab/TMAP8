/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
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

  /// The equilibrium coefficient
  const Real _K;

  const Real _p;

  /// The enclosure variable
  const ADVariableValue & _enclosure_var;

  const Real _temp;

  /// Boltzmann's constant
  const Real _kb;

  /// The number of atoms that compose our arbitrary unit for quantity
  const Real _var_scaling_factor;

  const Real _penalty;
};
