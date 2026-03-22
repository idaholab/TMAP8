# This include replaces the original two-trap baseline with the six trap families
# used in val-2f. The val-2f site densities are scaled uniformly so the initial
# areal inventory matches the current val-2k preloaded natural-oxide inventory.

[Variables]
  [deuterium_trapped_intrinsic]
    order = FIRST
    family = LAGRANGE
  []
  [deuterium_trapped_1]
    order = FIRST
    family = LAGRANGE
  []
  [deuterium_trapped_2]
    order = FIRST
    family = LAGRANGE
  []
  [deuterium_trapped_3]
    order = FIRST
    family = LAGRANGE
  []
  [deuterium_trapped_4]
    order = FIRST
    family = LAGRANGE
  []
  [deuterium_trapped_5]
    order = FIRST
    family = LAGRANGE
  []
[]

[ICs]
  [deuterium_trapped_intrinsic_ic]
    type = FunctionIC
    variable = deuterium_trapped_intrinsic
    function = '${fparse trapping_site_fraction_intrinsic * tungsten_density / trap_per_free_intrinsic}'
  []
  [deuterium_trapped_1_ic]
    type = FunctionIC
    variable = deuterium_trapped_1
    function = '${fparse trapping_site_fraction_1 * tungsten_density / trap_per_free_1} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [deuterium_trapped_2_ic]
    type = FunctionIC
    variable = deuterium_trapped_2
    function = '${fparse trapping_site_fraction_2 * tungsten_density / trap_per_free_2} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [deuterium_trapped_3_ic]
    type = FunctionIC
    variable = deuterium_trapped_3
    function = '${fparse trapping_site_fraction_3 * tungsten_density / trap_per_free_3} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [deuterium_trapped_4_ic]
    type = FunctionIC
    variable = deuterium_trapped_4
    function = '${fparse trapping_site_fraction_4 * tungsten_density / trap_per_free_4} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [deuterium_trapped_5_ic]
    type = FunctionIC
    variable = deuterium_trapped_5
    function = '${fparse trapping_site_fraction_5 * tungsten_density / trap_per_free_5} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
[]

[Functions]
  [trap_intrinsic_sites_function]
    type = ParsedFunction
    expression = '${trapping_site_fraction_intrinsic}'
  []
  [trap_1_sites_function]
    type = ParsedFunction
    expression = '${trapping_site_fraction_1} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [trap_2_sites_function]
    type = ParsedFunction
    expression = '${trapping_site_fraction_2} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [trap_3_sites_function]
    type = ParsedFunction
    expression = '${trapping_site_fraction_3} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [trap_4_sites_function]
    type = ParsedFunction
    expression = '${trapping_site_fraction_4} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
  [trap_5_sites_function]
    type = ParsedFunction
    expression = '${trapping_site_fraction_5} / (1 + exp((x - ${depth_center}) / ${depth_width}))'
  []
[]

[Kernels]
  [mobile_coupled_deuterium_trapped_intrinsic]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = deuterium_trapped_intrinsic
    coef = ${trap_per_free_intrinsic}
  []
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
  [mobile_coupled_deuterium_trapped_3]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = deuterium_trapped_3
    coef = ${trap_per_free_3}
  []
  [mobile_coupled_deuterium_trapped_4]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = deuterium_trapped_4
    coef = ${trap_per_free_4}
  []
  [mobile_coupled_deuterium_trapped_5]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_mobile
    v = deuterium_trapped_5
    coef = ${trap_per_free_5}
  []
[]

[NodalKernels]
  [time_deuterium_trapped_intrinsic]
    type = TimeDerivativeNodalKernel
    variable = deuterium_trapped_intrinsic
  []
  [trapping_deuterium_intrinsic]
    type = TrappingNodalKernel
    variable = deuterium_trapped_intrinsic
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_intrinsic_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_intrinsic}
  []
  [release_deuterium_intrinsic]
    type = ReleasingNodalKernel
    variable = deuterium_trapped_intrinsic
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_intrinsic}'
    temperature = temperature
  []
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
  [time_deuterium_trapped_3]
    type = TimeDerivativeNodalKernel
    variable = deuterium_trapped_3
  []
  [trapping_deuterium_3]
    type = TrappingNodalKernel
    variable = deuterium_trapped_3
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_3_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_3}
  []
  [release_deuterium_3]
    type = ReleasingNodalKernel
    variable = deuterium_trapped_3
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_3}'
    temperature = temperature
  []
  [time_deuterium_trapped_4]
    type = TimeDerivativeNodalKernel
    variable = deuterium_trapped_4
  []
  [trapping_deuterium_4]
    type = TrappingNodalKernel
    variable = deuterium_trapped_4
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_4_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_4}
  []
  [release_deuterium_4]
    type = ReleasingNodalKernel
    variable = deuterium_trapped_4
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_4}'
    temperature = temperature
  []
  [time_deuterium_trapped_5]
    type = TimeDerivativeNodalKernel
    variable = deuterium_trapped_5
  []
  [trapping_deuterium_5]
    type = TrappingNodalKernel
    variable = deuterium_trapped_5
    mobile_concentration = deuterium_mobile
    alpha_t = '${trapping_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = trap_5_sites_function
    temperature = temperature
    trap_per_free = ${trap_per_free_5}
  []
  [release_deuterium_5]
    type = ReleasingNodalKernel
    variable = deuterium_trapped_5
    alpha_r = '${detrapping_prefactor}'
    detrapping_energy = '${detrapping_energy_5}'
    temperature = temperature
  []
[]

[Postprocessors]
  [integral_deuterium_trapped_intrinsic]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_intrinsic
    outputs = none
  []
  [scaled_deuterium_trapped_intrinsic]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_intrinsic * ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_trapped_intrinsic
  []
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
  [integral_deuterium_trapped_3]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_3
    outputs = none
  []
  [scaled_deuterium_trapped_3]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_3 * ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_trapped_3
  []
  [integral_deuterium_trapped_4]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_4
    outputs = none
  []
  [scaled_deuterium_trapped_4]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_4 * ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_trapped_4
  []
  [integral_deuterium_trapped_5]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_trapped_5
    outputs = none
  []
  [scaled_deuterium_trapped_5]
    type = ScalePostprocessor
    scaling_factor = '${fparse trap_per_free_5 * ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_trapped_5
  []
[]
