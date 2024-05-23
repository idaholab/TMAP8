/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "Structure1D.h"
#include "TMAPUtils.h"
#include "DiffusionPhysicsBase.h"

registerMooseAction("TMAP8App", Structure1D, "add_mesh_generator");
registerMooseAction("TMAP8App", Structure1D, "init_component_physics");

InputParameters
Structure1D::validParams()
{
  auto params = ComponentAction::validParams();
  params += PhysicsComponentHelper::validParams();
  params += TMAP::structureCommonParams();
  params.addRequiredParam<unsigned int>("nx", "The number of elements in the structure.");
  params.addRequiredParam<Real>("xmax", "The maximum x-value.");
  params.addRequiredParam<Real>("length_unit_scaling", "Scaling to apply on the mesh");
  return params;
}

Structure1D::Structure1D(const InputParameters & params)
  : ComponentAction(params),
    PhysicsComponentHelper(params),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _scaling_factors(isParamValid("species_scaling_factors")
                         ? getParam<std::vector<Real>>("species_scaling_factors")
                         : std::vector<Real>(_species.size(), 1)),
    _ics(getParam<std::vector<Real>>("species_initial_concentrations")),
    _input_Ds(getParam<std::vector<FunctionName>>("diffusivities")),
    _length_unit(getParam<Real>("length_unit_scaling"))
{
  _dimension = 1;
  if (_species.size() != _scaling_factors.size())
    paramError("species_scaling_factors",
               "The number of species scaling factors must match the number of species.");

  if (_species.size() != _input_Ds.size())
    paramError("diffusivities", "The number of diffusivities must match the number of species.");

  if (_ics.size() && (_ics.size() != _species.size()))
    paramError("species_initial_concentrations",
               "The number of species concentrations must match the number of species.");
}

void
Structure1D::initComponentPhysics()
{
  // Check the type of the Physics. This component is not implemented for all types
  if (!physicsExists<DiffusionPhysicsBase>(_physics_names[0]))
    paramError("physics",
               "Physics '" + _physics_names[0] +
                   "' not a 'SpeciesTrappingPhysics'. This component has only been implemented for "
                   "'SpeciesTrappingPhysics'.");

  if (_verbose)
    mooseInfoRepeated("Adding Physics '" + _physics[0]->name() + "'.");

  // Transfer the data specified in the Component to the Physics
  const auto stp = dynamic_cast<DiffusionPhysicsBase *>(_physics[0]);
  stp->addComponent(*this);
}

void
Structure1D::addMeshGenerators()
{
  InputParameters params = _factory.getValidParams("GeneratedMeshGenerator");
  params.set<MooseEnum>("dim") = _dimension;
  params.set<Real>("xmax") = {getParam<Real>("xmax") * _length_unit};
  params.set<unsigned int>("nx") = {getParam<unsigned int>("nx")};
  params.set<std::string>("boundary_name_prefix") = name();
  params.set<SubdomainName>("subdomain_name") = name();
  _app.getMeshGeneratorSystem().addMeshGenerator(
      "GeneratedMeshGenerator", name() + "_base", params);

  // Keep track of the component mesh
  _mg_name = name() + "_base";
  _outer_boundaries.push_back(name() + "_left");
  _outer_boundaries.push_back(name() + "_right");
  _blocks.push_back(name());
}
