/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "Structure1D.h"
#include "TMAPUtils.h"
#include "MooseParsedFunction.h"
#include "THMMesh.h"

#include "libmesh/unstructured_mesh.h"
#include "libmesh/boundary_info.h"
#include "libmesh/mesh_generation.h"

registerMooseObject("TMAPApp", Structure1D);

InputParameters
Structure1D::validParams()
{
  auto params = Component::validParams();
  params += TMAP::structureCommonParams();
  params.addRequiredParam<unsigned int>("nx", "The number of elements in the structure.");
  params.addRequiredParam<Real>("xmax", "The maximum x-value.");
  return params;
}

Structure1D::Structure1D(const InputParameters & params)
  : Component(params),
    FunctionInterface(this),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _scaling_factors(isParamValid("species_scaling_factors")
                         ? getParam<std::vector<Real>>("species_scaling_factors")
                         : std::vector<Real>(_species.size(), 1)),
    _ics(isParamValid("species_initial_concentrations")
             ? getParam<std::vector<Real>>("species_initial_concentrations")
             : std::vector<Real>()),
    _input_Ds(getParam<std::vector<FunctionName>>("diffusivities")),
    _length_unit(getParam<Real>("length_unit"))
{
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
Structure1D::setupMesh()
{
  auto & lm_mesh = static_cast<UnstructuredMesh &>(_mesh.getMesh());
  MeshTools::Generation::build_line(
      lm_mesh, getParam<unsigned int>("nx"), 0, getParam<Real>("xmax") * _length_unit, EDGE2);
  auto & bi = lm_mesh.get_boundary_info();
  bi.sideset_name(0) = name() + "_left";
  bi.nodeset_name(0) = name() + "_left";
  bi.sideset_name(1) = name() + "_right";
  bi.nodeset_name(1) = name() + "_right";
}

void
Structure1D::addVariables()
{
  for (const auto i : index_range(_species))
    // Has another structure component already added this variable?
    if (!_sim.hasVariable(_species[i]))
      _sim.addSimVariable(true, _species[i], FEType(FIRST, LAGRANGE), _scaling_factors[i]);
}

void
Structure1D::addMooseObjects()
{
  for (const auto i : index_range(_ics))
  {
    const std::string class_name = "ConstantIC";
    auto params = _factory.getValidParams(class_name);
    params.set<Real>("value") = _ics[i];
    params.set<VariableName>("variable") = _species[i];
    params.applyParameter(_pars, "block");
    _sim.addInitialCondition(
        class_name,
        MooseUtils::join(std::vector<std::string>({_species[i], name(), "ic"}), "_"),
        params);
  }

  std::vector<FunctionName> scaled_D_functions(_species.size());

  // First create the functions that will be consumed by the material
  for (const auto i : index_range(_species))
  {
    const auto & input_D = getFunctionByName(_input_Ds[i]);
    if (!dynamic_cast<const MooseParsedFunction *>(&input_D))
      paramError("equilibrium_constants", "All TMAP functions should be parsed functions");

    const auto & input_D_params = input_D.parameters();
    const auto & input_D_value = input_D_params.get<std::string>("value");
    const std::string scaled_D_value =
        std::to_string(_length_unit) + "^2 * (" + input_D_value + ")";

    const std::string class_name = "ParsedFunction";
    auto params = _factory.getValidParams(class_name);
    params.set<std::string>("value") = scaled_D_value;
    params.applyParameter(input_D_params, "vars");
    params.applyParameter(input_D_params, "vals");
    _sim.addFunction(class_name, _input_Ds[i] + "_scaled", params);
    scaled_D_functions[i] = _input_Ds[i] + "_scaled";
  }

  // Next create the material that will be consumed by the diffusion kernels
  {
    const std::string class_name = "GenericFunctionMaterial";
    auto params = _factory.getValidParams(class_name);
    params.applyParameter(_pars, "block");
    std::vector<std::string> prop_names(_species.size());
    for (const auto i : index_range(_species))
      prop_names[i] = "D_" + _species[i];
    params.set<std::vector<std::string>>("prop_names") = prop_names;
    params.set<std::vector<FunctionName>>("prop_values") = scaled_D_functions;
    _sim.addMaterial(class_name, "diff_material_" + name(), params);
  }

  // Now create the kernels
  for (const auto i : index_range(_species))
  {
    const auto & specie = _species[i];

    {
      const std::string class_name = "TimeDerivative";
      auto params = _factory.getValidParams(class_name);
      params.applyParameter(_pars, "block");
      params.set<NonlinearVariableName>("variable") = specie;
      _sim.addKernel(
          class_name,
          MooseUtils::join(std::vector<std::string>({specie, name(), "time_deriv"}), "_"),
          params);
    }

    {
      const std::string class_name = "MatDiffusion";
      auto params = _factory.getValidParams(class_name);
      params.applyParameter(_pars, "block");
      params.set<NonlinearVariableName>("variable") = specie;
      params.set<MaterialPropertyName>("diffusivity") = "D_" + specie;
      _sim.addKernel(class_name,
                     MooseUtils::join(std::vector<std::string>({specie, name(), "diffusion"}), "_"),
                     params);
    }
  }
}
