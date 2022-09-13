/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2022 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "MooseApp.h"

class TMAPApp;

template <>
InputParameters validParams<TMAPApp>();

class TMAPApp : public MooseApp
{
public:
  TMAPApp(InputParameters parameters);
  virtual ~TMAPApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s);
};
