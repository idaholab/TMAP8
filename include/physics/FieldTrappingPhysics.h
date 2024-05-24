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

/**
 * Creates all the objects needed to solve for the concentration of a scalar in traps distributed
 * over a mesh.
 */
class FieldTrappingPhysics : public SpeciesTrappingPhysicsBase
{
public:
  static InputParameters validParams();

  FieldTrappingPhysics(const InputParameters & parameters);

  void addComponent(const ComponentAction & component);

protected:
  /// Return the name of the species variable
  /// @param c_i index of the component
  /// @param s_j index of  the species
  VariableName getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const;

  /// The mobile species of interest
  std::vector<std::vector<VariableName>> _mobile_species_names;

  // Properties on each component
  /// Trapping rate coefficient for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _alpha_ts;
  /// Atomic number density of the host material
  std::vector<Real> _Ns;
  /// Fraction of host sites that contribute to trapping
  std::vector<Real> _Ct0s;
  /// Estimate for the ratio of the concentration magnitude of trapped species to free species for each component
  std::vector<Real> _trap_per_frees;
  ///
  std::vector<std::vector<Real>> _alpha_rs;
  std::vector<std::vector<Real>> _trapping_energies;

  /// Whether to define a single variable for each species for all components, or a different one for each component
  const bool _single_variable_set;

private:
  virtual void addNonlinearVariables() override;
  virtual void addInitialConditions() override;
  virtual void addFEKernels() override;
};
