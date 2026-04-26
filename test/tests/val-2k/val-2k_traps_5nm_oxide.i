# This input file defines the six scaled trap model used by the 5 nm oxygen-
# field oxide case in val-2k. The trap densities are multiplied by a sharp tanh
# profile that suppresses trapping inside the front oxide region while
# preserving the original tungsten distributions in the substrate.

[Bounds]
  [deuterium_trapped_intrinsic_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_trapped_intrinsic
    bound_type = lower
    bound_value = 0
  []
  [deuterium_trapped_1_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_trapped_1
    bound_type = lower
    bound_value = 0
  []
  [deuterium_trapped_2_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_trapped_2
    bound_type = lower
    bound_value = 0
  []
  [deuterium_trapped_3_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_trapped_3
    bound_type = lower
    bound_value = 0
  []
  [deuterium_trapped_4_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_trapped_4
    bound_type = lower
    bound_value = 0
  []
  [deuterium_trapped_5_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_trapped_5
    bound_type = lower
    bound_value = 0
  []
[]

[Functions]
  [damage_profile_function]
    type = ParsedFunction
    expression = '1 / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_intrinsic_sites_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function'
    symbol_values = 'oxide_position_function'
    expression = '${trapping_site_fraction_intrinsic} * (1 - oxide_position_function)'
  []
  [trap_1_sites_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function damage_profile_function'
    symbol_values = 'oxide_position_function damage_profile_function'
    expression = '${trapping_site_fraction_1} * (1 - oxide_position_function) * damage_profile_function'
  []
  [trap_2_sites_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function damage_profile_function'
    symbol_values = 'oxide_position_function damage_profile_function'
    expression = '${trapping_site_fraction_2} * (1 - oxide_position_function) * damage_profile_function'
  []
  [trap_3_sites_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function damage_profile_function'
    symbol_values = 'oxide_position_function damage_profile_function'
    expression = '${trapping_site_fraction_3} * (1 - oxide_position_function) * damage_profile_function'
  []
  [trap_4_sites_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function damage_profile_function'
    symbol_values = 'oxide_position_function damage_profile_function'
    expression = '${trapping_site_fraction_4} * (1 - oxide_position_function) * damage_profile_function'
  []
  [trap_5_sites_function]
    type = ParsedFunction
    symbol_names = 'oxide_position_function damage_profile_function'
    symbol_values = 'oxide_position_function damage_profile_function'
    expression = '${trapping_site_fraction_5} * (1 - oxide_position_function) * damage_profile_function'
  []

  [initial_deuterium_trapped_intrinsic]
    type = ParsedFunction
    symbol_names = 'trap_sites_function'
    symbol_values = 'trap_intrinsic_sites_function'
    expression = 'trap_sites_function * ${tungsten_density} / ${trap_concentration_reference_intrinsic}'
  []
  [initial_deuterium_trapped_1]
    type = ParsedFunction
    symbol_names = 'trap_sites_function'
    symbol_values = 'trap_1_sites_function'
    expression = 'trap_sites_function * ${tungsten_density} / ${trap_concentration_reference_1}'
  []
  [initial_deuterium_trapped_2]
    type = ParsedFunction
    symbol_names = 'trap_sites_function'
    symbol_values = 'trap_2_sites_function'
    expression = 'trap_sites_function * ${tungsten_density} / ${trap_concentration_reference_2}'
  []
  [initial_deuterium_trapped_3]
    type = ParsedFunction
    symbol_names = 'trap_sites_function'
    symbol_values = 'trap_3_sites_function'
    expression = 'trap_sites_function * ${tungsten_density} / ${trap_concentration_reference_3}'
  []
  [initial_deuterium_trapped_4]
    type = ParsedFunction
    symbol_names = 'trap_sites_function'
    symbol_values = 'trap_4_sites_function'
    expression = 'trap_sites_function * ${tungsten_density} / ${trap_concentration_reference_4}'
  []
  [initial_deuterium_trapped_5]
    type = ParsedFunction
    symbol_names = 'trap_sites_function'
    symbol_values = 'trap_5_sites_function'
    expression = 'trap_sites_function * ${tungsten_density} / ${trap_concentration_reference_5}'
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping_intrinsic]
      species = 'deuterium_trapped_intrinsic'
      species_scaling_factors = '1'
      species_initial_concentrations = 'initial_deuterium_trapped_intrinsic'
      mobile = 'deuterium_mobile'
      dimensionless_trapping_rate_coefficient = '${dimensionless_trapping_rate_coefficient_intrinsic}'
      trapping_energy = '${trapping_energy_intrinsic}'
      N = ${tungsten_density}
      Ct0 = 'trap_intrinsic_sites_function'
      trap_concentration_reference = '${trap_concentration_reference_intrinsic}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate_coefficient = '${dimensionless_release_rate_coefficient_intrinsic}'
      detrapping_energy = '${detrapping_energy_intrinsic}'
      temperature = 'temperature'
      dimensionless_species = true
    []
    [trapping_1]
      species = 'deuterium_trapped_1'
      species_scaling_factors = '1'
      species_initial_concentrations = 'initial_deuterium_trapped_1'
      mobile = 'deuterium_mobile'
      dimensionless_trapping_rate_coefficient = '${dimensionless_trapping_rate_coefficient_1}'
      trapping_energy = '${trapping_energy_1}'
      N = ${tungsten_density}
      Ct0 = 'trap_1_sites_function'
      trap_concentration_reference = '${trap_concentration_reference_1}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate_coefficient = '${dimensionless_release_rate_coefficient_1}'
      detrapping_energy = '${detrapping_energy_1}'
      temperature = 'temperature'
      dimensionless_species = true
    []
    [trapping_2]
      species = 'deuterium_trapped_2'
      species_scaling_factors = '1'
      species_initial_concentrations = 'initial_deuterium_trapped_2'
      mobile = 'deuterium_mobile'
      dimensionless_trapping_rate_coefficient = '${dimensionless_trapping_rate_coefficient_2}'
      trapping_energy = '${trapping_energy_2}'
      N = ${tungsten_density}
      Ct0 = 'trap_2_sites_function'
      trap_concentration_reference = '${trap_concentration_reference_2}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate_coefficient = '${dimensionless_release_rate_coefficient_2}'
      detrapping_energy = '${detrapping_energy_2}'
      temperature = 'temperature'
      dimensionless_species = true
    []
    [trapping_3]
      species = 'deuterium_trapped_3'
      species_scaling_factors = '1'
      species_initial_concentrations = 'initial_deuterium_trapped_3'
      mobile = 'deuterium_mobile'
      dimensionless_trapping_rate_coefficient = '${dimensionless_trapping_rate_coefficient_3}'
      trapping_energy = '${trapping_energy_3}'
      N = ${tungsten_density}
      Ct0 = 'trap_3_sites_function'
      trap_concentration_reference = '${trap_concentration_reference_3}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate_coefficient = '${dimensionless_release_rate_coefficient_3}'
      detrapping_energy = '${detrapping_energy_3}'
      temperature = 'temperature'
      dimensionless_species = true
    []
    [trapping_4]
      species = 'deuterium_trapped_4'
      species_scaling_factors = '1'
      species_initial_concentrations = 'initial_deuterium_trapped_4'
      mobile = 'deuterium_mobile'
      dimensionless_trapping_rate_coefficient = '${dimensionless_trapping_rate_coefficient_4}'
      trapping_energy = '${trapping_energy_4}'
      N = ${tungsten_density}
      Ct0 = 'trap_4_sites_function'
      trap_concentration_reference = '${trap_concentration_reference_4}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate_coefficient = '${dimensionless_release_rate_coefficient_4}'
      detrapping_energy = '${detrapping_energy_4}'
      temperature = 'temperature'
      dimensionless_species = true
    []
    [trapping_5]
      species = 'deuterium_trapped_5'
      species_scaling_factors = '1'
      species_initial_concentrations = 'initial_deuterium_trapped_5'
      mobile = 'deuterium_mobile'
      dimensionless_trapping_rate_coefficient = '${dimensionless_trapping_rate_coefficient_5}'
      trapping_energy = '${trapping_energy_5}'
      N = ${tungsten_density}
      Ct0 = 'trap_5_sites_function'
      trap_concentration_reference = '${trap_concentration_reference_5}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate_coefficient = '${dimensionless_release_rate_coefficient_5}'
      detrapping_energy = '${detrapping_energy_5}'
      temperature = 'temperature'
      dimensionless_species = true
    []
  []
[]

[Postprocessors]
  [integral_trapped_concentration_intrinsic]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_intrinsic
    outputs = none
  []
  [scaled_trapped_deuterium_intrinsic]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_intrinsic * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_intrinsic
  []
  [trapped_deuterium_intrinsic_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_trapped_deuterium_intrinsic
  []

  [integral_trapped_concentration_1]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_1
    outputs = none
  []
  [scaled_trapped_deuterium_1]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_1 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_1
  []
  [trapped_deuterium_1_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_trapped_deuterium_1
  []

  [integral_trapped_concentration_2]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_2
    outputs = none
  []
  [scaled_trapped_deuterium_2]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_2 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_2
  []
  [trapped_deuterium_2_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_trapped_deuterium_2
  []

  [integral_trapped_concentration_3]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_3
    outputs = none
  []
  [scaled_trapped_deuterium_3]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_3 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_3
  []
  [trapped_deuterium_3_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_trapped_deuterium_3
  []

  [integral_trapped_concentration_4]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_4
    outputs = none
  []
  [scaled_trapped_deuterium_4]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_4 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_4
  []
  [trapped_deuterium_4_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_trapped_deuterium_4
  []

  [integral_trapped_concentration_5]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_5
    outputs = none
  []
  [scaled_trapped_deuterium_5]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_5 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_5
  []
  [trapped_deuterium_5_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_trapped_deuterium_5
  []
[]
