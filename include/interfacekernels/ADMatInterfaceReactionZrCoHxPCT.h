/************************************************************/
/*                DO NOT MODIFY THIS HEADER                 */
/*   TMAP8: Tritium Migration Analysis Program, Version 8   */
/*                                                          */
/*   Copyright 2021 - 2025 Battelle Energy Alliance, LLC    */
/*                   ALL RIGHTS RESERVED                    */
/************************************************************/

#pragma once

#include "ADInterfaceKernel.h"

/**
 *
 * Implements a reaction to establish ReactionRate=k_f*u-k_b*v to compute the surface H
 * concentration in ZrCoHx from the temperature and partial pressure based on the PCT curves with u
 * the concentration in the solid and v (neighbor) the concentration in the gas.
 *

Ram Avtar Jat, S. C. Parida, J. Nuwad, Renu Agarwal, and S. G. Kulkarni. Hydrogen
sorption–desorption studies on zrco–hydrogen system. Journal of Thermal Analysis and Calorimetry,
112(1):37–43, 2013. doi:10.1007/s10973-012-2783-7.[BibTeX] Takanori Nagasaki, Satoshi Konishi,
Hiroji Katsuta, and Yuji Naruse. A zirconium-cobalt compound as the material for a reversible
tritium getter. Fusion Technology, 9(3):506–509, 1986. doi:10.13182/FST86-A24739.[BibTeX] R.-D.
Penzhorn, M. Devillers, and M. Sirch. Evaluation of zrco and other getters for tritium handling and
storage. Journal of Nuclear Materials, 170:217–231, 1990. doi:10.1016/0022-3115(90)90292-U.[BibTeX]


 */

class ADMatInterfaceReactionZrCoHxPCT : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  ADMatInterfaceReactionZrCoHxPCT(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  /// Coupled temperature variable
  const GenericVariableValue<true> & _neighbor_temperature;

  /// Density of the solid
  const ADMaterialProperty<Real> & _density;

  /// Forward reaction rate coefficient
  const ADMaterialProperty<Real> & _kf;

  /// Backward reaction rate coefficient
  const ADMaterialProperty<Real> & _kb;
};
