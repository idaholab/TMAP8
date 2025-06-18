# This input file adds the trapping sites 2 for validation case val-2f.
# It is included in val-2f.i

[Variables]
  [trapped_2]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  [trapped_2_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_2
    bound_type = lower
    bound_value = '${fparse -1e-20}'
  []
[]

[Kernels]
  # trapping 2 kernel
  [coupled_time_trap_2]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_concentration_W
    v = trapped_2
    coef = ${trap_per_free_2}
  []
[]

[NodalKernels]
  # Second traps
  [time_2]
    type = TimeDerivativeNodalKernel
    variable = trapped_2
  []
  [trapping_2]
    type = TrappingNodalKernel
    variable = trapped_2
    mobile_concentration = deuterium_concentration_W
    alpha_t = '${trapping_prefactor_2}'
    trapping_energy = '${trapping_energy_2}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function_2'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_2}
  []
  [release_2]
    type = ReleasingNodalKernel
    variable = trapped_2
    alpha_r = '${detrapping_prefactor_2}'
    detrapping_energy = '${detrapping_energy_2}'
    temperature = 'temperature'
  []
[]

[Functions]
  [trap_distribution_function_2]
    type = ParsedFunction
    expression = '${trapping_site_fraction_2} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  # [trap_distribution_function_2_inf]
  #   type = ParsedFunction
  #   expression = '${trapping_site_fraction_2_inf} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  # []
[]

[Materials]
  [trap_distribution_function_2]
    type = GenericFunctionMaterial
    prop_names = trap_distribution_function_2
    prop_values = trap_distribution_function_2
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
    scaling_factor = '${fparse ${trap_per_free_2} * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_2
  []
[]
