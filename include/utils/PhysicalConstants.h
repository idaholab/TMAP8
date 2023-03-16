/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2023 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

namespace PhysicalConstants
{
// Physical constants
// Avogadro's number (atoms/mol)
// https://physics.nist.gov/cgi-bin/cuu/Value?na|search_for=Avogadro
const auto avogadro_number = 6.02214076e23;
// Boltzmann constant (J/K)
// https://physics.nist.gov/cgi-bin/cuu/Value?k|search_for=Boltzmann
const auto boltzmann_constant = 1.380649e-23;
// Conversion coefficient from eV to Joules
// https://physics.nist.gov/cgi-bin/cuu/Value?Revj|search_for=joules
const auto eV_to_J = 1.602176634e-19;
// Ideal gas constant (J/K/mol)
// https://physics.nist.gov/cgi-bin/cuu/Value?eqr
const auto ideal_gas_constant = 8.31446261815324;
// Stefan-Boltzmann constant (W/m^2/K^4)
// https://physics.nist.gov/cgi-bin/cuu/Value?sigma|search_for=Stefan-Boltzmann
const auto stefan_boltzmann_constant = 5.670374419e-8;
} // namespace PhysicalConstants
