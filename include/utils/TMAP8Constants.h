/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once
#include "PhysicalConstants.h"
namespace PhysicalConstants
{
// Tritium half-life (seconds)
// https://nvlpubs.nist.gov/nistpubs/jres/105/4/j54luc2.pdf
const auto tritium_half_life = 388800000.0;
const auto tritium_decay_const = 1.782785958230312e-09;
} // namespace PhysicalConstants
