/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "SpeciesPhysicsBase.h"
#include "MooseTypes.h"

// Forward declarations
class ActionComponent;

/**
 * Creates all the objects needed to solve for the concentration of one or more species in one or
 * more 0D enclosures in which the species can go into solution / release from
 */
class SorptionExchangePhysics : public SpeciesPhysicsBase
{
public:
  static InputParameters validParams();

  SorptionExchangePhysics(const InputParameters & parameters);

  void addComponent(const ActionComponent & component) override;

protected:
  /// Equilibrium constants for each species (inner) on each component (outer)
  std::vector<std::vector<MooseFunctorName>> _species_Ks;

  /// Scaling factor for lengths
  const Real _length_unit;
  /// Scaling factor for pressures
  const Real _pressure_unit;

private:
  virtual void addSolverVariables() override;
  virtual void addInitialConditions() override;
  virtual void addScalarKernels() override;
  virtual void addFEBCs() override;
  virtual void checkIntegrity() const override;

  /// Returns an error message if more than one boundary exists on the component
  void checkSingleBoundary(const std::vector<BoundaryName> & boundaries,
                           const ComponentName & comp) const;

  /// Return the structures connected to the component
  const std::vector<ComponentName> &
  getConnectedStructures(const MooseFunctorName & enc_name) const;

  /// Get the variable name for the structure connected to the component
  /// @param c_i index of the component
  /// @param conn_structure name of the connected structure
  /// @param s_j index of the species
  const VariableName & getConnectedStructureVariableName(unsigned int c_i,
                                                         const ComponentName & conn_structure,
                                                         unsigned int s_j) const;
  /// Get the boundary name for the surface connecting the structure to the component
  /// @param comp_name name of the component
  /// @param conn_structure name of the connected structure
  const BoundaryName & getConnectedStructureBoundary(const ComponentName & comp_name,
                                                     const ComponentName & conn_structure) const;
  /// Get the boundary area for the surface connecting the structure to the component
  /// @param comp_name name of the component
  /// @param conn_structure name of the connected structure
  Real getConnectedStructureConnectionArea(const ComponentName & comp_name,
                                           const ComponentName & connected_structure_name) const;
  /// Get the Physics active on the structure connected to the component
  /// @param conn_structure name of the connected structure
  const std::vector<PhysicsBase *>
  getConnectedStructurePhysics(const ComponentName & conn_structure) const;
  /// Get the Physics active on the structure connected to the component
  /// @param conn_structure name of the connected structure
  /// @param species_name name of the species
  PhysicsBase * getConnectedStructurePhysics(const ComponentName & conn_structure,
                                             const VariableName & species_name) const;
};
