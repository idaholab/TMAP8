cl = 3.1622e18
trap_per_free = 1e3
N = 3.1622e22
time_scaling = 1
temperature = 1000

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
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
  [trapped]
  []
[]

[AuxVariables]
  [empty_sites]
  []
  [scaled_empty_sites]
  []
  [trapped_sites]
  []
  [total_sites]
  []
[]

[AuxKernels]
  [empty_sites]
    variable = empty_sites
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = .1
    trap_per_free = ${trap_per_free}
    trapped_concentration_variables = trapped
  []
  [scaled_empty]
    variable = scaled_empty_sites
    type = NormalizationAux
    normal_factor = ${cl}
    source_variable = empty_sites
  []
  [trapped_sites]
    variable = trapped_sites
    type = NormalizationAux
    normal_factor = ${trap_per_free}
    source_variable = trapped
  []
  [total_sites]
    variable = total_sites
    type = ParsedAux
    expression = 'trapped_sites + empty_sites'
    coupled_variables = 'trapped_sites empty_sites'
  []
[]

[Kernels]
  [diff]
    type = MatDiffusion
    variable = mobile
    diffusivity = '${fparse 1. / time_scaling}'
    extra_vector_tags = ref
  []
  [time]
    type = TimeDerivative
    variable = mobile
    extra_vector_tags = ref
  []
  [coupled_time]
    type = ScaledCoupledTimeDerivative
    variable = mobile
    v = trapped
    factor = ${trap_per_free}
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  [time]
    type = TimeDerivativeNodalKernel
    variable = trapped
  []
  [trapping]
    type = TrappingNodalKernel
    variable = trapped
    alpha_t = '${fparse 1e15 / time_scaling}'
    N = '${fparse 3.1622e22 / cl}'
    Ct0 = 0.1
    mobile_concentration = 'mobile'
    temperature = ${temperature}
    trap_per_free = ${trap_per_free}
    extra_vector_tags = ref
  []
  [release]
    type = ReleasingNodalKernel
    alpha_r = ${fparse 1e13 / time_scaling}
    temperature = ${temperature}
    variable = trapped
  []
[]

[BCs]
  [left]
    type = FunctionDirichletBC
    variable = mobile
    function = 'BC_func'
    boundary = left
  []
  [right]
    type = DirichletBC
    variable = mobile
    value = 0
    boundary = right
  []
[]
[Functions]
  [BC_func]
    type = ParsedFunction
    expression = '${fparse 3.1622e18 / cl}*tanh( 3 * t )'
  []
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'right'
    diffusivity = 1
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${cl}
  []
  [nonlin_it]
    type = NumNonlinearIterations
  []
  [dt]
    type = TimestepSize
  []
  [min_trapped]
    type = NodalExtremeValue
    value_type = MIN
    variable = trapped
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
  end_time = 1000
  dtmax = 5
  solve_type = NEWTON
  scheme = BDF2
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = 'none'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    optimal_iterations = 9
    growth_factor = 1.1
    cutback_factor = 0.909
  []
[]

[Outputs]
  exodus = true
  csv = true
  [dof]
    type = DOFMap
    execute_on = initial
  []
  perf_graph = true
[]
