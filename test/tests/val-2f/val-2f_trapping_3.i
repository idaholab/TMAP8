# This input file adds the trapping sites 3 for validation case val-2f.
# It is included in val-2f.i

[Bounds]
  [trapped_3_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_3
    bound_type = lower
    bound_value = 0
  []
[]

[Functions]
  [trap_distribution_function_3]
    type = ParsedFunction
    expression = '${trapping_site_fraction_3} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_3_inf]
    type = ParsedFunction
    expression = '${trapping_site_fraction_3_inf} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping_3]
      species = 'trapped_3'
      species_scaling_factors = '1'
      species_initial_concentrations = '0'
      mobile = 'deuterium_concentration_W'
      dimensionless_trapping_rate = '${dimensionless_trapping_rate_3}'
      trapping_energy = '${trapping_energy_3}'
      N = ${tungsten_density}
      Ct0 = 'trap_distribution_function_3'
      trap_concentration_reference = '${trap_concentration_reference_3}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate = '${dimensionless_release_rate_3}'
      detrapping_energy = '${detrapping_energy_3}'
      temperature = 'temperature'
      dimensionless_species = true
    []
  []
[]

[Postprocessors]
  [integral_trapped_concentration_3]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_3
    outputs = none
  []
  [scaled_trapped_deuterium_3]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_3 * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_3
  []
[]
