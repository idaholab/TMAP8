/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "MultiSpeciesDiffusionCG.h"

/**
 * Creates all the objects needed to solve diffusion-reaction equations for multiple species with a
 * continuous Galerkin finite element discretization
 */
class SpeciesDiffusionReactionCG : public MultiSpeciesDiffusionCG
{
public:
  static InputParameters validParams();

  SpeciesDiffusionReactionCG(const InputParameters & parameters);

private:
  virtual void addFEKernels() override;
};
