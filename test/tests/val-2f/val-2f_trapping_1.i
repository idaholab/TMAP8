[Variables]
  [trapped_1]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  [trapped_1_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_1
    bound_type = lower
    bound_value = '${fparse -1e-20}'
  []
[]

[Kernels]
  # trapping 1 kernel
  [coupled_time_trap_1]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_concentration_W
    v = trapped_1
    coef = ${trap_per_free_1}
  []
[]

[NodalKernels]
  # First traps
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    mobile_concentration = deuterium_concentration_W
    alpha_t = '${trapping_prefactor_1}'
    trapping_energy = '${trapping_energy_1}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function_1'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_1}
  []
  [release_1]
    type = ReleasingNodalKernel
    variable = trapped_1
    alpha_r = '${detrapping_prefactor_1}'
    detrapping_energy = '${detrapping_energy_1}'
    temperature = 'temperature'
  []
[]

[Functions]
  [trap_distribution_function_1]
    type = ParsedFunction
    expression = '${trapping_site_fraction_1} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  # [max_dt_size_function_coarse]
  #   type = ParsedFunction
  #   expression = 'if(t<${fparse 3700}, ${fparse 1e1},
  #                 if(t<${fparse 3900}, ${fparse 1e0},
  #                 if(t<${fparse 6400}, ${fparse 1e1},
  #                 if(t<${fparse 7400}, ${fparse 1e0},
  #                 if(t<${fparse 10000}, ${fparse 1e1},
  #                 if(t<${fparse 1e5-1e4}, ${fparse 1e2},
  #                 if(t<${fparse 1e5+1e4}, ${fparse 5},
  #                 if(t<${fparse charge_time + cooldown_duration + 4500}, ${fparse 1e2},
  #                 if(t<${fparse 308500}, ${fparse 1e0},
  #                 if(t<${endtime}, ${fparse 2e2}, ${fparse 1e2}))))))))))'
  # []
[]

[Materials]
  [trap_distribution_function_1]
    type = GenericFunctionMaterial
    prop_names = trap_distribution_function_1
    prop_values = trap_distribution_function_1
  []
[]

[Postprocessors]
  [integral_trapped_concentration_1]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_1
  []
  [scaled_trapped_deuterium_1]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${trap_per_free_1} * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_1
  []
[]

