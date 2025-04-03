/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TMAP8App.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
TMAP8App::validParams()
{
  InputParameters params = MooseApp::validParams();
  // Set material property output to occur on TIMESTEP_END and INITIAL by default
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

TMAP8App::TMAP8App(const InputParameters & parameters) : MooseApp(parameters)
{
  TMAP8App::registerAll(_factory, _action_factory, _syntax);
}

TMAP8App::~TMAP8App() {}

void
TMAP8App::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<TMAP8App>(f, af, syntax);

  Registry::registerObjectsTo(f, {"TMAP8App"});
  Registry::registerActionsTo(af, {"TMAP8App"});

  /* register custom execute flags, action syntax, etc. here */

  // TMAP8 specific Physics
  registerSyntax("SorptionExchangePhysics", "Physics/SorptionExchange/*");
  registerSyntax("SpeciesTrappingPhysics", "Physics/SpeciesTrapping/*");
  registerSyntax("SpeciesDiffusionReactionCG", "Physics/SpeciesDiffusionReaction/*");

  // Shorter syntax for MOOSE Physics used by TMAP8
  registerSyntax("DiffusionCG", "Physics/Diffusion/*");
  registerSyntax("MultiSpeciesDiffusionCG", "Physics/SpeciesDiffusion/*");
  registerSyntax("HeatConductionCG", "Physics/HeatConduction/*");
}

void
TMAP8App::registerApps()
{
  registerApp(TMAP8App);
  ModulesApp::registerApps();
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
TMAP8App__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  TMAP8App::registerAll(f, af, s);
}
extern "C" void
TMAP8App__registerApps()
{
  TMAP8App::registerApps();
}
