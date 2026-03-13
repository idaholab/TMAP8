/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "libmesh/libmesh_common.h"

#include <cmath>

namespace TMAP
{
template <typename T>
T
regularizedConcentration(const T & concentration)
{
  using std::sqrt;
  const Real epsilon = libMesh::TOLERANCE * libMesh::TOLERANCE;
  return 0.5 * (concentration + sqrt(concentration * concentration + epsilon * epsilon));
}
}
