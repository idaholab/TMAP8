# This input file defines the constant transport properties used for the explicit
# 5 nm oxide layer in val-2k. It assigns a separate diffusivity to the oxide and
# tungsten blocks while keeping the same phenomenological D2 and D2O surface
# release laws as the tungsten-only baseline.

[Materials]
  [diffusivity_oxide_material]
    type = ADDerivativeParsedMaterial
    block = 0
    property_name = diffusivity_mobile
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${diffusion_oxide_preexponential_hat} * exp(-${diffusion_oxide_energy} / ${kb_eV} / temperature)'
  []
  [diffusivity_tungsten_material]
    type = ADDerivativeParsedMaterial
    block = 1
    property_name = diffusivity_mobile
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${diffusion_W_preexponential_hat} * exp(-${diffusion_W_energy} / ${kb_eV} / temperature)'
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
    coupled_variables = deuterium_mobile
    property_name = flux_recombination_surface_d2o
    material_property_names = Kr_d2o_hat
    expression = '-2 * Kr_d2o_hat * deuterium_mobile ^ 2'
  []
[]
