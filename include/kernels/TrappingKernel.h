/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ADKernel.h"

class Function;

/**
 * Implements the contribution to the residual and Jacobian using a volumetric integration and
 * automatic differentiation
 */
class TrappingKernel : public ADKernel
{
public:
  TrappingKernel(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  /// Trapping coefficient
  const Real _alpha_t;
  /// Trapping energy
  const Real _trapping_energy;
  const Real _N;
  const Function & _Ct0;
  /// Concentration of the mobile species
  const ADVariableValue & _mobile_concentration;
  /// Number of other species competing for the same traps
  unsigned int _n_other_concs;
  /// Concentration of the other species
  std::vector<const ADVariableValue *> _trapped_concentrations;
  const Real _trap_per_free;
  /// Local temperature
  const ADVariableValue & _temperature;
};
