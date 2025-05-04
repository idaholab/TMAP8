/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2024 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "Material.h"

/**
 * This class determines the atomic fraction of YHx from the temperature and pressure based on the
 * PCT curves.
 * The original data is from C. E. Lundin, J. P. Blackledge, Pressure-Temperature-Composition
 * Relationships of the Yttrium-Hydrogen System, Journal of The Electrochemical Society 109 (9)
 * (1962) 838–5.
 * The fits are from Matthews et al., Metal Hydride Simulations Using SWIFT, LANL technical report
 * LA-UR-21-27538, 2021.
 */
template <bool is_ad>
class YHxPCTTempl : public  Material
{
public:
  static InputParameters validParams();
  YHxPCTTempl(const InputParameters & parameters);

protected:
  /// Compute Atomic Fraction based on PCT curves
  void computeQpProperties();

  /// Coupled pressure in Pa
  const GenericVariableValue<is_ad> & _pressure;
  /// Coupled temperature in K
  const GenericVariableValue<is_ad> & _temperature;

  ///@{Base name of the material, its properties, and their derivatives
  const std::string _base_name;
  const std::string _atomic_fraction_name;
  const std::string _atomic_fraction_dT_name;
  const std::string _atomic_fraction_dP_name;
  ///@}

  ///@{Atomic fraction of H in YHx and its derivative wrt temperature and pressure
  GenericMaterialProperty<Real, is_ad> & _atomic_fraction;
  GenericMaterialProperty<Real, is_ad> * _atomic_fraction_dT;
  GenericMaterialProperty<Real, is_ad> * _atomic_fraction_dP;
  ///@}

  /// Flag to silence correlation out of bound warnings
  const bool _silence_warnings;
};

typedef YHxPCTTempl<false> YHxPCT;
typedef YHxPCTTempl<true> ADYHxPCT;
