/********************************************************/
/*             DO NOT MODIFY THIS HEADER                */
/* TMAP8: Tritium Migration Analysis Program, Version 8 */
/*                                                      */
/*    Copyright 2021 Battelle Energy Alliance, LLC      */
/*               ALL RIGHTS RESERVED                    */
/********************************************************/

#pragma once

#include "PhysicsBase.h"
#include "ComponentMaterialPropertyInterface.h"

#include <vector>
#include <type_traits>

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
   * Routine to process a component's values for a given quantity into the Physics'
   * component-indexed storage
   * @tparam T the type of the parameter to process
   * @param param_name name of the parameter
   * @param comp_name name of the component
   * @param physics_storage storage for those values on the Physics
   * @param component_value values on the component
   * @param use_default whether to rely on a default value if the physics and the component do not
   * have a parameter set
   * @param default_value a default
   */
  template <typename T>
  void processComponentValues(const std::string & param_name,
                              const std::string & comp_name,
                              std::vector<T> & physics_storage,
                              const T & component_value,
                              bool use_default,
                              const T & default_value);

  /**
   * Routine to process a component's parameter into the Physics component-indexed storage
   * @tparam T the type of the parameter to process
   * @param param_name name of the parameter
   * @param comp_name name of the component
   * @param physics_storage storage for those values on the Physics
   * @param component_param_name parameter name on the component
   * @param use_default whether to rely on a default value if the physics and the component do not
   * have a parameter set
   * @param default_value a default
   */
  template <typename T>
  void processComponentParameters(const std::string & param_name,
                                  const std::string & comp_name,
                                  std::vector<T> & physics_storage,
                                  const std::string & comp_param_name,
                                  bool use_default,
                                  const T & default_value);

  /**
   * Routine to process a component's material properties (must be derived from
   * ComponentMaterialPropertyInterface)
   * @tparam T the type of the parameter to process
   * @param param_name name of the parameter
   * @param comp the component
   * @param species the species on that component
   * @param physics_storage storage for those values on the Physics
   */
  template <typename T>
  void processComponentMatprop(const std::string & param_name,
                               const ActionComponent & comp,
                               const std::vector<NonlinearVariableName> & species,
                               std::vector<T> & physics_storage);
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
struct vector_value_type;

template <typename T, typename Alloc>
struct vector_value_type<std::vector<T, Alloc>>
{
  using type = T;
};

// Helper alias template
template <typename T>
using vector_value_type_t = typename vector_value_type<T>::type;

