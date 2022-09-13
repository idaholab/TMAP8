/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "UnaryRecombinationBC.h"

registerMooseObject("TMAPApp", UnaryRecombinationBC);

InputParameters
UnaryRecombinationBC::validParams()
{
  auto params = ADIntegratedBC::validParams();
  params.addParam<Real>("Kr", 1, "The recombination coefficient");
  return params;
}

UnaryRecombinationBC::UnaryRecombinationBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), _Kr(getParam<Real>("Kr"))
{
}

ADReal
UnaryRecombinationBC::computeQpResidual()
{
  return _test[_i][_qp] * _Kr * _u[_qp] * _u[_qp];
}
