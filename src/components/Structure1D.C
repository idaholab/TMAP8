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
  auto params = ActionComponent::validParams();
  params += PhysicsComponentBase::validParams();
  params += TMAP::structureCommonParams();
  params.addRequiredParam<unsigned int>("nx", "The number of elements in the structure.");
  params.addRequiredParam<Real>("xmax", "The maximum x-value.");
  params.addRequiredParam<Real>("length_unit_scaling", "Scaling to apply on the mesh");
  params.addParamNamesToGroup("nx xmax length_unit_scaling", "Geometry");
  // TODO: add a spatial offset
  return params;
}

Structure1D::Structure1D(const InputParameters & params)
  : ActionComponent(params),
    PhysicsComponentBase(params),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _ics(getParam<std::vector<Real>>("species_initial_concentrations")),
    _length_unit(getParam<Real>("length_unit_scaling"))
{
  _dimension = 1;

  if (_ics.size() && (_ics.size() != _species.size()))
    paramError("species_initial_concentrations",
               "The number of species concentrations must match the number of species.");
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
  _mg_names.push_back(name() + "_base");
  _outer_boundaries.push_back(name() + "_left");
  _outer_boundaries.push_back(name() + "_right");
  _blocks.push_back(name());
}
