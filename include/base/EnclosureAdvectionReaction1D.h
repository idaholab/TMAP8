/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "FlowModelSinglePhase.h"

class EnclosureAdvectionReaction1D : public FlowModelSinglePhase
{
public:
  EnclosureAdvectionReaction1D(const InputParameters & params);

  virtual void init() override;
  virtual void addVariables() override;
  virtual void addInitialConditions() override;
  virtual void addMooseObjects() override;

  static InputParameters validParams();
};
