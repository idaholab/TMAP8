# Validation Problem val-2k
# Shared oxygen-field layer model for a validation case based on experimental
# data from Kremer et al. (2022):
# https://doi.org/10.1016/j.nme.2022.101137
# Unit system:
# - length: micrometers
# - time: seconds
# - concentration: atoms / micrometer^3
# - flux: atoms / micrometer^2 / second
# This file defines the front oxygen inventory profile, the tungsten and oxygen
# transport properties, and the auxiliary quantities used by the val-2k oxide
# cases.

[Functions]
  [oxide_position_function]
    type = ParsedFunction
    expression = '0.5 * (1 - tanh((x - ${oxide_thickness_hat}) / ${oxide_transition_width_hat}))'
  []
  [oxygen_initial_distribution_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function'
    symbol_values = 'oxide_position_function'
    expression = '${oxygen_initial_concentration_hat} * oxide_position_function'
  []
[]

[Materials]
  [diffusivity_tungsten_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_tungsten
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${diffusion_W_preexponential_hat} * exp(-${diffusion_W_energy} / ${kb_eV} / temperature)'
  []
  [diffusivity_oxygen_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_oxygen
    functor_names = 'temperature_history oxide_position_function'
    functor_symbols = 'temperature oxide_position_function'
    expression = '${oxygen_diffusion_W_preexponential_hat} * exp(-${oxygen_diffusion_W_energy} / ${kb_eV} / temperature) * oxide_position_function'
  []
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = Kr_d2_hat
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${d2_recombination_coefficient_hat} * exp(-${d2_recombination_energy} / ${kb_eV} / temperature)'
  []
  [flux_recombination_surface_d2]
    type = ADDerivativeParsedMaterial
    coupled_variables = deuterium_mobile
    property_name = flux_recombination_surface_d2
    material_property_names = Kr_d2_hat
    expression = '-2 * Kr_d2_hat * deuterium_mobile ^ 2'
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
    material_property_names = 'Kr_d2o_hat'
    expression = '-2 * Kr_d2o_hat * oxygen * deuterium_mobile ^ 2'
  []
  [flux_recombination_surface_oxygen]
    type = ADDerivativeParsedMaterial
    property_name = flux_recombination_surface_oxygen
    material_property_names = flux_recombination_surface_d2o
    expression = '${oxygen_release_stoichiometric_factor_hat} * flux_recombination_surface_d2o'
  []
[]
