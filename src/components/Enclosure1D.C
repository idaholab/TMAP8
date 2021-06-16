/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "Enclosure1D.h"
#include "TMAPUtils.h"

registerMooseObject("TMAPApp", Enclosure1D);

InputParameters
Enclosure1D::validParams()
{
  auto params = FlowChannel1Phase::validParams();
  params += TMAP::enclosureCommonParams();
  return params;
}

Enclosure1D::Enclosure1D(const InputParameters & params) : FlowChannel1Phase(params) {}

std::shared_ptr<FlowModel>
Enclosure1D::buildFlowModel()
{
  const std::string class_name = "EnclosureAdvectionReaction1D";
  InputParameters pars = _factory.getValidParams(class_name);
  pars.set<THMProblem *>("_thm_problem") = &_sim;
  pars.set<FlowChannelBase *>("_flow_channel") = this;
  pars.set<UserObjectName>("numerical_flux") = _numerical_flux_name;
  pars.applyParameters(_pars);
  return _factory.create<FlowModel>(class_name, name(), pars, 0);
}
