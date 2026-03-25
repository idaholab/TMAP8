# This input file adds the trapping sites 2 for validation case val-2f.
# It is included in val-2f.i

[Bounds]
  [trapped_2_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_2
    bound_type = lower
    bound_value = 0
  []
[]

[Functions]
  [trap_distribution_function_2]
    type = ParsedFunction
    expression = '${trapping_site_fraction_2} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_2_inf]
    type = ParsedFunction
    expression = '${trapping_site_fraction_2_inf} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping_2]
      species = 'trapped_2'
      species_scaling_factors = '1'
      species_initial_concentrations = '0'
      mobile = 'deuterium_concentration_W'
      dimensionless_trapping_rate = '${dimensionless_trapping_rate_2}'
      trapping_energy = '${trapping_energy_2}'
      N = ${tungsten_density}
      Ct0 = 'trap_distribution_function_2'
      trap_concentration_reference = '${trap_concentration_reference_2}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate = '${dimensionless_release_rate_2}'
      detrapping_energy = '${detrapping_energy_2}'
      temperature = 'temperature'
      dimensionless_species = true
    []
  []
[]

[Postprocessors]
  [integral_trapped_concentration_2]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_2
    outputs = none
  []
  [scaled_trapped_deuterium_2]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_2 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_2
  []
[]
