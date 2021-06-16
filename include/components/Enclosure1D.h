/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "FlowChannel1Phase.h"

class Enclosure1D : public FlowChannel1Phase
{
public:
  Enclosure1D(const InputParameters & params);

  static InputParameters validParams();

protected:
  std::shared_ptr<FlowModel> buildFlowModel() override;
};
