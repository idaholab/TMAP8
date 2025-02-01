# This is the input file to apply the method of manufactured solution to the ver-1dc case.
# It leverages ver-1dc_base.i and functions.i to form a complete input file.

cl = ${units 1 atom/m^3}
N = ${units 2 atom/m^3}
nx_num = 2 # (-)
trapping_rate_coefficient = ${units 2 1/s}
release_rate_coefficient = ${units 2 1/s}
alphar = ${release_rate_coefficient}
alphat = ${trapping_rate_coefficient}
frac1 = ${trapping_site_fraction_1}
frac2 = ${trapping_site_fraction_2}
frac3 = ${trapping_site_fraction_3}
simulation_time = ${units 1 s}
time_interval_max = ${units 1 s}
time_step = ${units 0.1 s}

scheme = implicit-euler

!include ver-1dc_base.i

[ICs]
  [mobile]
    type = FunctionIC
    variable = mobile
    function = exact_u
  []
  [t1]
    type = FunctionIC
    variable = trapped_1
    function = exact_t1
  []
  [t2]
    type = FunctionIC
    variable = trapped_2
    function = exact_t2
  []
  [t3]
    type = FunctionIC
    variable = trapped_3
    function = exact_t3
  []
[]

[Kernels]

  [forcing]
    type = BodyForce
    variable = mobile
    function = 'forcing_u'
  []
[]

[NodalKernels]
  [forcing_1]
    type = UserForcingFunctionNodalKernel
    variable = trapped_1
    function = forcing_t1
  []
  [forcing_2]
    type = UserForcingFunctionNodalKernel
    variable = trapped_2
    function = forcing_t2
  []
  [forcing_3]
    type = UserForcingFunctionNodalKernel
    variable = trapped_3
    function = forcing_t3
  []
[]

[BCs]
  [dirichlet]
    type = FunctionDirichletBC
    variable = mobile
    function = 'exact_u'
    boundary = 'left right'
  []
[]

[Functions]
!include functions.i
[]

[Postprocessors]
  [h]
    type = AverageElementSize
  []
  [L2u]
    type = ElementL2Error
    variable = mobile
    function = exact_u
  []
[]

[Executioner]
  num_steps = 1000
  dt = ${time_step}
[]

[Outputs]
  csv = true
  exodus = true
[]
