#include "DissociationFluxBC.h"

registerMooseObject("TMAPApp", DissociationFluxBC);

InputParameters
DissociationFluxBC::validParams()
{
  auto params = ADIntegratedBC::validParams();
  params.addRequiredCoupledVar("v",
                               "The (scalar) variable that is dissociating on this boundary to "
                               "form the mobile species (specified with the variable param)");
  params.addParam<Real>("Kd", 1, "The dissociation coefficient");
  return params;
}

DissociationFluxBC::DissociationFluxBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), _v(adCoupledValue("v")), _Kd(getParam<Real>("Kd"))
{
}

ADReal
DissociationFluxBC::computeQpResidual()
{
  return -_test[_i][_qp] * _Kd * _v[_qp];
}
