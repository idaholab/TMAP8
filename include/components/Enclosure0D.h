/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "ComponentAction.h"
#include "PhysicsComponentHelper.h"

/**
 * Enclosure component which can trap a species, e.g. Tritium
 */
class Enclosure0D : public virtual ComponentAction, public PhysicsComponentHelper
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
  /// Return the temperature of this enclosure
  Real temperature() const { return _temperature; }
  /// Returns the scaled volume of the enclosure
  virtual Real volume() const override { return _volume; }
  /// Returns the scaled outer boundary surface area
  virtual Real outerSurfaceArea() const override { return _surface_area; }
  /// Returns the boundary of the enclosure, connecting with the structure
  virtual const std::vector<BoundaryName> & outerSurfaceBoundaries() const override { _console << Moose::stringify(_outer_boundaries); return _outer_boundaries; }
  /// Get the connected structure name
  ComponentName connectedStructure() const { return getParam<ComponentName>("connected_structure");}

protected:
  virtual void initComponentPhysics() override;

  /// Vector of the names of the species to track
  std::vector<NonlinearVariableName> _species;
  /// Scaling factors for the nonlinear species equations
  std::vector<Real> _scaling_factors;
  /// Initial conditions for each species
  std::vector<Real> _ics;
  /// Temperature of the enclosure
  const Real _temperature;
  /// Outer surface area of the enclosure
  const Real _surface_area;
  /// Volume of the enclosure
  const Real _volume;
  /// Surface connecting the enclosure with the structure
  const std::vector<BoundaryName> _outer_boundaries;
};
