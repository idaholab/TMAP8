# This input file adds the trapping sites 4 for validation case val-2f.
# It is included in val-2f.i

[Variables]
  [trapped_4]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  # trapping 4 kernel
  [coupled_time_trap_4]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_concentration_W
    v = trapped_4
    coef = ${trap_per_free_4}
  []
[]

[NodalKernels]
  [time_4]
    type = TimeDerivativeNodalKernel
    variable = trapped_4
  []
  [trapping_4]
    type = TrappingNodalKernel
    variable = trapped_4
    mobile_concentration = deuterium_concentration_W
    alpha_t = '${trapping_prefactor_4}'
    trapping_energy = '${trapping_energy_4}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function_4'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_4}
  []
  [release_4]
    type = ReleasingNodalKernel
    variable = trapped_4
    alpha_r = '${detrapping_prefactor_4}'
    detrapping_energy = '${detrapping_energy_4}'
    temperature = 'temperature'
  []
[]

[Functions]
  [trap_distribution_function_4]
    type = ParsedFunction
    expression = '${trapping_site_fraction_4} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [trap_distribution_function_4_inf]
    type = ParsedFunction
    expression = '${trapping_site_fraction_4_inf} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
[]

[Materials]
  [trap_distribution_function_4]
    type = GenericFunctionMaterial
    prop_names = trap_distribution_function_4
    prop_values = trap_distribution_function_4
  []
[]

[Postprocessors]
  [integral_trapped_concentration_4]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_4
    outputs = none
  []
  [scaled_trapped_deuterium_4]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${trap_per_free_4} * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_4
  []
[]
