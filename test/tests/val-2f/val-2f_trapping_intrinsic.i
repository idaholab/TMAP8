# This input file adds the intrinsic trapping sites for validation case val-2f. 
# It is included in val-2f.i

[Variables]
  [trapped_intrinsic]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  [trapped_intrinsic_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_intrinsic
    bound_type = lower
    bound_value = '${fparse -1e-20}'
  []
[]

[Kernels]
  # trapping intrinsic kernel
  [coupled_time_trap_intrinsic]
    type = ADCoefCoupledTimeDerivative
    variable = deuterium_concentration_W
    v = trapped_intrinsic
    coef = ${trap_per_free_intrinsic}
  []
[]

[NodalKernels]
  [time_intrinsic]
    type = TimeDerivativeNodalKernel
    variable = trapped_intrinsic
  []
  [trapping_intrinsic]
    type = TrappingNodalKernel
    variable = trapped_intrinsic
    mobile_concentration = deuterium_concentration_W
    alpha_t = '${trapping_prefactor_intrinsic}'
    trapping_energy = '${trapping_energy_intrinsic}'
    N = '${tungsten_density}'
    Ct0 = '${trapping_site_fraction_intrinsic}'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_intrinsic}
  []
  [release_intrinsic]
    type = ReleasingNodalKernel
    variable = trapped_intrinsic
    alpha_r = '${detrapping_prefactor_intrinsic}'
    detrapping_energy = '${detrapping_energy_intrinsic}'
    temperature = 'temperature'
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
    scaling_factor = '${fparse ${trap_per_free_intrinsic} * ${units 1 m^2 -> mum^2}}'
    value = integral_trapped_concentration_intrinsic
  []
[]

