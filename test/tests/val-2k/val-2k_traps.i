[Variables]
  [trapped_1]
    order = FIRST
    family = LAGRANGE
    outputs = none
  []
  [trapped_2]
    order = FIRST
    family = LAGRANGE
    outputs = none
  []
[]

[ICs]
  [trapped_1_ic]
    type = FunctionIC
    variable = trapped_1
    function = 'if(x <= ${damage_depth}, ${fparse initial_trapped_fraction_1 * tungsten_density / trap_per_free_1}, 0)'
  []
  [trapped_2_ic]
    type = FunctionIC
    variable = trapped_2
    function = 'if(x <= ${damage_depth}, ${fparse initial_trapped_fraction_2 * tungsten_density / trap_per_free_2}, 0)'
  []
[]

[Functions]
  [trap_1_sites_function]
    type = ParsedFunction
    expression = 'if(x <= ${damage_depth}, ${trap_site_fraction_1}, 0)'
  []
  [trap_2_sites_function]
    type = ParsedFunction
    expression = 'if(x <= ${damage_depth}, ${trap_site_fraction_2}, 0)'
  []
[]

[Kernels]
  [mobile_coupled_trapped_1]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = trapped_1
    coef = ${trap_per_free_1}
  []
  [mobile_coupled_trapped_2]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = trapped_2
    coef = ${trap_per_free_2}
  []
[]

[NodalKernels]
  [time_trapped_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_1_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_1}
  []
  [release_1]
    type = ReleasingNodalKernel
    variable = trapped_1
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_1}'
    temperature = temperature
  []
  [time_trapped_2]
    type = TimeDerivativeNodalKernel
    variable = trapped_2
  []
  [trapping_2]
    type = TrappingNodalKernel
    variable = trapped_2
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_2_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_2}
  []
  [release_2]
    type = ReleasingNodalKernel
    variable = trapped_2
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_2}'
    temperature = temperature
  []
[]

[Postprocessors]
  [integral_trapped_1]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_1
    outputs = none
  []
  [scaled_trapped_1]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_1 * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_1
  []
  [integral_trapped_2]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_2
    outputs = none
  []
  [scaled_trapped_2]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_2 * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_2
  []
[]
