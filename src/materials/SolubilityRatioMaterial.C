//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SolubilityRatioMaterial.h"
#include "TwoMaterialPropertyInterface.h"

registerMooseObject("TMAP8App", SolubilityRatioMaterial);

InputParameters
SolubilityRatioMaterial::validParams()
{
  InputParameters params = InterfaceMaterial::validParams();
  params.addClassDescription("Calculates the jump in concentration across an interface.");
  params.addRequiredParam<std::string>(
      "solubility_primary", "The material property on the primary side of the interface");
  params.addRequiredParam<std::string>(
      "solubility_secondary", "The material property on the secondary side of the interface");
  params.addRequiredCoupledVar("concentration_primary",
                               "Primary side non-linear variable for jump computation");
  params.addRequiredCoupledVar("concentration_secondary",
                               "Secondary side non-linear variable for jump computation");
  return params;
}

SolubilityRatioMaterial::SolubilityRatioMaterial(const InputParameters & parameters)
  : InterfaceMaterial(parameters),
    _solubility_primary_name(getParam<std::string>("solubility_primary")),
    _solubility_secondary_name(getParam<std::string>("solubility_secondary")),
    _solubility_primary(getADMaterialPropertyByName<Real>(_solubility_primary_name)),
    _solubility_secondary(getNeighborADMaterialPropertyByName<Real>(_solubility_secondary_name)),
    //    _solubility_primary(getADMaterialProperty<Real>("solubility_primary")),
    //    _solubility_secondary(getNeighborADMaterialProperty<Real>("solubility_secondary")),
    _concentration_primary(adCoupledValue("concentration_primary")),
    _concentration_secondary(adCoupledNeighborValue("concentration_secondary")),
    _jump(declareADProperty<Real>("solubility_ratio"))
{
}

void
SolubilityRatioMaterial::computeQpProperties()
{
  mooseAssert(_neighbor_elem, "Neighbor elem is NULL!");
  //*  _jump[_qp] = _concentration_primary[_qp] - _concentration_secondary[_qp];
  //  _jump[_qp] = _concentration_primary[_qp]*(_solubility_secondary[_qp]/_solubility_primary[_qp]
  //  - 1);
  _jump[_qp] = _concentration_primary[_qp] / _solubility_primary[_qp] -
               _concentration_secondary[_qp] / _solubility_secondary[_qp];
  //_jump[_qp] = 0.0;
}
