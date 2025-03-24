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
  virtual void checkIntegrity() const override;

  /// Which components this Physics is defined on
  std::vector<ComponentName> _components;
  /// The species of interest
  std::vector<std::vector<NonlinearVariableName>> _species;
  /// Scaling factor for each species balance equation, to achieve better system conditioning
  std::vector<std::vector<Real>> _scaling_factors;
  /// Initial conditions for each species
  std::vector<std::vector<MooseFunctorName>> _initial_conditions;
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

  /// Helper routine to output 'on component xyz' in error messages
  /// @param comp_index index of the component
  std::string getOnComponentString(unsigned int comp_index) const;
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
    mooseError("Not implemented for this data type");

  // Parameter added by the Physics, just need to check consistency
  if (isParamSetByUser(param_name))
  {
    T temp_storage;
    if (component_value_valid && physics_storage[0] != component_values)
    {
      // It could be that they are different because they pertain to a subset of the species defined
      // on the Physics. We should allow that
      const auto & comp = getActionComponent(comp_name);
      bool consistent = false;
      // We can only do this for species-indexed vectors
      if constexpr (is_vector<T>::value)
      {
        if (comp.isParamValid("species") && comp_index > 0)
        {
          consistent = true;

          // All the TMAP8 components have a species parameter, so this works for them. For a
          // general component, it likely won't have this parameter. In that case, we will just
          // error and users will have to ensure Physics and Component specified values are
          // consistent.
          const auto & species_component =
              comp.getParam<std::vector<NonlinearVariableName>>("species");
          for (const auto i_comp_sp : index_range(species_component))
          {
            const auto & specie = species_component[i_comp_sp];
            // Find index in Physics species vector
            bool found_specie = false;
            for (const auto i_phy : index_range(_species))
            {
              // The Physics parameters are at index 0
              if (specie == _species[0][i_phy])
              {
                found_specie = true;

                // Check sizes. We can never check sizes enough
                if (i_phy >= physics_storage[0].size())
                  paramError(param_name,
                             "Index '" + std::to_string(i_phy) + "' for species '" + specie +
                                 " is beyond parameter size " +
                                 std::to_string(physics_storage[0].size()));
                if (i_comp_sp >= component_values.size())
                  comp.mooseError("For quantity " + param_name + ": Index '" +
                                  std::to_string(i_comp_sp) + "' for species '" + specie +
                                  " is beyond parameter size " +
                                  std::to_string(component_values.size()));

                if (physics_storage[0][i_phy] != component_values[i_comp_sp])
                  consistent = false;

                // Store the component value
                temp_storage.push_back(component_values[i_comp_sp]);
              }
            }
            // A component species was not defined in the Physics parameters. We wont support that
            // for now but we could in the future.
            if (!found_specie)
              consistent = false;
          }
        }
      }

      // We cannot allow any difference because the values / parameters are indexed the same way as
      // the Physics
      if (temp_storage != physics_storage[0])
        consistent = false;

      if (!consistent)
        paramError(param_name,
                   "'" + param_name + "' in component '" + comp_name + "' :\n" +
                       Moose::stringify(component_values) + "\n differs from '" + param_name +
                       "' in " + type() + ":\n" + Moose::stringify(physics_storage[0]));
    }
    // Use the Physics parameter
    else
      temp_storage = physics_storage[0];

    // Add the component values anyway in case the component values are a subset of the Physics'
    if (comp_index > 0)
      physics_storage.push_back(temp_storage);
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
    T temp_storage;

    // Check that the value is actually valid
    if (component_value_valid)
    {
      const auto & component_values = comp.getParam<T>(comp_param_name);
      // Create new cases as needed. The parameter is valid but the default does not work here
      if constexpr (is_vector<T>::value)
        component_value_valid = component_values.size();
      else if constexpr (std::is_same_v<T, MooseFunctorName>)
        component_value_valid = !component_values.empty();
    }

    if (component_value_valid && physics_storage[0] != comp.getParam<T>(comp_param_name))
    {
      const auto & component_values = comp.getParam<T>(comp_param_name);
      // It could be that they are different because they pertain to a subset of the species defined
      // on the Physics. We should allow that
      bool consistent = false;
      // We can only do this for species-indexed vectors
      if constexpr (is_vector<T>::value)
      {
        if (comp.isParamValid("species"))
        {
          consistent = true;
          // All the TMAP8 components have a species parameter, so this works for them. For a
          // general component, it likely won't have this parameter. In that case, we will just
          // error and users will have to ensure Physics and Component specified values are
          // consistent.
          const auto & species_component =
              comp.getParam<std::vector<NonlinearVariableName>>("species");
          for (const auto i_comp_sp : index_range(species_component))
          {
            const auto & specie = species_component[i_comp_sp];
            // Find index in Physics species vector
            // Note that some species in the component species are not governed by this Physics
            for (const auto i_phy : index_range(_species[0]))
            {
              // The Physics parameters are at index 0
              if (specie == _species[0][i_phy])
              {
                // Check sizes. We can never check sizes enough
                if (i_phy >= physics_storage[0].size())
                  paramError(param_name,
                             "Index '" + std::to_string(i_phy) + "' for species '" + specie +
                                 " is beyond parameter size " +
                                 std::to_string(physics_storage[0].size()));
                if (i_comp_sp >= component_values.size())
                  comp.paramError(comp_param_name,
                                  "Index '" + std::to_string(i_comp_sp) + "' for species '" +
                                      specie + " is beyond parameter size " +
                                      std::to_string(component_values.size()));

                if (physics_storage[0][i_phy] != component_values[i_comp_sp])
                  consistent = false;

                // Store the component value
                temp_storage.push_back(component_values[i_comp_sp]);
              }
            }
          }
        }
      }

      // The parameters are indexed the same way as the species. But we can handle:
      // - less species on the Physics than in the component, but ordered the same way
      // - different ordering of the species in the Physics and Components, as the parameters are
      // resorted above We can't handle:
      // - more species in the Physics, because the Physics would add more equations than needed on
      // the component And we disallow specifying different parameters in the Physics and the
      // Components for a given species
      if (temp_storage != physics_storage[0])
        consistent = false;

      if (!consistent)
        paramError(param_name,
                   "'" + param_name + "' in component '" + comp_name + "' :\n" +
                       Moose::stringify(comp.getParam<T>(comp_param_name)) + "\n differs from '" +
                       param_name + "' in " + type() + ":\n" +
                       Moose::stringify(physics_storage[0]));
    }
    // Use the Physics parameter
    else
      temp_storage = physics_storage[0];

    // Add the component values
    if (comp_index > 0)
      physics_storage.push_back(temp_storage);
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
