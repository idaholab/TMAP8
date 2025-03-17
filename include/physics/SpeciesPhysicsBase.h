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
                              unsigned int comp_index,
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
                                  unsigned int comp_index,
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
                               unsigned int comp_index,
                               const std::vector<NonlinearVariableName> & species,
                               std::vector<T> & physics_storage);

  /** Defense in depth routine to prevent OOB access **/
  /**
   * Routine to check the size of the vectors storing component-indexed quantities.
   * @param vector a vector indexed by components
   * @param param_name the name of the parameter related to this quantity
   * @param allow_component_shared_value whether to allow a single vector, for the first component,
   * which will be used by all components
   */
  template <typename T>
  void checkSizeComponentIndexedVector(const std::vector<T> & vector,
                                       const std::string & param_name,
                                       bool allow_component_shared_value) const;

  /**
   * Routine to check the size of the vectors storing component-indexed and species-indexed
   * quantities.
   * @param double_indexed a vector indexed by components and species
   * @param param_name the name of the parameter related to this quantity
   * @param allow_component_shared_value whether to allow a single vector, for the first component,
   * which will be used by all components
   */
  template <typename T>
  void
  checkSizeComponentSpeciesIndexedVectorOfVector(const std::vector<std::vector<T>> & double_indexed,
                                                 const std::string & param_name,
                                                 bool allow_component_shared_value) const;
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
                                           const unsigned int comp_index,
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
    if (comp_index > 0)
      physics_storage.push_back(physics_storage[0]);
  }
  // Always add if it's been specified on a component instead
  else if (component_value_valid)
  {
    // Replace the empty default
    if (comp_index == 0)
    {
      if (physics_storage.empty())
        physics_storage.resize(1);
      physics_storage[0] = component_values;
    }
    else
      physics_storage.push_back(component_values);
  }
  // User did not specify the parameter, in the component or the Physics
  else if (use_default)
  {
    // Replace the empty default
    if (comp_index == 0)
    {
      if (physics_storage.empty())
        physics_storage.resize(1);
      physics_storage[0] = default_values;
    }
    else
      physics_storage.push_back(default_values);
  }
  else
    paramError(param_name,
               "This parameter should be specified, in the Physics '" + name() +
                   "' (applying to all components) or in component '" + comp_name + "'");
}

template <typename T>
void
SpeciesPhysicsBase::processComponentParameters(const std::string & param_name,
                                               const std::string & comp_name,
                                               const unsigned int comp_index,
                                               std::vector<T> & physics_storage,
                                               const std::string & comp_param_name,
                                               bool use_default,
                                               const T & default_values)
{
  const auto & comp = getActionComponent(comp_name);
  bool component_value_valid = comp.isParamValid(comp_param_name);

  // Parameter added by the Physics, just need to check consistency
  if (isParamSetByUser(param_name))
  {
    if (component_value_valid && physics_storage[0] != comp.getParam<T>(comp_param_name))
      paramError(param_name,
                 "'" + param_name + "' in component '" + comp_name + "' :\n" +
                     Moose::stringify(comp.getParam<T>(comp_param_name)) + "\n differs from '" +
                     param_name + "' in " + type() + ":\n" + Moose::stringify(physics_storage[0]));
    // Duplicate for simplicity
    if (comp_index > 0)
      physics_storage.push_back(physics_storage[0]);
  }
  // Always add if it's been specified on a component instead
  else if (component_value_valid)
  {
    // Replace the empty default
    if (comp_index == 0)
    {
      if (physics_storage.empty())
        physics_storage.resize(1);
      physics_storage[0] = comp.getParam<T>(comp_param_name);
    }
    else
      physics_storage.push_back(comp.getParam<T>(comp_param_name));
  }
  // User did not specify the parameter, in the component or the Physics
  else if (use_default)
  {
    // Replace the empty default
    if (comp_index == 0)
    {
      if (physics_storage.empty())
        physics_storage.resize(1);
      physics_storage[0] = default_values;
    }
    else
      physics_storage.push_back(default_values);
  }
  else
    paramError(param_name,
               "This parameter should be specified, in the Physics '" + name() +
                   "' (applying to all components) or in component '" + comp_name + "'");
}

template <typename T>
void
SpeciesPhysicsBase::processComponentMatprop(const std::string & param_name,
                                            const ActionComponent & comp,
                                            const unsigned int comp_index,
                                            const std::vector<NonlinearVariableName> & species,
                                            std::vector<T> & physics_storage)
{
  // Check that the component could host material properties
  const auto * mat_comp = dynamic_cast<const ComponentMaterialPropertyInterface *>(&comp);
  const auto comp_name = comp.name();

  // Parameter added by the Physics, just need to check consistency
  if (isParamSetByUser(param_name))
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

      for (const auto i : make_range(n_items))
      {
        const auto property_name = (n_items == 1) ? param_name : param_name + "_" + species[i];
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
      if (comp_index > 0)
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
      const auto property_name = (n_items == 1) ? param_name : param_name + "_" + species[i];
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

    // Replace the empty default
    if (comp_index == 0)
    {
      if (physics_storage.empty())
        physics_storage.resize(1);
      physics_storage[0] = temp_storage;
    }
    else
      physics_storage.push_back(temp_storage);
  }
}

template <typename T>
void
SpeciesPhysicsBase::checkSizeComponentIndexedVector(const std::vector<T> & vector,
                                                    const std::string & param_name,
                                                    bool allow_component_shared_value) const
{
  if (vector.size() == 0)
    paramError(param_name,
               "The Physics does not have any values set for this parameter. It should be provided "
               "on each component, or specified once on the Physics and shared by all components");

  if (vector.size() != _components.size())
  {
    if (!allow_component_shared_value || vector.size() != 1)
      paramError(param_name,
                 "We have '" + std::to_string(_components.size()) + "' Components but we found '" +
                     std::to_string(vector.size()) +
                     "' values. This quantity should be provided by each component for specified "
                     "once in the Physics for all components.");
  }
}

template <typename T>
void
SpeciesPhysicsBase::checkSizeComponentSpeciesIndexedVectorOfVector(
    const std::vector<std::vector<T>> & double_indexed,
    const std::string & param_name,
    bool allow_component_shared_value) const
{
  if (double_indexed.size() == 0)
    paramError(param_name,
               "The Physics does not have any values set for this parameter. It should be provided "
               "on each component, or specified once on the Physics and shared by all components");
  mooseAssert(_components.size() != 0,
              "This routine is being used without components defined for the Physics");

  if (double_indexed.size() != _components.size())
  {
    if (allow_component_shared_value && double_indexed.size() == 1)
    {
      if (double_indexed[0].size() != _species.size())
        paramError(param_name,
                   "A value should be specified for each species. Only '" +
                       std::to_string(double_indexed.size()) + "' values were found");
    }
    else
      paramError(param_name,
                 "We have '" + std::to_string(_components.size()) + "' Components but we found '" +
                     std::to_string(double_indexed.size()) +
                     "' values. This quantity should be provided by each component");
  }
  else
    for (const auto c_index : index_range(double_indexed))
    {
      if (c_index > _species.size())
        paramError("species",
                   "The species have not been specified for component '" + _components[c_index] +
                       "'");
      if (double_indexed[c_index].size() != _species[c_index].size())
        paramError(param_name,
                   "We have '" + std::to_string(_species[c_index].size()) +
                       "' species for component '" + _components[c_index] +
                       "' but we only found '" + std::to_string(double_indexed[c_index].size()) +
                       "' values for that quantity. This quantity should be provided by each "
                       "component and for each species");
    }
}
