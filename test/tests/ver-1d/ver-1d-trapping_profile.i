# This input file is slightly adapted from ver-1d-trapping.i to include a spatially-dependent trap site density

cl=3.1622e18
trap_per_free=1e3
N=3.1622e22
time_scaling=1
epsilon=10000
temperature = 1000
Ct0_surface = .1 # trapping site density close to the sample surface
Ct0_bulk = .01 # trapping site density in the sample bulk
trap_profile_depth = 0.2 # position of the transition from Ct0_surface to Ct0_bulk

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 20
  xmax = 1
[]

[Functions]
  [trapping_sites_density_function]
    type = ParsedFunction
    expression = 'if(x<${trap_profile_depth}, ${Ct0_surface}, ${Ct0_bulk})'
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  [mobile][]
  [trapped][]
[]

[AuxVariables]
  [empty_sites][]
  [scaled_empty_sites][]
  [trapped_sites][]
  [total_sites][]
[]

[AuxKernels]
  [empty_sites]
    variable = empty_sites
    type = EmptySitesAux
    N = ${fparse N / cl}
    Ct0 = trapping_sites_density_function
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
  [./diff]
    type = MatDiffusion
    variable = mobile
    diffusivity = ${fparse 1. / time_scaling}
    extra_vector_tags = ref
  [../]
  [./time]
    type = TimeDerivative
    variable = mobile
    extra_vector_tags = ref
  [../]
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
    alpha_t = ${fparse 1e15 / time_scaling}
    N = ${fparse 3.1622e22 / cl}
    Ct0 = trapping_sites_density_function
    mobile_concentration = 'mobile'
    temperature = ${temperature}
    trap_per_free = ${trap_per_free}
    extra_vector_tags = ref
  []
  [release]
    type = ReleasingNodalKernel
    alpha_r = ${fparse 1e13 / time_scaling}
    temperature = ${temperature}
    detrapping_energy = ${epsilon}
    variable = trapped
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = mobile
    value = ${fparse 3.1622e18 / cl}
    boundary = left
  []
  [right]
    type = DirichletBC
    variable = mobile
    value = 0
    boundary = right
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
  dt = 1
  solve_type = NEWTON
  line_search = 'none'
  automatic_scaling = true
  verbose = true
  compute_scaling_once = false
  l_tol = 1e-11
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
