/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "FunctionalEnclosure0D.h"
#include "TMAPUtils.h"
#include "MooseParsedFunction.h"

registerMooseObject("TMAPApp", FunctionalEnclosure0D);

InputParameters
FunctionalEnclosure0D::validParams()
{
  auto params = Enclosure0D::validParams();
  params += TMAP::enclosureCommonParams();
  params += FunctionInterface::validParams();
  params.addRequiredParam<Real>(
      "surface_area", "The surface area for mass transfer between enclosure and structure");
  params.addRequiredParam<std::string>("structure", "The structure this enclosure is coupling to.");
  params.addRequiredParam<BoundaryName>("boundary",
                                        "The structure boundary this enclosure is coupling to.");
  params.addRequiredParam<std::vector<FunctionName>>(
      "equilibrium_constants",
      "the equilibrium constants between "
      "gas partial pressure and adsorbed solute concentration");
  return params;
}

FunctionalEnclosure0D::FunctionalEnclosure0D(const InputParameters & params)
  : Enclosure0D(params),
    FunctionInterface(this),
    _input_Ks(getParam<std::vector<FunctionName>>("equilibrium_constants")),
    _structure_name(getParam<std::string>("structure")),
    _structure_boundary(MooseUtils::join(
        std::vector<std::string>({_structure_name, getParam<BoundaryName>("boundary")}), "_"))
{
  if (_input_Ks.size() != _species.size())
    paramError("equilibrium_constants",
               "The number of equilibrium constants and species must match");

  addDependency(_structure_name);
}

void
FunctionalEnclosure0D::addVariables()
{
  for (const auto i : index_range(_species))
    _sim.addSimVariable(true, _species[i], FEType(FIRST, SCALAR), _scaling_factors[i]);
}

InputParameters
FunctionalEnclosure0D::createParams(const std::string & class_name)
{
  auto params = _factory.getValidParams(class_name);
  params.applyParameters(_pars);
  return params;
}

void
FunctionalEnclosure0D::addMooseObjects()
{
  for (const auto i : index_range(_ics))
  {
    const std::string class_name = "ScalarConstantIC";
    auto params = _factory.getValidParams(class_name);
    params.set<Real>("value") = _ics[i] * _pressure_unit;
    params.set<VariableName>("variable") = _species[i];
    _sim.addInitialCondition(class_name, _species[i] + "_ic", params);
  }

  static constexpr Real kb = 1.38e-23;

  for (const auto i : index_range(_species))
  {
    const auto & specie = _species[i];
    auto structure_specie = specie;
    const auto start_pos = structure_specie.rfind("_");
    auto start_it = structure_specie.begin() + start_pos;
    structure_specie.erase(start_it, structure_specie.end());

    // enclosure specie objects

    {
      const std::string class_name = "ODETimeDerivative";
      auto params = _factory.getValidParams(class_name);
      params.set<NonlinearVariableName>("variable") = specie;
      _sim.addScalarKernel(class_name, specie + "_enc_time_deriv", params);
    }

    PostprocessorName flux_name = structure_specie + "_" + _structure_boundary + "_flux";

    // We need to create this PP first so EnclosureSinkScalarKernel construction works
    {
      const std::string class_name = "SideDiffusiveFluxIntegral";
      auto params = _factory.getValidParams(class_name);
      params.set<std::vector<VariableName>>("variable") = {structure_specie};
      params.set<MaterialPropertyName>("diffusivity") = "D_" + structure_specie;
      params.set<std::vector<BoundaryName>>("boundary") = {_structure_boundary};
      params.set<ExecFlagEnum>("execute_on") = {
          EXEC_INITIAL, EXEC_NONLINEAR, EXEC_LINEAR, EXEC_TIMESTEP_END};
      // params.set<std::vector<OutputName>>("outputs") = {""};
      _sim.addPostprocessor(class_name, flux_name, params);
    }

    {
      const std::string class_name = "EnclosureSinkScalarKernel";
      auto params = _factory.getValidParams(class_name);
      params.set<NonlinearVariableName>("variable") = specie;
      params.set<Real>("concentration_to_pressure_conversion_factor") =
          kb * libMesh::Utility::pow<3>(_length_unit) * _temperature * _pressure_unit;
      params.set<PostprocessorName>("flux") = flux_name;
      params.set<Real>("surface_area") = scaledSurfaceArea();
      params.set<Real>("volume") = scaledVolume();
      _sim.addScalarKernel(class_name, specie + "_enc_sink_sk", params);
    }

    // structure specie objects

    {
      const auto & input_K = getFunctionByName(_input_Ks[i]);
      if (!dynamic_cast<const MooseParsedFunction *>(&input_K))
        paramError("equilibrium_constants", "All TMAP functions should be parsed functions");

      const auto & input_K_params = input_K.parameters();
      const auto & input_K_value = input_K_params.get<std::string>("value");
      const std::string scaled_K_value = "1/(" + std::to_string(_length_unit) + "^3 * " +
                                         std::to_string(_pressure_unit) + ") * (" + input_K_value +
                                         ")";

      const std::string class_name = "ParsedFunction";
      auto params = _factory.getValidParams(class_name);
      params.set<std::string>("value") = scaled_K_value;
      params.applyParameter(input_K_params, "vars");
      params.applyParameter(input_K_params, "vals");
      _sim.addFunction(class_name, _input_Ks[i] + "_scaled", params);
    }

    {

      const std::string class_name = "EquilibriumBC";
      auto params = _factory.getValidParams(class_name);
      params.set<NonlinearVariableName>("variable") = structure_specie;
      params.set<std::vector<VariableName>>("enclosure_scalar_var") = {specie};
      params.set<FunctionName>("K") = _input_Ks[i] + "_scaled";
      params.set<Real>("temperature") = _temperature;
      params.set<std::vector<BoundaryName>>("boundary") = {_structure_boundary};
      _sim.addBoundaryCondition(class_name, specie + "_equi_bc", params);
    }
  }
}
