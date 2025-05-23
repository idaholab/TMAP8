[Variables]
  [trapped_3]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  [trapped_3_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_3
    bound_type = lower
    bound_value = '${fparse -1e-20}'
  []
[]

[Kernels]
  # trapping 3 kernel
  [coupled_time_trap_3]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_concentration_W
    v = trapped_3
    coef = ${trap_per_free_3}
  []
[]

[NodalKernels]
  # Second traps
  [time_3]
    type = TimeDerivativeNodalKernel
    variable = trapped_3
  []
  [trapping_3]
    type = TrappingNodalKernel
    variable = trapped_3
    mobile_concentration = deuterium_concentration_W
    alpha_t = '${trapping_prefactor_3}'
    trapping_energy = '${trapping_energy_3}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function_3'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_3}
  []
  [release_3]
    type = ReleasingNodalKernel
    variable = trapped_3
    alpha_r = '${detrapping_prefactor_3}'
    detrapping_energy = '${detrapping_energy_3}'
    temperature = 'temperature'
  []
[]

[Functions]
  [trap_distribution_function_3]
    type = ParsedFunction
    expression = '${trapping_site_fraction_3} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
[]

[Materials]
  [trap_distribution_function_3]
    type = GenericFunctionMaterial
    prop_names = trap_distribution_function_3
    prop_values = trap_distribution_function_3
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
    scaling_factor = '${fparse ${trap_per_free_3} * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_3
  []
[]

