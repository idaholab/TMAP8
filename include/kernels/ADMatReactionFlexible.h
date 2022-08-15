//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADKernel.h"

/**
 * This kernel adds to the residual a contribution of \f$ - coeff*L*vs \f$ where
 * coeff is a simple coefficient, \f$ L \f$ is a material property and \f$ vs \f$
 * is the multiplication of several variables (nonlinear or coupled).
 */
class ADMatReactionFlexible : public ADKernel
{
public:
  static InputParameters validParams();

  ADMatReactionFlexible(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual();

  /**
   * Kernel variable (can be nonlinear or coupled variable)
   * (For constrained Allen-Cahn problems, v = lambda
   * where lambda is the Lagrange multiplier)
   */
   const unsigned int _num_vs;
   const std::vector<const VariableValue *> _vs;
  // std::vector<const ADVariableValue &> _vs;
  // const ADVariableValue & _v;

  /// Reaction rate
  const ADMaterialProperty<Real> & _mob;

  /// An optional input-file supplied coefficient
  const Real _coeff;
};
