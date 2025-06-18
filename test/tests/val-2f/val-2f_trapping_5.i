# This input file adds the trapping sites 5 for validation case val-2f.
# It is included in val-2f.i

[Variables]
  [trapped_5]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  # trapping 5 kernel
  [coupled_time_trap_5]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_concentration_W
    v = trapped_5
    coef = ${trap_per_free_5}
  []
[]

[NodalKernels]
  [time_5]
    type = TimeDerivativeNodalKernel
    variable = trapped_5
  []
  [trapping_5]
    type = TrappingNodalKernel
    variable = trapped_5
    mobile_concentration = deuterium_concentration_W
    alpha_t = '${trapping_prefactor_5}'
    trapping_energy = '${trapping_energy_5}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function_5'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_5}
  []
  [release_5]
    type = ReleasingNodalKernel
    variable = trapped_5
    alpha_r = '${detrapping_prefactor_5}'
    detrapping_energy = '${detrapping_energy_5}'
    temperature = 'temperature'
  []
[]

[Functions]
  [trap_distribution_function_5]
    type = ParsedFunction
    expression = '${trapping_site_fraction_5} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  # [trap_distribution_function_5_inf]
  #   type = ParsedFunction
  #   expression = '${trapping_site_fraction_5_inf} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  # []
[]

[Materials]
  [trap_distribution_function_5]
    type = GenericFunctionMaterial
    prop_names = trap_distribution_function_5
    prop_values = trap_distribution_function_5
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
    scaling_factor = '${fparse ${trap_per_free_5} * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_5
  []
[]
