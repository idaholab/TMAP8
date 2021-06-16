/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "Component.h"
#include "FunctionInterface.h"

class Structure1D : public Component, public FunctionInterface
{
public:
  Structure1D(const InputParameters & params);

  static InputParameters validParams();

  void addVariables() override;
  void addMooseObjects() override;

protected:
  void setupMesh() override;

  const std::vector<NonlinearVariableName> _species;
  const std::vector<Real> _scaling_factors;
  const std::vector<Real> _ics;
  const std::vector<FunctionName> _input_Ds;
  const Real _length_unit;
};
