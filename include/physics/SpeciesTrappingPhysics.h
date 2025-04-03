/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "SpeciesPhysicsBase.h"

class ActionComponent;

/**
 * Creates all the objects needed to solve for the concentration of a scalar in traps distributed
 * over a mesh.
 */
class SpeciesTrappingPhysics : public SpeciesPhysicsBase
{
public:
  static InputParameters validParams();

  SpeciesTrappingPhysics(const InputParameters & parameters);

  void addComponent(const ActionComponent & component) override;

protected:
  /// Return the name of the species variable
  /// @param c_i index of the component
  /// @param s_j index of  the species
  VariableName getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const;

  /// The discretization method for the trapping equations
  const MooseEnum _discretization;
  /// The mobile species of interest
  std::vector<std::vector<VariableName>> _mobile_species_names;

  // Properties on each component
  /// Trapping rate coefficient for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _alpha_ts;
  /// Trapping energies for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _trapping_energies;
  /// Atomic number density of the host material
  std::vector<Real> _Ns;
  /// Fraction of host sites that contribute to trapping for each component (outer indexing) and species (inner)
  std::vector<std::vector<FunctionName>> _Ct0s;
  /// Estimate for the ratio of the concentration magnitude of trapped species to free species for each component
  std::vector<Real> _trap_per_frees;
  /// Releasing rate for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _alpha_rs;
  /// Detrapping energies for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _detrapping_energies;

  /// Whether to define a single variable for each species for all components, or a different one for each component
  const bool _single_variable_set;

private:
  bool isNodal() const { return _discretization == "nodal"; }
  virtual void addSolverVariables() override;
  virtual void addInitialConditions() override;
  virtual void addFEKernels() override;
};
