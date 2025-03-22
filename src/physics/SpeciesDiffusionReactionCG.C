/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "SpeciesDiffusionReactionCG.h"
#include "MooseVariableBase.h"

// Register the actions for the objects actually used
registerMooseAction("MooseApp", SpeciesDiffusionReactionCG, "add_kernel");
registerMooseAction("MooseApp", SpeciesDiffusionReactionCG, "add_bc");
registerMooseAction("MooseApp", SpeciesDiffusionReactionCG, "add_variable");
registerMultiSpeciesDiffusionPhysicsBaseTasks("MooseApp", SpeciesDiffusionReactionCG);

InputParameters
SpeciesDiffusionReactionCG::validParams()
{
  InputParameters params = MultiSpeciesDiffusionCG::validParams();
  params.addClassDescription(
      "Discretizes a diffusion equation with the continuous Galerkin finite element method");

  // Add reaction parameters
  // Until we support a Component-based input, these are required in the Physics parameters
  params.addRequiredParam<std::vector<std::vector<VariableName>>>(
      "reacting_species", "For each species (outer indexing), the list of species they react with");
  params.addRequiredParam<std::vector<std::vector<VariableName>>>(
      "product_species",
      "For each species (outer indexing), for each reactant, the species being created");
  params.addRequiredParam<std::vector<std::vector<MaterialPropertyName>>>(
      "reaction_coefficients",
      "For each species (outer indexing), the reaction coefficient for the reaction");
  params.addParamNamesToGroup("reacting_species product_species reaction_coefficients",
                              "Reaction Network");

  return params;
}

SpeciesDiffusionReactionCG::SpeciesDiffusionReactionCG(const InputParameters & parameters)
  : MultiSpeciesDiffusionCG(parameters)
{
  checkTwoDVectorParamsSameLength<VariableName, MaterialPropertyName>("reacting_species",
                                                                      "reaction_coefficients");
  checkTwoDVectorParamsSameLength<VariableName, VariableName>("reacting_species",
                                                              "product_species");
}

void
SpeciesDiffusionReactionCG::addFEKernels()
{
  MultiSpeciesDiffusionCG::addFEKernels();

  if (!isParamValid("reacting_species"))
    return;
  const auto & reacting_species =
      getParam<std::vector<std::vector<VariableName>>>("reacting_species");
  const auto & product_species =
      getParam<std::vector<std::vector<VariableName>>>("product_species");
  const auto & reaction_coeffs =
      getParam<std::vector<std::vector<MaterialPropertyName>>>("reaction_coefficients");

  for (const auto s : index_range(_species_names))
  {
    const auto & var_name = _species_names[s];
    // Reaction term
    if (isParamValid("reacting_species"))
    {
      // Add a kernel for both directions
      std::string kernel_type = "ADMatReactionFlexible";
      InputParameters params = getFactory().getValidParams(kernel_type);
      params.set<NonlinearVariableName>("variable") = var_name;
      assignBlocks(params, _blocks);
      // Note: since we do not support per-component input of reacting species at this time,
      // we use the Physics' block restriction rather than the Component's

      // Double-indexed vectors arent initialized as I expected
      if (reacting_species.size() <= s)
        continue;

      for (const auto c : index_range(reacting_species[s]))
      {
        params.set<std::vector<VariableName>>("vs") = {var_name, reacting_species[s][c]};
        params.set<MaterialPropertyName>("reaction_rate_name") = reaction_coeffs[s][c];
        params.set<Real>("coeff") = -1;

        getProblem().addKernel(kernel_type,
                               prefix() + var_name + "_reaction_" + var_name + "_" +
                                   reacting_species[s][c],
                               params);

        // only if the other reacting species is a nonlinear variable
        if (variableExists(reacting_species[s][c], false))
        {
          params.set<NonlinearVariableName>("variable") = reacting_species[s][c];
          params.set<std::vector<VariableName>>("vs") = {var_name, reacting_species[s][c]};

          params.set<Real>("coeff") = -1;
          getProblem().addKernel(kernel_type,
                                 prefix() + var_name + "_reaction_" + reacting_species[s][c] + "_" +
                                     var_name,
                                 params);
        }

        // only if the target species is a nonlinear variable
        if (variableExists(product_species[s][c], false))
        {
          params.set<NonlinearVariableName>("variable") = product_species[s][c];
          params.set<std::vector<VariableName>>("vs") = {var_name, reacting_species[s][c]};

          params.set<Real>("coeff") = 1;
          getProblem().addKernel(kernel_type,
                                 prefix() + var_name + "_production_" + var_name + "_" +
                                     reacting_species[s][c],
                                 params);
        }
      }
    }
  }
}
