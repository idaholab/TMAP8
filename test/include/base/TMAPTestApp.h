/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "MooseApp.h"

class TMAPTestApp;

template <>
InputParameters validParams<TMAPTestApp>();

class TMAPTestApp : public MooseApp
{
public:
  TMAPTestApp(InputParameters parameters);
  virtual ~TMAPTestApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs = false);
};