template <typename T>
void
SpeciesPhysicsBase::processComponentValues(const std::string & param_name,
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

template <typename T>
void
SpeciesPhysicsBase::processComponentParameters(const std::string & param_name,
                                               const std::string & comp_name,
                                               std::vector<T> & physics_storage,
                                               const std::string & comp_param_name,
                                               bool use_default,
                                               const T & default_values)
{
  bool component_value_valid = isParamValid(comp_param_name);

  // Parameter added by the Physics, just need to check consistency
  if (isParamSetByUser(param_name))
  {
    if (component_value_valid && physics_storage[0] != getParam<T>(comp_param_name))
      paramError(param_name,
                 "'" + param_name + "' in component '" + comp_name + "' :\n" +
                     Moose::stringify(getParam<T>(comp_param_name)) + "\n differs from '" +
                     param_name + "' in " + type() + ":\n" + Moose::stringify(physics_storage[0]));
    // Duplicate for simplicity
    physics_storage.push_back(physics_storage[0]);
  }
  // Always add if it's been specified on a component instead
  else if (component_value_valid)
    physics_storage.push_back(getParam<T>(comp_param_name));
  // User did not specify the parameter, in the component or the Physics
  else if (use_default)
    physics_storage.push_back(default_values);
  else
    paramError(param_name,
               "This parameter should be specified, in the Physics '" + name() +
                   "' (applying to all components) or in component '" + comp_name + "'");
}

template <typename T>
void
SpeciesPhysicsBase::processComponentMatprop(const std::string & param_name,
                                            const ActionComponent & comp,
                                            const std::vector<NonlinearVariableName> & species,
                                            std::vector<T> & physics_storage)
{
  // Check that the component could host material properties
  const auto * mat_comp = dynamic_cast<const ComponentMaterialPropertyInterface *>(&comp);
  const auto comp_name = comp.name();

  // Parameter added by the Physics, just need to check consistency
  if (isParamValid(param_name))
  {
    const auto & physics_value = getParam<T>(param_name);

    // Does not have the quantity as a material property anyway
    if (!mat_comp)
    {
      physics_storage.push_back(physics_value);
      return;
    }
    else
    {
      // For vectors, we have to get the properties one by one
      // We use the size of the species vector
      auto n_items = 1;
      if constexpr (is_vector<T>::value)
        n_items = _species.size();
      T temp_storage;

      for (const auto i : make_range(n_items))
      {
        const auto property_name = (n_items == 1) ? param_name : param_name + species[i];
        // Has the property, check the type
        if (mat_comp->hasProperty(property_name))
        {
          const auto & comp_value = mat_comp->getPropertyValue(property_name, name());
          try
          {
            if constexpr (is_vector<T>::value)
            {
              const auto & comp_value_conv =
                  MooseUtils::convert<vector_value_type_t<T>>(comp_value, true);
              if (physics_value[i] != comp_value_conv)
                paramError(param_name,
                           "'" + property_name + "' in component '" + comp_name + "' :\n" +
                               Moose::stringify(comp_value_conv) + "\n differs from '" +
                               param_name + "' in " + type() + ":\n" +
                               Moose::stringify(physics_storage[0][i]));
            }
            else
            {
              const auto & comp_value_conv = MooseUtils::convert<T>(comp_value, true);
              temp_storage = comp_value_conv;
              if (physics_value != comp_value_conv)
                paramError(param_name,
                           "'" + property_name + "' in component '" + comp_name + "' :\n" +
                               Moose::stringify(comp_value_conv) + "\n differs from '" +
                               param_name + "' in " + type() + ":\n" +
                               Moose::stringify(physics_storage[0]));
            }
          }
          catch (...)
          {
            comp.paramError("property_values",
                            "Property '" + property_name +
                                "' should be of type: " + MooseUtils::prettyCppType<T>());
          }
        }
      }

      // Duplicate the physics value for simplicity
      physics_storage.push_back(physics_value);
      return;
    }
  }
  // Parameter not defined in Physics, try to retrieve it from the component
  else
  {
    if (!mat_comp)
      mooseError("Component '",
                 comp.name(),
                 "' does not inherit from the ComponentMaterialPropertyInterface. It does not "
                 "define the '",
                 param_name,
                 "' property. This property should be defined in the '",
                 name(),
                 "' Physics instead.");

    auto n_items = 1;
    if constexpr (is_vector<T>::value)
      n_items = _species.size();
    T temp_storage;

    for (const auto i : make_range(n_items))
    {
      const auto property_name = (n_items == 1) ? param_name : param_name + species[i];
      // Has the property, check the type
      if (mat_comp->hasProperty(property_name))
      {
        const auto & comp_value = mat_comp->getPropertyValue(property_name, name());
        try
        {
          if constexpr (is_vector<T>::value)
          {
            const auto & comp_value_conv =
                MooseUtils::convert<vector_value_type_t<T>>(comp_value, true);
            temp_storage.push_back(comp_value_conv);
          }
          else
          {
            const auto & comp_value_conv = MooseUtils::convert<T>(comp_value, true);
            temp_storage = comp_value_conv;
          }
        }
        catch (...)
        {
          comp.paramError("property_values",
                          "Property '" + property_name +
                              "' should be of type: " + MooseUtils::prettyCppType<T>());
        }
      }
      else
        paramError(param_name,
                   "This parameter should be specified, in the Physics '" + name() +
                       "' (applying to all components) or in component '" + comp_name +
                       "' using the property_name '" + property_name + "'");
    }

    physics_storage.push_back(temp_storage);
  }
}
