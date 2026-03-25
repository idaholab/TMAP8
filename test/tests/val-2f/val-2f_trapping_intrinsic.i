# This input file adds the intrinsic trapping sites for validation case val-2f.
# It is included in val-2f.i

[Bounds]
  [trapped_intrinsic_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_intrinsic
    bound_type = lower
    bound_value = 0
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping_intrinsic]
      species = 'trapped_intrinsic'
      species_scaling_factors = '1'
      species_initial_concentrations = '0'
      mobile = 'deuterium_concentration_W'
      dimensionless_trapping_rate = '${dimensionless_trapping_rate_intrinsic}'
      trapping_energy = '${trapping_energy_intrinsic}'
      N = ${tungsten_density}
      Ct0 = '${trapping_site_fraction_intrinsic}'
      trap_concentration_reference = '${trap_concentration_reference_intrinsic}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate = '${dimensionless_release_rate_intrinsic}'
      detrapping_energy = '${detrapping_energy_intrinsic}'
      temperature = 'temperature'
      dimensionless_species = true
    []
  []
[]

[Postprocessors]
  [integral_trapped_concentration_intrinsic]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_intrinsic
    outputs = none
  []
  [scaled_trapped_deuterium_intrinsic]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_concentration_reference_intrinsic * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_intrinsic
  []
  [max_scaled_trapped_deuterium_intrinsic]
    type = TimeExtremeValue
    postprocessor = scaled_trapped_deuterium_intrinsic
    value_type = max
    outputs = 'console'
  []
[]
