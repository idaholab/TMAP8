/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#include "TMAPUtils.h"
#include "InputParameters.h"
#include "MooseTypes.h"

namespace TMAP
{
namespace internal
{
InputParameters
commonParams()
{
  auto params = emptyInputParameters();
  params.addRequiredParam<std::vector<NonlinearVariableName>>(
      "species",
      "The species that are reacting, advecting, and diffusing throughout the simulation domain");
  params.addParam<std::vector<Real>>(
      "species_scaling_factors",
      "Scaling factors to make the (non)linear system better conditioned");
  return params;
}
}

InputParameters
structureCommonParams()
{
  auto params = internal::commonParams();
  params.addParam<std::vector<SubdomainName>>(
      "block", "The list of block ids (SubdomainID) that this object will be applied");
  params.addParam<std::vector<Real>>(
      "species_initial_concentrations", {}, "Initial concentrations for the structure species");
  params.addRequiredParam<MooseFunctorName>("temperature", "Temperature [K]");
  return params;
}

InputParameters
enclosureCommonParams()
{
  auto params = internal::commonParams();

  params.addRequiredParam<Real>("temperature", "Enclosure temperature [K]");
  params.addRequiredParam<Real>("volume", "Volume of enclosure [m^3]");
  params.addRequiredParam<Real>("surface_area", "Contact surface with the structure [m^3]");
  params.addRequiredParam<ComponentName>("connected_structure",
                                         "Structure exchanging species with the enclosure");
  params.addRequiredParam<BoundaryName>(
      "boundary",
      "Surface between the enclosure and the connected structure. This surface should exist on the "
      "mesh and likely be located on the 'connected_structure'");

  params.addParam<std::vector<Real>>(
      "species_initial_pressures",
      {},
      "Initial partial pressures for the enclosure species in Pascals");
  params.addParam<std::vector<MooseFunctorName>>(
      "equilibrium_constants", {}, "Solubility constants for each specie");

  params.addParamNamesToGroup("species_initial_pressures equilibrium_constants", "Species");
  params.addParamNamesToGroup("temperature", "Enclosure conditions");
  params.addParamNamesToGroup("volume surface_area connected_structure boundary", "Geometry");
  return params;
}
}
