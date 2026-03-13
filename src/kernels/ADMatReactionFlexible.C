/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "ADMatReactionFlexible.h"

// MOOSE includes
#include "MooseVariable.h"
#include "NonlinearSystem.h"

#include "metaphysicl/raw_type.h"

registerMooseObject("TMAP8App", ADMatReactionFlexible);

InputParameters
ADMatReactionFlexible::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addCoupledVar("vs",
                       "Set this to make vs a list of coupled variables, otherwise it will use the "
                       "kernel's nonlinear variable for v");
  params.addClassDescription(
      "Kernel to add -coeff*K*vs, where coeff=coefficient, K=reaction rate, vs=variables product");
  params.addParam<MaterialPropertyName>(
      "reaction_rate_name", "K", "The reaction rate used with the kernel");
  params.addParam<Real>("coeff",
                        1.,
                        "A coefficient for multiplying the reaction term. It can be used to "
                        "include the stoichiometry of a reaction for specific species.");
  return params;
}

ADMatReactionFlexible::ADMatReactionFlexible(const InputParameters & parameters)
  : ADKernel(parameters),
    _num_vs(coupledComponents("vs")),
    _vs(coupledValues("vs")),
    _reaction_rate(getADMaterialProperty<Real>("reaction_rate_name")),
    _coeff(getParam<Real>("coeff"))
{
}

ADReal
ADMatReactionFlexible::computeQpResidual()
{
  ADReal residual;
  if (_num_vs == 0)
    residual = -_coeff * _reaction_rate[_qp] * _test[_i][_qp];
  else
  {
    Real prod_vs = 1.0;
    for (const auto * const v : _vs)
      prod_vs *= (*v)[_qp];
    residual = -_coeff * _reaction_rate[_qp] * _test[_i][_qp] * prod_vs;
  }

  mooseAssert(MetaPhysicL::raw_value(residual) <= 0,
              "ADMatReactionFlexible returned a positive residual, which is not physically "
              "expected for this reaction kernel.");

  return residual;
}
