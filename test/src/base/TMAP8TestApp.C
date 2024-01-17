/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TMAP8TestApp.h"
#include "TMAP8App.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
TMAP8TestApp::validParams()
{
  InputParameters params = TMAP8App::validParams();
  return params;
}

TMAP8TestApp::TMAP8TestApp(InputParameters parameters) : MooseApp(parameters)
{
  TMAP8TestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

TMAP8TestApp::~TMAP8TestApp() {}

void
TMAP8TestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  TMAP8App::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"TMAP8TestApp"});
    Registry::registerActionsTo(af, {"TMAP8TestApp"});
  }
}

void
TMAP8TestApp::registerApps()
{
  registerApp(TMAP8TestApp);
  TMAP8App::registerApps();
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
TMAP8TestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  TMAP8TestApp::registerAll(f, af, s);
}
extern "C" void
TMAP8TestApp__registerApps()
{
  TMAP8TestApp::registerApps();
}
