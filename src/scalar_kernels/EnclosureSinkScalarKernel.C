//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EnclosureSinkScalarKernel.h"

// MOOSE includes
#include "Assembly.h"
#include "MooseVariableScalar.h"

registerMooseObject("TMAPApp", EnclosureSinkScalarKernel);

template <>
InputParameters
validParams<EnclosureSinkScalarKernel>()
{
  InputParameters params = validParams<ODEKernel>();
  params.addRequiredParam<PostprocessorName>(
      "flux", "Name of the Postprocessor whose value will be the flux");
  params.addRequiredParam<Real>("surface_area", "The surface area of the structure");
  params.addRequiredParam<Real>("volume", "The volume of the enclosure");
  params.addParam<Real>(
      "concentration_to_pressure_conversion_factor",
      1,
      "The constant for converting from units of concentration to units of pressure");

  return params;
}

EnclosureSinkScalarKernel::EnclosureSinkScalarKernel(const InputParameters & parameters)
  : ODEKernel(parameters),
    _flux(getPostprocessorValue("flux")),
    _area(getParam<Real>("surface_area")),
    _volume(getParam<Real>("volume")),
    _concentration_to_pressure_conversion_factor(
        getParam<Real>("concentration_to_pressure_conversion_factor"))
{
}

Real
EnclosureSinkScalarKernel::computeQpResidual()
{
  return _flux * _area / _volume * _concentration_to_pressure_conversion_factor;
}
