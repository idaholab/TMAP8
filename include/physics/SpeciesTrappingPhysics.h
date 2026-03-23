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
  /// Dimensionless trapping rate k_t_hat for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _dimensionless_trapping_rates;
  /// Reference trapped concentration for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _trap_concentration_references;
  /// Reference mobile concentration for each component
  std::vector<Real> _mobile_concentration_references;
  /// Estimate for the ratio of the concentration magnitude of trapped species to free species for each component
  std::vector<Real> _trap_per_frees;
  /// Releasing rate for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _alpha_rs;
  /// Dimensionless release rate k_r_hat for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _dimensionless_release_rates;
  /// Detrapping energies for each component (outer indexing) and species (inner)
  std::vector<std::vector<Real>> _detrapping_energies;
  /// Whether to define a single variable for each species for all components, or a different one for each component
  const bool _single_variable_set;
  /// Whether to use dimensionless mobile and trapped-species variables and their associated dimensionless trapping/release kernels
  const bool _use_dimensionless_species;

private:
  Real trapConcentrationReference(unsigned int c_i, unsigned int s_j);
  Real dimensionlessTrappingRate(unsigned int c_i, unsigned int s_j);
  Real mobileConcentrationReference(unsigned int c_i) const;
  Real dimensionlessReleaseRate(unsigned int c_i, unsigned int s_j);
  Real trappedConcentrationReference(unsigned int c_i) const;
  Real variableScalingFromReference(Real reference) const;
  Real siteDensityReference(unsigned int c_i) const;
  Real timeReference(unsigned int c_i) const;
  Real temperatureReference(unsigned int c_i) const;
  virtual void addSolverVariables() override;
  virtual void addInitialConditions() override;
  virtual void addFEKernels() override;
};
