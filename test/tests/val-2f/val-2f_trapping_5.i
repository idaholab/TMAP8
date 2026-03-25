# This input file adds the trapping sites 5 for validation case val-2f.
# It is included in val-2f.i

[Bounds]
  [trapped_5_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_5
    bound_type = lower
    bound_value = 0
  []
[]

[Functions]
  [trap_distribution_function_5]
    type = ParsedFunction
    expression = '${trapping_site_fraction_5} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_5_inf]
    type = ParsedFunction
    expression = '${trapping_site_fraction_5_inf} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping_5]
      species = 'trapped_5'
      species_scaling_factors = '1'
      species_initial_concentrations = '0'
      mobile = 'deuterium_concentration_W'
      dimensionless_trapping_rate = '${dimensionless_trapping_rate_5}'
      trapping_energy = '${trapping_energy_5}'
      N = ${tungsten_density}
      Ct0 = 'trap_distribution_function_5'
      trap_concentration_reference = '${trap_concentration_reference_5}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate = '${dimensionless_release_rate_5}'
      detrapping_energy = '${detrapping_energy_5}'
      temperature = 'temperature'
      dimensionless_species = true
    []
  []
[]

[Postprocessors]
  [integral_trapped_concentration_5]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_5
    outputs = none
  []
  [scaled_trapped_deuterium_5]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_5 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_5
  []
[]
