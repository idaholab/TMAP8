/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "NodalKernel.h"

// Forward Declarations
class ReleasingNodalKernel;

template <>
InputParameters validParams<ReleasingNodalKernel>();

class ReleasingNodalKernel : public NodalKernel
{
public:
  ReleasingNodalKernel(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const Real _alpha_r;
  const VariableValue & _temp;
  const Real _trapping_energy;
};
