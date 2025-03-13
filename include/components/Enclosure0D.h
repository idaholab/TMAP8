/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "ActionComponent.h"
#include "ComponentPhysicsInterface.h"
#include "ComponentMaterialPropertyInterface.h"

/**
 * Enclosure component which can trap a species, e.g. Tritium
 */
class Enclosure0D : public virtual ActionComponent,
                    public virtual ComponentPhysicsInterface,
                    public virtual ComponentMaterialPropertyInterface
{
public:
  Enclosure0D(const InputParameters & params);

  static InputParameters validParams();

  /// Return the species living on this component
  const std::vector<NonlinearVariableName> & species() const { return _species; }
  /// Return the scaling factors to use for these species
  const std::vector<Real> & scalingFactors() const { return _scaling_factors; }
  /// Return the initial conditions to use for these species
  const std::vector<Real> & ics() const { return _ics; }
  /// Return the equilibrium constants to use for these species
  const std::vector<MooseFunctorName> & equilibriumConstants() const { return _species_Ks; }
  /// Return the temperature of this enclosure
  Real temperature() const { return _temperature; }
  /// Returns the scaled volume of the enclosure
  virtual Real volume() const override { return _volume; }
  /// Returns the scaled outer boundary surface area
  virtual Real outerSurfaceArea() const override;
  /// Returns the boundary of the enclosure, connecting with the structure(s)
  virtual const std::vector<BoundaryName> & outerSurfaceBoundaries() const override
  {
    return _connection_boundaries;
  }
  /// Get the connected structure name
  const std::vector<ComponentName> & connectedStructures() const { return _connected_structures; }
  /// Get the boundary for the connection to the structure
  const BoundaryName & connectedStructureBoundary(const ComponentName & conn_structure) const;
  /// Get the boundary area for the connection surface to the structure
  Real connectedStructureBoundaryArea(const ComponentName & conn_structure) const;

protected:
  virtual void addPhysics() override;
  virtual void addMeshGenerators() override;

  /// Vector of the names of the species to track
  std::vector<NonlinearVariableName> _species;
  /// Scaling factors for the nonlinear species equations
  std::vector<Real> _scaling_factors;
  /// Initial conditions for each species
  std::vector<Real> _ics;
  /// Equilibrium constants for each species
  std::vector<MooseFunctorName> _species_Ks;
  /// Temperature of the enclosure
  const Real _temperature;
  /// Volume of the enclosure
  const Real _volume;
  /// Connected structures
  const std::vector<ComponentName> _connected_structures;
  /// Surfaces connecting the enclosure with the structures
  const std::vector<BoundaryName> _connection_boundaries;
  /// Surface area of each connection
  const std::vector<Real> _connection_boundaries_area;
};
