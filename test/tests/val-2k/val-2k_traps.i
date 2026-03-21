# This include adds the two occupied trap populations used in the val-2k
# natural-oxide baseline. It localizes trapping to the self-damaged near-surface
# tungsten layer and provides the initial trapped deuterium inventory for stage 1.

[Variables]
  [deuterium_trapped_1]
    order = FIRST
    family = LAGRANGE
  []
  [deuterium_trapped_2]
    order = FIRST
    family = LAGRANGE
  []
[]

[ICs]
  [deuterium_trapped_1_ic]
    type = FunctionIC
    variable = deuterium_trapped_1
    function = 'if(x <= ${damage_depth}, ${fparse initial_trapped_fraction_1 * tungsten_density / trap_per_free_1}, 0)'
  []
  [deuterium_trapped_2_ic]
    type = FunctionIC
    variable = deuterium_trapped_2
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
  [mobile_coupled_deuterium_trapped_1]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = deuterium_trapped_1
    coef = ${trap_per_free_1}
  []
  [mobile_coupled_deuterium_trapped_2]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = deuterium_trapped_2
    coef = ${trap_per_free_2}
  []
[]

[NodalKernels]
  [time_deuterium_trapped_1]
    type = TimeDerivativeNodalKernel
    variable = deuterium_trapped_1
  []
  [trapping_deuterium_1]
    type = TrappingNodalKernel
    variable = deuterium_trapped_1
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_1_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_1}
  []
  [release_deuterium_1]
    type = ReleasingNodalKernel
    variable = deuterium_trapped_1
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_1}'
    temperature = temperature
  []
  [time_deuterium_trapped_2]
    type = TimeDerivativeNodalKernel
    variable = deuterium_trapped_2
  []
  [trapping_deuterium_2]
    type = TrappingNodalKernel
    variable = deuterium_trapped_2
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_2_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_2}
  []
  [release_deuterium_2]
    type = ReleasingNodalKernel
    variable = deuterium_trapped_2
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_2}'
    temperature = temperature
  []
[]

[Postprocessors]
  [integral_deuterium_trapped_1]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_1
    outputs = none
  []
  [scaled_deuterium_trapped_1]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_1 * ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_trapped_1
  []
  [integral_deuterium_trapped_2]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_2
    outputs = none
  []
  [scaled_deuterium_trapped_2]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_2 * ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_trapped_2
  []
[]
