/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "EnclosureAdvectionReaction1D.h"
#include "TMAPUtils.h"

InputParameters
EnclosureAdvectionReaction1D::validParams()
{
  auto params = FlowModelSinglePhase::validParams();
  params += TMAP::enclosureCommonParams();
  return params;
}

EnclosureAdvectionReaction1D::EnclosureAdvectionReaction1D(const InputParameters & params)
  : FlowModelSinglePhase(params)
{
}

void
EnclosureAdvectionReaction1D::init()
{
  FlowModelSinglePhase::init();
}

void
EnclosureAdvectionReaction1D::addVariables()
{
  FlowModelSinglePhase::addVariables();
}

void
EnclosureAdvectionReaction1D::addInitialConditions()
{
  FlowModelSinglePhase::addInitialConditions();
}

void
EnclosureAdvectionReaction1D::addMooseObjects()
{
  FlowModelSinglePhase::addMooseObjects();
}
