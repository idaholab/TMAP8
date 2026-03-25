# This input file adds the trapping sites 1 for validation case val-2f.
# It is included in val-2f.i

[Bounds]
  [trapped_1_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_1
    bound_type = lower
    bound_value = 0
  []
[]

[Functions]
  [trap_distribution_function_1]
    type = ParsedFunction
    expression = '${trapping_site_fraction_1} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_1_inf]
    type = ParsedFunction
    expression = '${trapping_site_fraction_1_inf} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping_1]
      species = 'trapped_1'
      species_scaling_factors = '1'
      species_initial_concentrations = '0'
      mobile = 'deuterium_concentration_W'
      dimensionless_trapping_rate = '${dimensionless_trapping_rate_1}'
      trapping_energy = '${trapping_energy_1}'
      N = ${tungsten_density}
      Ct0 = 'trap_distribution_function_1'
      trap_concentration_reference = '${trap_concentration_reference_1}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate = '${dimensionless_release_rate_1}'
      detrapping_energy = '${detrapping_energy_1}'
      temperature = 'temperature'
      dimensionless_species = true
    []
  []
[]

[Postprocessors]
  [integral_trapped_concentration_1]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_1
    outputs = none
  []
  [scaled_trapped_deuterium_1]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_1 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_1
  []
[]
