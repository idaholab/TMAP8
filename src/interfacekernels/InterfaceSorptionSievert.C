/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "InterfaceSorptionSievert.h"

registerMooseObject("TMAPApp", InterfaceSorptionSievert);
registerMooseObject("TMAPApp", ADInterfaceSorptionSievert);

template <bool is_ad>
InputParameters
InterfaceSorptionSievertTempl<is_ad>::validParams()
{
  InputParameters params = InterfaceKernelParent<is_ad>::validParams();
  params.addClassDescription(
      "Computes Sievert's law at interface between solid and gas in isothermal conditions.");
  params.addRequiredParam<Real>("K0",
                                "The pre-exponential factor for the Arrhenius law for the "
                                "solubility $K$ for the relationship $C_i = KP_i^p$");
  params.addParam<Real>("Ea",
                        0,
                        "The activation energy for the Arrhenius law for the solubility $K$ for "
                        "the relationship $C_i = KP_i^p$");
  params.addParam<Real>(
      "unit_scale", 1.0, "Unit conversion factor used to scale the concentration");
  params.addParam<Real>("unit_scale_neighbor",
                        1.0,
                        "Unit conversion factor used to scale the neighbor (gas) concentration");

  params.addRequiredCoupledVar("temperature", "The coupled temperature variable");

  params.addParam<Real>(
      "sorption_penalty", 1.0, "Penalty associated with the concentration imbalance");
  params.addParam<bool>("use_flux_penalty",
                        false,
                        "Whether to use the penalty formulation to enforce the flux balance");
  params.addParam<Real>("flux_penalty", 1.0, "Penalty associated with the flux balance");

  params.addParam<MaterialPropertyName>("diffusivity", "diffusivity", "The diffusion coefficient");
  return params;
}

template <bool is_ad>
InterfaceSorptionSievertTempl<is_ad>::InterfaceSorptionSievertTempl(
    const InputParameters & parameters)
  : InterfaceKernelParent<is_ad>(parameters),
    _K0(this->template getParam<Real>("K0")),
    _Ea(this->template getParam<Real>("Ea")),

    _unit_scale(this->template getParam<Real>("unit_scale")),
    _unit_scale_neighbor(this->template getParam<Real>("unit_scale_neighbor")),

    _T(this->template coupledGenericValue<is_ad>("temperature")),

    _sorption_penalty(this->template getParam<Real>("sorption_penalty")),
    _use_flux_penalty(this->template getParam<bool>("use_flux_penalty")),
    _flux_penalty(_use_flux_penalty ? this->template getParam<Real>("flux_penalty") : 0.0),

    _diffusivity(this->template getGenericMaterialProperty<Real, is_ad>("diffusivity")),
    _diffusivity_neighbor(
        _use_flux_penalty
            ? &this->template getGenericNeighborMaterialProperty<Real, is_ad>("diffusivity")
            : nullptr)
{
  if (!_use_flux_penalty && parameters.isParamSetByUser("flux_penalty"))
    this->template paramError(
        "flux_penalty", "The flux penalty should be specified only when use_flux_penalty = true");
}

template <bool is_ad>
GenericReal<is_ad>
InterfaceSorptionSievertTempl<is_ad>::computeQpResidual(Moose::DGResidualType type)
{
  // restrict inputs to physically meaningful values to avoid encountering NANs during linear solve
  const auto small = 1.0e-20;
  const GenericReal<is_ad> u = std::max(small, _unit_scale * _u[_qp]);
  const GenericReal<is_ad> u_neighbor =
      std::max(small, _unit_scale_neighbor * _neighbor_value[_qp]);
  const GenericReal<is_ad> temperature_limited = std::max(small, _T[_qp]);
  const auto R = 8.31446261815324; // ideal gas constant (W/(m2-K))

  GenericReal<is_ad> r = 0; // residual

  switch (type)
  {
    case Moose::Element:
    {
      r = _test[_i][_qp] * _sorption_penalty *
          (u - _K0 * std::exp(-_Ea / R / temperature_limited) *
                   std::sqrt(u_neighbor * R * temperature_limited));
      break;
    }

    case Moose::Neighbor:
    {
      if (_use_flux_penalty)
        r = _test_neighbor[_i][_qp] * _flux_penalty * _normals[_qp] *
            (_diffusivity[_qp] * _grad_u[_qp] -
             (*_diffusivity_neighbor)[_qp] * _grad_neighbor_value[_qp]);
      else
        r = _test_neighbor[_i][_qp] * _normals[_qp] * _diffusivity[_qp] * _grad_u[_qp];
      break;
    }
  }
  return r;
}

template <>
Real
InterfaceSorptionSievertTempl<false>::computeQpJacobian(Moose::DGJacobianType type)
{
  // restrict inputs to physically meaningful values to avoid encountering NANs during linear solve
  const Real small = 1.0e-20;
  const Real u_neighbor = std::max(small, _unit_scale_neighbor * _neighbor_value[_qp]);
  const Real temperature_limited = std::max(small, _T[_qp]);
  const auto R = 8.31446261815324; // ideal gas constant (W/(m2-K))

  Real jac = 0; // jacobian

  switch (type)
  {
    case Moose::ElementElement:
      jac = _test[_i][_qp] * _sorption_penalty * _phi[_j][_qp] * (1);
      break;

    case Moose::ElementNeighbor:
      jac = -_test[_i][_qp] * _sorption_penalty * _phi_neighbor[_j][_qp] *
            (_K0 * std::exp(-_Ea / R / temperature_limited) * std::sqrt(R * temperature_limited) *
             1 / 2 * std::pow(u_neighbor, -1 / 2));
      break;

    case Moose::NeighborElement:
      if (_use_flux_penalty)
        jac = _test_neighbor[_i][_qp] * _flux_penalty * _normals[_qp] * _diffusivity[_qp] *
              _grad_phi[_j][_qp];
      else
        jac = _test_neighbor[_i][_qp] * _diffusivity[_qp] * _grad_phi[_j][_qp] * _normals[_qp];
      break;

    case Moose::NeighborNeighbor:
      if (_use_flux_penalty)
        jac = -_test_neighbor[_i][_qp] * _flux_penalty * _normals[_qp] *
              (*_diffusivity_neighbor)[_qp] * _grad_phi_neighbor[_j][_qp];
      break;
  }
  return jac;
}

template <>
Real InterfaceSorptionSievertTempl<true>::computeQpJacobian(Moose::DGJacobianType /*type*/)
{
  mooseError("ADInterfaceSorptionSievert '",
             name(),
             "': in , computeQpJacobian incorrectly called from within AD "
             "calculation");
}

template class InterfaceSorptionSievertTempl<false>;
template class InterfaceSorptionSievertTempl<true>;
