/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "Enclosure0D.h"
#include "FunctionInterface.h"

class FunctionalEnclosure0D : public Enclosure0D, public FunctionInterface
{
public:
  FunctionalEnclosure0D(const InputParameters & params);

  static InputParameters validParams();

  void addVariables() override;
  void addMooseObjects() override;

protected:
  InputParameters createParams(const std::string & class_name);

  const std::vector<FunctionName> _input_Ks;
  const std::string _structure_name;
  const std::string _structure_boundary;
};
