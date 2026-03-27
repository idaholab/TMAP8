/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "NodalKernel.h"

class ReleasingNodalKernelBase : public NodalKernel
{
public:
  static InputParameters validParams();

protected:
  ReleasingNodalKernelBase(const InputParameters & parameters, Real release_rate);

  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const Real _release_rate;
  const Real _detrapping_energy;
  const VariableValue & _temperature;
};
