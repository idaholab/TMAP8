/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "PressureReleaseFluxIntegral.h"

registerMooseObject("TMAPApp", PressureReleaseFluxIntegral);

InputParameters
PressureReleaseFluxIntegral::validParams()
{
  InputParameters params = SideIntegralVariablePostprocessor::validParams();
  params.addRequiredParam<MaterialPropertyName>(
      "diffusivity",
      "The name of the diffusivity material property that will be used in the flux computation.");
  params.addClassDescription(
      "Computes the integral of the flux over the specified boundary and over time.");
  params.addRequiredParam<Real>("surface_area", "The surface area of the structure");
  params.addRequiredParam<Real>("volume", "The volume of the enclosure");
  params.addParam<Real>(
      "concentration_to_pressure_conversion_factor",
      1,
      "The constant for converting from units of concentration to units of pressure");
  return params;
}

PressureReleaseFluxIntegral::PressureReleaseFluxIntegral(const InputParameters & parameters)
  : SideIntegralVariablePostprocessor(parameters),
    _diffusivity(parameters.get<MaterialPropertyName>("diffusivity")),
    _diffusion_coef(getMaterialProperty<Real>(_diffusivity)),
    _area(getParam<Real>("surface_area")),
    _volume(getParam<Real>("volume")),
    _concentration_to_pressure_conversion_factor(
        getParam<Real>("concentration_to_pressure_conversion_factor"))
{
  if (_mesh.dimension() != 1)
    mooseError("The PressureReleaseFluxIntegral object is currently coded with the assumption that "
               "structures are one-dimensional and enclosures are 0-dimensional.");
}

Real
PressureReleaseFluxIntegral::computeQpIntegral()
{
  return -_diffusion_coef[_qp] * _grad_u[_qp] * _normals[_qp] * _area / _volume *
         _concentration_to_pressure_conversion_factor * _dt;
}
