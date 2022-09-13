/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "LMTimeKernel.h"
#include "MooseVariableFE.h"

InputParameters
LMTimeKernel::validParams()
{
  auto params = LMKernel::validParams();
  params.set<MultiMooseEnum>("vector_tags") = "time";
  params.set<MultiMooseEnum>("matrix_tags") = "system time";
  return params;
}

LMTimeKernel::LMTimeKernel(const InputParameters & parameters)
  : LMKernel(parameters), _u_dot(_var.adUDot())
{
}
