//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "SpeciesTrappingPhysicsBase.h"

// Forward declarations
class ActionComponent;

/**
 * Creates all the objects needed to solve for the concentration of a scalar in 0D trap(s).
 */
class PointTrappingPhysics : public SpeciesTrappingPhysicsBase
{
public:
  static InputParameters validParams();

  PointTrappingPhysics(const InputParameters & parameters);

  void addComponent(const ActionComponent & component) override;

protected:
  /// Equilibrium constants / solubilities
  const std::vector<MooseFunctorName> _species_Ks;

  /// Scaling factor for lengths
  const Real _length_unit;
  /// Scaling factor for pressures
  const Real _pressure_unit;

private:
  virtual void addSolverVariables() override;
  virtual void addInitialConditions() override;
  virtual void addScalarKernels() override;
  virtual void addFEBCs() override;

  /// Returns an error message if more than one boundary exists on the component
  void checkSingleBoundary(const std::vector<BoundaryName> & boundaries,
                           const ComponentName & comp) const;

  /// Get the variable name for the structure connected to the component
  /// @param c_i index of the component
  /// @param s_j index of the species
  const VariableName & getConnectedStructureVariableName(unsigned int c_i, unsigned int s_j);
  /// Get the boundary name for the surface connecting the structure to the component
  /// @param c_i index of the component
  const BoundaryName & getConnectedStructureBoundary(unsigned int c_i);
  /// Get the Physics active on the structure connected to the component
  /// @param c_i index of the component
  const std::vector<PhysicsBase *> getConnectedStructurePhysics(unsigned int c_i);
};
