//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MultiSpeciesMigrationCG.h"
#include "MooseVariableBase.h"

// Register the actions for the objects actually used
registerMooseAction("MooseApp", MultiSpeciesMigrationCG, "add_kernel");
registerMooseAction("MooseApp", MultiSpeciesMigrationCG, "add_bc");
registerMooseAction("MooseApp", MultiSpeciesMigrationCG, "add_variable");
registerMultiSpeciesDiffusionPhysicsBaseTasks("MooseApp", MultiSpeciesMigrationCG);

InputParameters
MultiSpeciesMigrationCG::validParams()
{
  InputParameters params = MultiSpeciesDiffusionCG::validParams();
  params.addClassDescription(
      "Discretizes a diffusion equation with the continuous Galerkin finite element method");

  // Add reaction parameters
  params.addParam<std::vector<std::vector<VariableName>>>(
      "reacting_species", "For each species (outer indexing), the list of species they react with");
  params.addParam<std::vector<std::vector<MaterialPropertyName>>>(
      "reaction_coefficients",
      "For each species (outer indexing), the reaction coefficient for the reaction");

  // Remove diffusion parameters for now: talk to PC
  params.suppressParameter<std::vector<MooseFunctorName>>("diffusivity_functor");
  params.suppressParameter<std::vector<MaterialPropertyName>>("diffusivity_matprop");

  return params;
}

MultiSpeciesMigrationCG::MultiSpeciesMigrationCG(const InputParameters & parameters)
  : MultiSpeciesDiffusionCG(parameters)
{
  checkTwoDVectorParamsSameLength<VariableName, MaterialPropertyName>("reacting_species",
                                                                      "reaction_coefficients");
}

void
MultiSpeciesMigrationCG::addFEKernels()
{
  MultiSpeciesDiffusionCG::addFEKernels();

  if (!isParamValid("reacting_species"))
    return;
  const auto & reacting_species =
      getParam<std::vector<std::vector<MooseFunctorName>>>("reacting_species");
  const auto & reaction_coeffs =
      getParam<std::vector<std::vector<MooseFunctorName>>>("reaction_coefficients");

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

      for (const auto c : index_range(reacting_species[s]))
      {
        params.set<std::vector<VariableName>>("vs") = {reacting_species[s][c]};
        params.set<MaterialPropertyName>("reaction_rate_name") = reaction_coeffs[s][c];
        params.set<Real>("coeff") = -1;

        getProblem().addKernel(kernel_type,
                               prefix() + var_name + "_reaction_" + var_name + "_" +
                                   reacting_species[s][c],
                               params);

        // only if the target species is a nonlinear variable
        if (nonlinearVariableExists(reacting_species[s][c], false))
        {
          params.set<NonlinearVariableName>("variable") = reacting_species[s][c];
          params.set<std::vector<VariableName>>("vs") = {var_name};

          params.set<Real>("coeff") = 1;
          getProblem().addKernel(kernel_type,
                                 prefix() + var_name + "_reaction_" + reacting_species[s][c] + "_" +
                                     var_name,
                                 params);
        }
      }
    }
  }
}
