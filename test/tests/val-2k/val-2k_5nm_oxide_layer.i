# This input file defines the smooth oxygen-field representation used for the
# 5 nm oxide case in val-2k. A sharp tanh transition maps the front oxide layer
# onto blended deuterium transport properties, while the oxygen inventory
# evolves dynamically and gates the D2O release channel.

[Functions]
  [oxide_indicator_function]
    type = ParsedFunction
    expression = '0.5 * (1 - tanh((x - ${oxide_thickness_hat}) / ${oxide_transition_width_hat}))'
  []
  [tungsten_indicator_function]
    type = ParsedFunction
    expression = '0.5 * (1 + tanh((x - ${oxide_thickness_hat}) / ${oxide_transition_width_hat}))'
  []
  [oxygen_initial_function]
    type = ParsedFunction
    symbol_names = 'oxide_indicator_function'
    symbol_values = 'oxide_indicator_function'
    expression = '${oxygen_initial_concentration_hat} * oxide_indicator_function'
  []
[]

[Materials]
  [oxide_indicator]
    type = ADGenericFunctionMaterial
    prop_names = oxide_indicator
    prop_values = oxide_indicator_function
  []
  [tungsten_indicator]
    type = ADGenericFunctionMaterial
    prop_names = tungsten_indicator
    prop_values = tungsten_indicator_function
  []
  [diffusivity_oxide_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_oxide
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${diffusion_oxide_preexponential_hat} * exp(-${diffusion_oxide_energy} / ${kb_eV} / temperature)'
  []
  [diffusivity_tungsten_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_tungsten
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${diffusion_W_preexponential_hat} * exp(-${diffusion_W_energy} / ${kb_eV} / temperature)'
  []
  [diffusivity_mobile_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_mobile
    material_property_names = 'diffusivity_oxide diffusivity_tungsten oxide_indicator tungsten_indicator'
    expression = 'oxide_indicator * diffusivity_oxide + tungsten_indicator * diffusivity_tungsten'
  []
  [diffusivity_oxygen_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_oxygen
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${oxygen_diffusion_W_preexponential_hat} * exp(-${oxygen_diffusion_W_energy} / ${kb_eV} / temperature)'
  []
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = Kr_hat
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${recombination_coefficient_hat} * exp(-${recombination_energy} / ${kb_eV} / temperature)'
  []
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = deuterium_mobile
    property_name = flux_recombination_surface
    material_property_names = Kr_hat
    expression = '-2 * Kr_hat * deuterium_mobile ^ 2'
  []
  [d2o_recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = Kr_d2o_hat
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${d2o_recombination_coefficient_hat} * exp(-${d2o_recombination_energy} / ${kb_eV} / temperature)'
  []
  [flux_recombination_surface_d2o]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'deuterium_mobile oxygen'
    property_name = flux_recombination_surface_d2o
    material_property_names = 'Kr_d2o_hat oxide_indicator'
    expression = '-2 * Kr_d2o_hat * oxide_indicator * oxygen * deuterium_mobile ^ 2'
  []
  [flux_recombination_surface_oxygen]
    type = ADDerivativeParsedMaterial
    property_name = flux_recombination_surface_oxygen
    material_property_names = flux_recombination_surface_d2o
    expression = '${oxygen_release_stoichiometric_factor_hat} * flux_recombination_surface_d2o'
  []
[]
