/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TMAPScaling.h"

namespace TMAP
{
namespace Scaling
{
void
addTrappingEquationScaleParams(InputParameters & params)
{
  params.addRangeCheckedParam<Real>("trap_concentration_reference",
                                    1.0,
                                    "trap_concentration_reference>0",
                                    "Reference scale for the trapped concentration variable.");
  params.addRangeCheckedParam<Real>("mobile_concentration_reference",
                                    1.0,
                                    "mobile_concentration_reference>0",
                                    "Reference scale for the coupled mobile concentration.");
  params.addRangeCheckedParam<Real>("site_density_reference",
                                    1.0,
                                    "site_density_reference>0",
                                    "Reference scale for the host or trap site density.");
  params.addRangeCheckedParam<Real>(
      "time_reference", 1.0, "time_reference>0", "Reference timescale for the trapping equations.");
  params.addRangeCheckedParam<Real>("temperature_reference",
                                    1.0,
                                    "temperature_reference>0",
                                    "Reference temperature scale for trapping equations.");
}

void
addMobileEquationScaleParams(InputParameters & params)
{
  params.addRangeCheckedParam<Real>(
      "primary_concentration_reference",
      1.0,
      "primary_concentration_reference>0",
      "Reference scale for the primary variable of the mobile balance equation.");
  params.addRangeCheckedParam<Real>(
      "coupled_concentration_reference",
      1.0,
      "coupled_concentration_reference>0",
      "Reference scale for the coupled variable contributing to the mobile balance equation.");
  params.addRangeCheckedParam<Real>(
      "time_reference", 1.0, "time_reference>0", "Reference timescale for the mobile equation.");
}

TrappingEquationScaling::TrappingEquationScaling(const InputParameters & parameters)
  : _trap_concentration_reference(parameters.get<Real>("trap_concentration_reference")),
    _mobile_concentration_reference(parameters.get<Real>("mobile_concentration_reference")),
    _site_density_reference(parameters.get<Real>("site_density_reference")),
    _time_reference(parameters.get<Real>("time_reference")),
    _temperature_reference(parameters.get<Real>("temperature_reference"))
{
}

MobileEquationScaling::MobileEquationScaling(const InputParameters & parameters)
  : _primary_concentration_reference(parameters.get<Real>("primary_concentration_reference")),
    _coupled_concentration_reference(parameters.get<Real>("coupled_concentration_reference")),
    _time_reference(parameters.get<Real>("time_reference"))
{
}
}
}
