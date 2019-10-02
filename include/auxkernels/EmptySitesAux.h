//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "AuxKernel.h"

// Forward Declarations
class EmptySitesAux;

template <>
InputParameters validParams<EmptySitesAux>();

class EmptySitesAux : public AuxKernel
{
public:
  EmptySitesAux(const InputParameters & parameters);

protected:
  virtual Real computeValue() override;

  const Real _N;
  const Real _Ct0;
  unsigned int _n_concs;
  std::vector<const VariableValue *> _trapped_concentrations;
  const Real _trap_per_free;
};
