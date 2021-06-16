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
  params.addParam<Real>(
      "length_unit",
      1,
      "The number of length units in a meter. This allows the user to select length units "
      "other than meters that may lead to better overall scaling of the system.");
  return params;
}
}

InputParameters
structureCommonParams()
{
  auto params = internal::commonParams();
  params.addParam<std::vector<SubdomainName>>(
      "block", "The list of block ids (SubdomainID) that this object will be applied");
  params.addParam<std::vector<Real>>("species_initial_concentrations",
                                     "Initial concentrations for the structure species");
  params.addRequiredParam<std::vector<FunctionName>>("diffusivities",
                                                     "The diffusivities of the species");
  return params;
}

InputParameters
enclosureCommonParams()
{
  auto params = internal::commonParams();
  // params.addRequiredParam<std::string>("material", "Fluid material name");
  params.addRequiredParam<Real>("volume", "Volume of enclosure [m^3]");
  params.addRequiredParam<Real>("temperature", "Enclosure temperature [K]");
  // params.addRequiredParam<FunctionName>("pressure", "Enclosure pressure [Pa]");
  params.addParam<FunctionName>(
      "D_h", "Hydraulic diameter [m]"); // required if mass transfer correlation is to be used
  params.addParam<std::vector<Real>>(
      "species_initial_pressures",
      "Initial partial pressures for the enclosure species in Pascals");
  params.addParam<Real>(
      "pressure_unit",
      1,
      "The number of pressure units in a Pascal. This allows the user to select pressure units "
      "other than Pascals that may lead to better overall scaling of the system.");
  return params;
}
}
