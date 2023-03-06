/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#include "TMAPTestApp.h"
#include "TMAPApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
TMAPTestApp::validParams()
{
  InputParameters params = TMAPApp::validParams();
  return params;
}

TMAPTestApp::TMAPTestApp(InputParameters parameters) : MooseApp(parameters)
{
  TMAPTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

TMAPTestApp::~TMAPTestApp() {}

void
TMAPTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  TMAPApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"TMAPTestApp"});
    Registry::registerActionsTo(af, {"TMAPTestApp"});
  }
}

void
TMAPTestApp::registerApps()
{
  registerApp(TMAPApp);
  registerApp(TMAPTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
TMAPTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  TMAPTestApp::registerAll(f, af, s);
}
extern "C" void
TMAPTestApp__registerApps()
{
  TMAPTestApp::registerApps();
}
