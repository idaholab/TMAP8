//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "InterfaceMaterial.h"
#include "MaterialProperty.h"

/**
 * Calculates the jump in concentration across an interface
 * based on the ratio of solubilities
 */
class SolubilityRatioMaterial : public InterfaceMaterial
{
public:
  static InputParameters validParams();

  SolubilityRatioMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  const std::string _solubility_primary_name;
  const std::string _solubility_secondary_name;
  const ADMaterialProperty<Real> & _solubility_primary;
  const ADMaterialProperty<Real> & _solubility_secondary;
  const ADVariableValue & _concentration_primary;
  const ADVariableValue & _concentration_secondary;
  ADMaterialProperty<Real> & _jump;
};
