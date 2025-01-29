cl = 1
N = 2
epsilon_1 = 100 # K
epsilon_2 = 500 # K
epsilon_3 = 800 # K
temperature = 1000 # K
nx_num = 2 # (-)
trapping_site_fraction_1 = 0.33 # (-)
trapping_site_fraction_2 = 0.33 # (-)
trapping_site_fraction_3 = 0.33 # (-)
trapping_rate_coefficient = 2
release_rate_coefficient = 2
alphar = ${release_rate_coefficient}
alphat = ${trapping_rate_coefficient}
frac1 = ${trapping_site_fraction_1}
frac2 = ${trapping_site_fraction_2}
frac3 = ${trapping_site_fraction_3}

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${nx_num}
  xmax = 1
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  [mobile]
  []
  [trapped_1]
  []
  [trapped_2]
  []
  [trapped_3]
  []
[]

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
  [diff]
    type = Diffusion
    variable = mobile
    extra_vector_tags = ref
  []
  [time]
    type = TimeDerivative
    variable = mobile
    extra_vector_tags = ref
  []
  [forcing]
    type = BodyForce
    variable = mobile
    function = 'forcing_u'
  []
  [coupled_time_1]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_1
    extra_vector_tags = ref
  []
  [coupled_time_2]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_2
    extra_vector_tags = ref
  []
  [coupled_time_3]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_3
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  # For first traps
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_1}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [forcing_1]
    type = UserForcingFunctionNodalKernel
    variable = trapped_1
    function = forcing_t1
  []
  [release_1]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_1}'
    variable = trapped_1
  []
  # For second traps
  [time_2]
    type = TimeDerivativeNodalKernel
    variable = trapped_2
  []
  [trapping_2]
    type = TrappingNodalKernel
    variable = trapped_2
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_2}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_2]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_2}'
    variable = trapped_2
  []
  [forcing_2]
    type = UserForcingFunctionNodalKernel
    variable = trapped_2
    function = forcing_t2
  []
  # For third traps
  [time_3]
    type = TimeDerivativeNodalKernel
    variable = trapped_3
  []
  [trapping_3]
    type = TrappingNodalKernel
    variable = trapped_3
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_3}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_3]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_3}'
    variable = trapped_3
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

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  end_time = 1
  # dtmax = ${time_interval_max}
  solve_type = NEWTON
  scheme = implicit-euler
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = 'none'
  num_steps = 1000
  dt = 0.1
[]

[Outputs]
  csv = true
  exodus = true
[]
