/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "Enclosure0D.h"
#include "TMAPUtils.h"
#include "SorptionExchangePhysics.h"

registerMooseAction("TMAP8App", Enclosure0D, "init_component_physics");
registerMooseAction("TMAP8App", Enclosure0D, "add_material");
registerMooseAction("TMAP8App", Enclosure0D, "check_integrity");
registerMooseAction("TMAP8App", Enclosure0D, "add_mesh_generator");
registerActionComponent("TMAP8App", Enclosure0D);

InputParameters
Enclosure0D::validParams()
{
  auto params = ActionComponent::validParams();
  params += ComponentPhysicsInterface::validParams();
  params += ComponentMaterialPropertyInterface::validParams();
  params += TMAP::enclosureCommonParams();
  params.makeParamRequired<std::vector<PhysicsName>>("physics");
  return params;
}

Enclosure0D::Enclosure0D(const InputParameters & params)
  : ActionComponent(params),
    ComponentPhysicsInterface(params),
    ComponentMaterialPropertyInterface(params),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _scaling_factors(isParamValid("species_scaling_factors")
                         ? getParam<std::vector<Real>>("species_scaling_factors")
                         : std::vector<Real>(_species.size(), 1)),
    _ics(getParam<std::vector<Real>>("species_initial_pressures")),
    _species_Ks(getParam<std::vector<MooseFunctorName>>("equilibrium_constants")),
    _temperature(getParam<MooseFunctorName>("temperature")),
    _volume(getParam<Real>("volume")),
    _connected_structures(getParam<std::vector<ComponentName>>("connected_structures")),
    _connection_boundaries(getParam<std::vector<BoundaryName>>("connection_boundaries")),
    _connection_boundaries_area(getParam<std::vector<Real>>("connection_boundaries_area"))
{
  // Species parameter checks
  if (_species.size() != _scaling_factors.size())
    paramError("species_scaling_factors",
               "The number of species scaling factors must match the number of species.");
  if (_ics.size() && (_ics.size() != _species.size()))
    paramError("species_initial_pressures",
               "The number of species partial pressures must match the number of species.");

  // Physics checks
  if (_physics.empty())
    paramError("physics", "A physics must be specified in the enclosure");
  if (_physics.size() > 1)
    paramError("physics",
               "Enclosure0D has only been implemented for a single 'SorptionExchangePhysics'");
}

void
Enclosure0D::addMeshGenerators()
{
  // Add a single elem
  InputParameters params = _factory.getValidParams("ElementGenerator");
  // If specified use the block, if not the component name
  const auto block =
      isParamValid("block") ? getParam<std::vector<SubdomainName>>("block")[0] : name();
  params.set<SubdomainName>("subdomain_name") = block;

  // TODO: use a nodeelem instead of a Quad4
  params.set<std::vector<Point>>("nodal_positions") = {
      Point(0, 0, 0), Point(0, 1e-8, 0), Point(1e-8, 1e-8, 0), Point(1e-8, 0, 0)};
  params.set<std::vector<dof_id_type>>("element_connectivity") = {0, 1, 2, 3};
  params.set<MooseEnum>("elem_type") = "QUAD4";

  _app.getMeshGeneratorSystem().addMeshGenerator("ElementGenerator", name() + "_base", params);

  // Keep track of the component mesh
  _mg_names.push_back(name() + "_base");
  _blocks.push_back(block);
  _dimension = 0;
}

void
Enclosure0D::addPhysics()
{
  // Check the type of the Physics. This component is not implemented for all types
  if (!physicsExists<SorptionExchangePhysics>(_physics_names[0]))
    paramError(
        "physics",
        "Physics '" + _physics_names[0] +
            "' is not a 'SorptionExchangePhysics'. This component has only been implemented for "
            "'SorptionExchangePhysics'.");

  if (_verbose)
    mooseInfoRepeated("Adding Physics '" + _physics[0]->name() + "'.");

  // Transfer the data specified in the Component to the Physics
  const auto stp = dynamic_cast<SorptionExchangePhysics *>(_physics[0]);
  stp->addComponent(*this);
}

const BoundaryName &
Enclosure0D::connectedStructureBoundary(const ComponentName & conn_structure) const
{
  for (const auto i : index_range(_connected_structures))
    if (conn_structure == _connected_structures[i])
      return _connection_boundaries[i];
  mooseError("Connection boundary for connected structure '",
             conn_structure,
             "' was requested, but this structure does not appear to be connected. Connected "
             "structures include:\n",
             Moose::stringify(_connected_structures));
}

Real
Enclosure0D::connectedStructureBoundaryArea(const ComponentName & conn_structure) const
{
  for (const auto i : index_range(_connected_structures))
    if (conn_structure == _connected_structures[i])
      return _connection_boundaries_area[i];
  mooseError("Connection boundary area for connected structure '",
             conn_structure,
             "' was requested, but this structure does not appear to be connected. Connected "
             "structures include:\n",
             Moose::stringify(_connected_structures));
}

Real
Enclosure0D::outerSurfaceArea() const
{
  return std::accumulate(_connection_boundaries_area.begin(), _connection_boundaries_area.end(), 0);
}
