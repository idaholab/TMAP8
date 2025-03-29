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
  params.addRangeCheckedParam<std::vector<Real>>(
      "species_scaling_factors",
      "species_scaling_factors>0",
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
  // This is used by the SpeciesTrapping Physics notably. But not by Diffusion and
  // Diffusion-Reaction. We could consider making it required
  params.addParam<MooseFunctorName>("temperature", "Temperature [K]");
  return params;
}

InputParameters
enclosureCommonParams()
{
  auto params = internal::commonParams();

  params.addRequiredParam<MooseFunctorName>("temperature", "Enclosure temperature [K]");
  params.addRequiredRangeCheckedParam<Real>("volume", "volume>0", "Volume of enclosure [m^3]");

  // Connection with structures
  params.addRequiredParam<std::vector<ComponentName>>(
      "connected_structures", "Structure exchanging species with the enclosure");
  params.addRequiredParam<std::vector<BoundaryName>>(
      "connection_boundaries",
      "Surface between the enclosure and the connected "
      "structures. This surface should exist on the "
      "mesh and likely be located on the 'connected_structures'");
  params.addRequiredRangeCheckedParam<std::vector<Real>>(
      "connection_boundaries_area",
      "connection_boundaries_area>=0",
      "Contact surface with each structure [m^3]");

  // Species quantities
  params.addParam<std::vector<Real>>(
      "species_initial_pressures",
      {},
      "Initial partial pressures for the enclosure species in Pascals");
  params.addParam<std::vector<MooseFunctorName>>(
      "equilibrium_constants", {}, "Solubility constants for each specie");

  params.addParamNamesToGroup("species_initial_pressures equilibrium_constants", "Species");
  params.addParamNamesToGroup("temperature", "Enclosure conditions");
  params.addParamNamesToGroup(
      "connected_structures connection_boundaries connection_boundaries_area",
      "Enclosure connections to structures");
  params.addParamNamesToGroup("volume", "Geometry");
  return params;
}
}
