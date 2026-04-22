# This input file defines the constant transport properties used for the explicit
# 5 nm oxide layer in val-2k. It assigns a separate diffusivity to the oxide and
# tungsten blocks while keeping the same D2 recombination release law as the
# tungsten-only baseline.

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
[]
