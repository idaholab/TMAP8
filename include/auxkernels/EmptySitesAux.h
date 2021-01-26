/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

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
