/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "TrappingNodalKernelBase.h"

/**
 * Trapping NodalKernel for trapped-species concentrations in physical units.
 */
class TrappingNodalKernel : public TrappingNodalKernelBase
{
public:
  TrappingNodalKernel(const InputParameters & parameters);

  static InputParameters validParams();
};
