/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "YHxPCT.h"

registerMooseObject("TMAP8App", YHxPCT);
registerMooseObject("TMAP8App", ADYHxPCT);

template <bool is_ad>
InputParameters
YHxPCTTempl<is_ad>::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("Computes the surface atomic fraction of YHx from the temperature and "
                             "partial pressure based on the PCT curves.");
  params.addRequiredCoupledVar("pressure", "Coupled partial pressure (Pa)");
  params.addRequiredCoupledVar("temperature", "Coupled temperature (K)");
  params.addParam<std::string>("base_name",
                               "Optional parameter that allows the user to define multiple "
                               "material systems on the same block, i.e. for multiple phases");
  params.addParam<bool>(
      "silence_warnings", false, "Whether to silence correlation out of bound warnings");
  return params;
}

template <bool is_ad>
YHxPCTTempl<is_ad>::YHxPCTTempl(const InputParameters & parameters)
  : Material(parameters),
    _pressure(coupledGenericValue<is_ad>("pressure")),
    _temperature(coupledGenericValue<is_ad>("temperature")),
    _base_name(isParamValid("base_name") ? getParam<std::string>("base_name") + "_" : ""),
    _atomic_fraction_name(_base_name + "atomic_fraction"),
    _atomic_fraction_dT_name(_atomic_fraction_name + "_dT"),
    _atomic_fraction(declareGenericProperty<Real, is_ad>(_atomic_fraction_name)),
    _atomic_fraction_dT(is_ad ? nullptr
                              : &declareGenericProperty<Real, is_ad>(_atomic_fraction_dT_name)),
    _atomic_fraction_dP(is_ad ? nullptr
                              : &declareGenericProperty<Real, is_ad>(_atomic_fraction_dP_name)),
    _silence_warnings(this->template getParam<bool>("silence_warnings"))
{
}

template <bool is_ad>
void
YHxPCTTempl<is_ad>::computeQpProperties()
{
  auto limit_pressure = std::exp(-26.1 + 3.88e-2 * _temperature[_qp] - 9.7e-6 * Utility::pow<2>(_temperature[_qp]));

  if (!_silence_warnings && ((_pressure[_qp] < limit_pressure) || (_pressure[_qp] > 1.e6)))
    mooseDoOnce(mooseWarning("In YHxPCT: pressure ",
                             _pressure[_qp],
                             "Pa and temperature ",
                             _temperature[_qp],
                             "K are outside the bounds of the atomic fraction correlation. See "
                             "documentation for YHxPCT material."));

  _atomic_fraction[_qp] = 2. - std::pow(1. + std::exp(21.6 - 0.0225 * _temperature[_qp] +
                                                 (-0.0445 + 7.18e-4 * _temperature[_qp]) *
                                                     (std::log(_pressure[_qp] - limit_pressure))),
                                   -1);
  if (!is_ad)
  {
    (*_atomic_fraction_dT)[_qp] = 0.0;
    (*_atomic_fraction_dP)[_qp] = 0.0;
  }
}

template class YHxPCTTempl<false>;
template class YHxPCTTempl<true>;
