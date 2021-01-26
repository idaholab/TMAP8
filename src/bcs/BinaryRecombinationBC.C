/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "BinaryRecombinationBC.h"

registerMooseObject("TMAPApp", BinaryRecombinationBC);

InputParameters
BinaryRecombinationBC::validParams()
{
  auto params = ADIntegratedBC::validParams();
  params.addRequiredCoupledVar("v", "The other mobile variable that takes part in recombination");
  params.addParam<Real>("Kr", 1, "The recombination coefficient");
  return params;
}

BinaryRecombinationBC::BinaryRecombinationBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), _v(adCoupledValue("v")), _Kr(getParam<Real>("Kr"))
{
}

ADReal
BinaryRecombinationBC::computeQpResidual()
{
  return _test[_i][_qp] * _Kr * _u[_qp] * _v[_qp];
}
