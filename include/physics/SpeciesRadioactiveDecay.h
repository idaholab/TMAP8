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
 * Creates all the objects needed to solve for the radioactive decay of the species
 */
class SpeciesRadioactiveDecay : public SpeciesPhysicsBase
{
public:
  static InputParameters validParams();

  SpeciesRadioactiveDecay(const InputParameters & parameters);

  void addComponent(const ActionComponent & component) override;

protected:
  /// Return the name of the species variable
  /// @param c_i index of the component
  /// @param s_j index of  the species
  VariableName getSpeciesVariableName(unsigned int c_i, unsigned int s_j) const;

  /// Decay products on each component, for each species, for each decay reaction
  std::vector<std::vector<std::vector<std::vector<VariableName>>>> _decay_products;
  /// Decay constants on each component, for each species, for each decay reaction
  std::vector<std::vector<std::vector<Real>>> _decay_constants;
  /// Branching rations on each component, for each species, for each decay reaction, for each product species
  std::vector<std::vector<std::vector<std::vector<Real>>>> _branching_ratios;

  /// Whether to define a single variable for each species for all components, or a different one for each component
  const bool _single_variable_set;
  /// Whether to define initial conditions for the decaying species
  const bool _add_initial_conditions;
  /// Whether to use a nodal or a volumetric formulation for the definition of kernels, indexed per component
  std::vector<bool> _use_nodal_formulations;

private:
  virtual void addSolverVariables() override;
  virtual void addInitialConditions() override;
  virtual void addFEKernels() override;
};
