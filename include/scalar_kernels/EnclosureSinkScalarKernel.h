/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ODEKernel.h"

class EnclosureSinkScalarKernel : public ODEKernel
{
public:
  EnclosureSinkScalarKernel(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  Real computeQpResidual() final;

  const PostprocessorValue & _flux;
  const Real _area;
  const Real _volume;
  const Real _concentration_to_pressure_conversion_factor;
};
