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
  params.addClassDescription("Discretizes a diffusion equation with one or more reaction terms "
                             "with the continuous Galerkin finite element method");

  // Add reaction parameters
  // Until we support a Component-based input, these are required in the Physics parameters
  params.addRequiredParam<std::vector<std::vector<VariableName>>>(
      "reacting_species",
      "The groups of reacting species that react. The "
      "outer indexing separates each group, while the inner indexing is used to "
      "describe the groups");
  params.addParam<std::vector<std::vector<VariableName>>>(
      "product_species",
      {},
      "For each (group of) reactant, the species (innermost indexing) being created");
  params.addRequiredParam<std::vector<MaterialPropertyName>>(
      "reaction_coefficients", "The reaction coefficient for each reaction");
  params.addParamNamesToGroup("reacting_species product_species reaction_coefficients",
                              "Reaction Network");

  return params;
}

SpeciesDiffusionReactionCG::SpeciesDiffusionReactionCG(const InputParameters & parameters)
  : MultiSpeciesDiffusionCG(parameters)
{
  // There must be as many groups of reactants as coefficients for the reactions
  checkVectorParamsSameLength<std::vector<VariableName>, MaterialPropertyName>(
      "reacting_species", "reaction_coefficients");
  // There must be as many groups of reactants as groups of products, if any product
  if (isParamSetByUser("product_species"))
    checkVectorParamsSameLength<std::vector<VariableName>, std::vector<VariableName>>(
        "reacting_species", "product_species");
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
      getParam<std::vector<MaterialPropertyName>>("reaction_coefficients");

  // Reaction term
  if (isParamValid("reacting_species"))
  {
    // Add a kernel for both directions
    std::string kernel_type = "ADMatReactionFlexible";
    InputParameters params = getFactory().getValidParams(kernel_type);
    assignBlocks(params, _blocks);
    // Note: since we do not support per-component input of reacting species at this time,
    // we use the Physics' block restriction rather than the Component's

    // Loop on reaction equations (= groups of reactants and products)
    for (const auto c : index_range(reacting_species))
    {
      // Triple-indexed vectors arent initialized as I expected
      if (reacting_species.size() <= c)
        continue;

      // only if the other reacting species is a nonlinear variable
      // We skip the 'var_name' species because it's done right above
      for (const auto & reactant : reacting_species[c])
        if (solverVariableExists(reactant))
        {
          params.set<NonlinearVariableName>("variable") = reactant;
          params.set<std::vector<VariableName>>("vs") = reacting_species[c];
          params.set<MaterialPropertyName>("reaction_rate_name") = reaction_coeffs[c];

          params.set<Real>("coeff") = -1;
          // Keep the index in the name to keep uniqueness
          getProblem().addKernel(kernel_type,
                                 prefix() + reactant + ":coupled_reaction_of_" +
                                     Moose::stringify(reacting_species[c]) + "_" +
                                     std::to_string(c),
                                 params);
        }
        else if (variableExists(reactant, false))
          paramWarning("reacting_species",
                       "Variable '" + reactant +
                           "' is auxiliary, so its consumption cannot be tracked using kernels!");
        else
          paramError("reacting_species", "Reactant species '" + reactant + "' is not a variable");

      // only if the target species is a nonlinear variable
      if (product_species.size() > c)
      {
        for (const auto & product : product_species[c])
          if (solverVariableExists(product))
          {
            params.set<NonlinearVariableName>("variable") = product;
            params.set<std::vector<VariableName>>("vs") = reacting_species[c];
            params.set<MaterialPropertyName>("reaction_rate_name") = reaction_coeffs[c];

            params.set<Real>("coeff") = 1;
            // Keep the index in the name to keep uniqueness
            getProblem().addKernel(kernel_type,
                                   prefix() + product + ":production_of_" + product + "_from_" +
                                       Moose::stringify(reacting_species[c]) + "_" +
                                       std::to_string(c),
                                   params);
          }
          else if (variableExists(product, false))
            paramWarning("product_species",
                         "Variable '" + product +
                             "' is auxiliary, so its production cannot be tracked using kernels!");
          else
            paramError("product_species", "Product species '" + product + "' is not a variable");
      }
    }
  }
}
