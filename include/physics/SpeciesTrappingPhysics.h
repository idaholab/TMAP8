//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "PhysicsBase.h"

/**
 * Creates all the objects needed to solve for the concentration of a scalar in a trap.
 * Implemented in 0D for now.
 */
class SpeciesTrappingPhysics : public PhysicsBase
{
public:
  static InputParameters validParams();

  SpeciesTrappingPhysics(const InputParameters & parameters);

  void addComponent(const ComponentAction & component);

protected:
  /// Which components this Physics is defined on
  std::vector<ComponentName> _components;
  /// The species of interest
  std::vector<std::vector<NonlinearVariableName>> _species;
  /// Scaling factor for each species balance equation, to achieve better system conditioning
  std::vector<std::vector<Real>> _scaling_factors;
  /// Initial conditions for each species
  std::vector<std::vector<Real>> _initial_conditions;
  /// Temperature of each enclosure
  std::vector<Real> _enclosure_temperatures;
  /// Equilibrium constants / solubilities?
  std::vector<std::vector<Real>> _species_Ks;

  /// Scaling factor for lengths
  const Real _length_unit;
  /// Scaling factor for pressures
  const Real _pressure_unit;

private:
  virtual void addNonlinearVariables() override;
  virtual void addInitialConditions() override;
  virtual void addScalarKernels() override;
  virtual void addFEBCs() override;

  /**
   * Routine to process an Enclosure component parameter into the Physics
   * @tparam T the type of the parameter to process
   * @param param_name name of the parameter
   * @param physics_storage storage for those values on the Physics
   * @param component_value values on the component
   * @param use_default whether to rely on a default value if the component does not provide
   * @param default_value the default
   */
  template <typename T>
  void processComponentParameters(const std::string & param_name,
                                  const std::string & comp_name,
                                  std::vector<T> & physics_storage,
                                  const T & component_value,
                                  bool use_default,
                                  const T & default_value);

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

template <typename T>
struct is_vector : public std::false_type
{
};

template <typename T, typename A>
struct is_vector<std::vector<T, A>> : public std::true_type
{
};

template <typename T>
void
SpeciesTrappingPhysics::processComponentParameters(const std::string & param_name,
                                                   const std::string & comp_name,
                                                   std::vector<T> & physics_storage,
                                                   const T & component_values,
                                                   bool use_default,
                                                   const T & default_values)
{
  bool component_value_valid = false;
  // Create new cases as needed
  if constexpr (is_vector<T>::value)
    component_value_valid = component_values.size();
  else
    component_value_valid = (component_values != 0);

  // Parameter added by the Physics, just need to check consistency
  if (isParamSetByUser(param_name))
  {
    if (component_value_valid && physics_storage[0] != component_values)
      paramError(param_name,
                 "'" + param_name + "' in component '" + comp_name + "' :\n" +
                     Moose::stringify(component_values) + "\n differs from '" + param_name +
                     "' in SpeciesTrappingPhysics:\n" + Moose::stringify(physics_storage[0]));
  }
  // Always add if it's been specified on a component instead
  else if (component_value_valid)
    physics_storage.push_back(component_values);
  // User did not specify the parameter, in the component or the Physics
  else if (use_default)
    physics_storage.push_back(default_values);
  else
    paramError(param_name,
               "This parameter should be specified, in the Physics '" + name() +
                   "' or in component '" + comp_name + "'");
}
