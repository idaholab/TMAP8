/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "ADMatCoupledDefectAnnihilation.h"

// MOOSE includes
#include "MooseVariable.h"
#include "NonlinearSystem.h"

registerMooseObject("MooseApp", ADMatCoupledDefectAnnihilation);

InputParameters
ADMatCoupledDefectAnnihilation::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addCoupledVar("v",
                       "Set this to make v a coupled variable, otherwise it will use the "
                       "kernel's nonlinear variable for v");
  params.addClassDescription(
      "Kernel to add K*v*(c0-c), where K=annihilation rate, u=variable, v=coupled variable");
  params.addParam<MaterialPropertyName>(
      "eq_concentration",
      "u_0",
      "The equilibrium concentration of the variable used with the kernel");
  params.addParam<MaterialPropertyName>(
      "annihilation_rate", "K", "The annihilation rate used with the kernel");
  params.addParam<Real>("coeff",
                        1.,
                        "A coefficient for multiplying the The annihilation rate. It can be used "
                        "for sensitivity analysis.");
  return params;
}

ADMatCoupledDefectAnnihilation::ADMatCoupledDefectAnnihilation(const InputParameters & parameters)
  : ADKernel(parameters),
    _v(isCoupled("v") ? adCoupledValue("v") : _u),
    _u_0(getADMaterialProperty<Real>("eq_concentration")),
    _K(getADMaterialProperty<Real>("annihilation_rate")),
    _coeff(getParam<Real>("coeff"))
{
}

ADReal
ADMatCoupledDefectAnnihilation::computeQpResidual()
{
  return -_coeff * _K[_qp] * _test[_i][_qp] * (_u_0[_qp] - _u[_qp]) * _v[_qp];
}
