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

  const Real _alpha_r;
  const Real _trapping_energy;
  const VariableValue & _temperature;
};
