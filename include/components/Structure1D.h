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
 * A 1D structure on which a species can diffuse
 */
class Structure1D : public virtual ComponentAction, public PhysicsComponentHelper
{
public:
  Structure1D(const InputParameters & params);

  static InputParameters validParams();

  virtual void addMeshGenerators() override;
  virtual void initComponentPhysics() override;

protected:
  /// Names of the variables for the species
  const std::vector<NonlinearVariableName> _species;
  /// Scaling factors for each nonlinear variable
  const std::vector<Real> _scaling_factors;
  /// Initial values for the variables
  const std::vector<Real> _ics;
  /// Diffusion coefficients
  const std::vector<FunctionName> _input_Ds;
  /// Unit for the mesh
  const Real _length_unit;
};
