/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "NodalKernel.h"

class ReleasingNodalKernel : public NodalKernel
{
public:
  ReleasingNodalKernel(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  /// Release coefficient
  const Real _alpha_r;
  /// Energy from detrapping
  const Real _detrapping_energy;
  /// Local temperature
  const VariableValue & _temperature;
  /// Species concentration
  const VariableValue & _v;
  /// Index of the species variable
  const unsigned int _v_index;
  /// Whether the v variable is the kernel's variable parameter variable
  const bool _v_is_u;
  /// Whether the kernels are mass lumped to make it compatible
  const bool _mass_lumped;
  /// Local node mass
  const VariableValue & _nodal_mass;
  /// An array with ones for convenience
  const VariableValue _one;
};
