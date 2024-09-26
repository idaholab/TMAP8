/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "Enclosure0D.h"
#include "TMAPUtils.h"
#include "PointTrappingPhysics.h"

registerMooseAction("TMAP8App", Enclosure0D, "init_component_physics");

InputParameters
Enclosure0D::validParams()
{
  auto params = ActionComponent::validParams();
  params += PhysicsComponentBase::validParams();
  params += TMAP::enclosureCommonParams();
  params.makeParamRequired<std::vector<PhysicsName>>("physics");
  return params;
}

Enclosure0D::Enclosure0D(const InputParameters & params)
  : ActionComponent(params),
    PhysicsComponentBase(params),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _scaling_factors(isParamValid("species_scaling_factors")
                         ? getParam<std::vector<Real>>("species_scaling_factors")
                         : std::vector<Real>(_species.size(), 1)),
    _ics(getParam<std::vector<Real>>("species_initial_pressures")),
    _temperature(getParam<Real>("temperature")),
    _surface_area(getParam<Real>("surface_area")),
    _volume(getParam<Real>("volume")),
    _outer_boundaries({getParam<BoundaryName>("boundary")})
{
  if (_species.size() != _scaling_factors.size())
    paramError("species_scaling_factors",
               "The number of species scaling factors must match the number of species.");

  if (_ics.size() && (_ics.size() != _species.size()))
    paramError("species_initial_pressures",
               "The number of species partial pressures must match the number of species.");
  if (_physics.empty())
    paramError("physics", "A physics must be specified in the enclosure");
  if (_physics.size() > 1)
    paramError("physics",
               "Enclosure0D has only been implemented for a single 'PointTrappingPhysics'");
}

void
Enclosure0D::initComponentPhysics()
{
  // Check the type of the Physics. This component is not implemented for all types
  if (!physicsExists<PointTrappingPhysics>(_physics_names[0]))
    paramError("physics",
               "Physics '" + _physics_names[0] +
                   "' not a 'PointTrappingPhysics'. This component has only been implemented for "
                   "'PointTrappingPhysics'.");

  if (_verbose)
    mooseInfoRepeated("Adding Physics '" + _physics[0]->name() + "'.");

  // Transfer the data specified in the Component to the Physics
  const auto stp = dynamic_cast<PointTrappingPhysics *>(_physics[0]);
  stp->addComponent(*this);
}
