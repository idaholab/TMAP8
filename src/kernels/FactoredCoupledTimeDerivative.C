/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "FactoredCoupledTimeDerivative.h"

registerMooseObject("TMAP8App", FactoredCoupledTimeDerivative);

InputParameters
FactoredCoupledTimeDerivative::validParams()
{
  InputParameters params = CoupledTimeDerivative::validParams();
  params.addClassDescription(
      "Adds factor * (ψ, ∂v/∂t) to the residual of the primary variable. "
      "Intended for the dimensionless trapping formulation where factor = C_t_ref / C_m_ref "
      "and no equation-level scaling is required.");
  params.addRequiredParam<Real>("factor", "Constant multiplier applied to the coupled time derivative.");
  return params;
}

FactoredCoupledTimeDerivative::FactoredCoupledTimeDerivative(const InputParameters & parameters)
  : CoupledTimeDerivative(parameters), _factor(getParam<Real>("factor"))
{
}

Real
FactoredCoupledTimeDerivative::computeQpResidual()
{
  return _factor * CoupledTimeDerivative::computeQpResidual();
}

Real
FactoredCoupledTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  return _factor * CoupledTimeDerivative::computeQpOffDiagJacobian(jvar);
}
