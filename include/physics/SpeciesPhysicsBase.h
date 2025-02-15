/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "PhysicsBase.h"

/**
 * Base class for physics implementing the trapping of one or more species in a medium
 */
class SpeciesPhysicsBase : public PhysicsBase
{
public:
  static InputParameters validParams();

  SpeciesPhysicsBase(const InputParameters & parameters);

protected:
  /// Which components this Physics is defined on
  std::vector<ComponentName> _components;
  /// The species of interest
  std::vector<std::vector<NonlinearVariableName>> _species;
  /// Scaling factor for each species balance equation, to achieve better system conditioning
  std::vector<std::vector<Real>> _scaling_factors;
  /// Initial conditions for each species
  std::vector<std::vector<Real>> _initial_conditions;
  /// Temperature of each component
  std::vector<MooseFunctorName> _component_temperatures;

  /**
   * Routine to process an Enclosure component parameter into the Physics
   * @tparam T the type of the parameter to process
   * @param param_name name of the parameter
   * @param physics_storage storage for those values on the Physics
   * @param component_value values on the component
   * @param use_default whether to rely on a default value if the physics and the component do not
   * have a parameter set
   * @param default_value a default
   */
  template <typename T>
  void processComponentParameters(const std::string & param_name,
                                  const std::string & comp_name,
                                  std::vector<T> & physics_storage,
                                  const T & component_value,
                                  bool use_default,
                                  const T & default_value);
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
SpeciesPhysicsBase::processComponentParameters(const std::string & param_name,
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
  else if constexpr (std::is_same_v<T, MooseFunctorName>)
    component_value_valid = !component_values.empty();
  else
    mooseError("Not implemented");

  // Parameter added by the Physics, just need to check consistency
  if (isParamSetByUser(param_name))
  {
    if (component_value_valid && physics_storage[0] != component_values)
      paramError(param_name,
                 "'" + param_name + "' in component '" + comp_name + "' :\n" +
                     Moose::stringify(component_values) + "\n differs from '" + param_name +
                     "' in " + type() + ":\n" + Moose::stringify(physics_storage[0]));
    // Duplicate for simplicity
    physics_storage.push_back(physics_storage[0]);
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
                   "' (applying to all components) or in component '" + comp_name + "'");
}
