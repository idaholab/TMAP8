/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TMAPApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
TMAPApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Set material property output to occur on TIMESTEP_END and INITIAL by default
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

TMAPApp::TMAPApp(InputParameters parameters) : MooseApp(parameters)
{
  TMAPApp::registerAll(_factory, _action_factory, _syntax);
}

TMAPApp::~TMAPApp() {}

void
TMAPApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"TMAPApp"});
  Registry::registerActionsTo(af, {"TMAPApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
TMAPApp::registerApps()
{
  registerApp(TMAPApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
TMAPApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  TMAPApp::registerAll(f, af, s);
}
extern "C" void
TMAPApp__registerApps()
{
  TMAPApp::registerApps();
}
