//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "MultiSpeciesDiffusionCG.h"

/**
 * Creates all the objects needed to solve diffusion equations for multiple species with a
 * continuous Galerkin finite element discretization
 */
class MultiSpeciesMigrationCG : public MultiSpeciesDiffusionCG
{
public:
  static InputParameters validParams();

  MultiSpeciesMigrationCG(const InputParameters & parameters);

private:
  virtual void addFEKernels() override;
};
