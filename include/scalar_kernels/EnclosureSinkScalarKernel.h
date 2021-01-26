/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "ODEKernel.h"

class EnclosureSinkScalarKernel;

template <>
InputParameters validParams<EnclosureSinkScalarKernel>();

class EnclosureSinkScalarKernel : public ODEKernel
{
public:
  EnclosureSinkScalarKernel(const InputParameters & parameters);

protected:
  Real computeQpResidual() final;

  const PostprocessorValue & _flux;
  const Real _area;
  const Real _volume;
  const Real _concentration_to_pressure_conversion_factor;
};
