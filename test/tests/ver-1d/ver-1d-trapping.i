# Verification Problem #1d from TMAP4/TMAP7 V&V document
# Permeation Problem with Trapping in Trapping-limited Case
# No Soret effect, or solubility included.

# Modeling parameters
node_num = 1000
thickness = '${units 1 m}'
end_time = '${units 1000 s}'
time_scaling = 1
temperature = '${units 1000 K}'
diffusivity = '${fparse ${units 1 m^2/s} / time_scaling}'

# Trapping parameters
cl = '${units 3.1622e18 at/m^3}'
N = '${units 3.1622e22 at/m^3}'
trapping_prefactor = '${fparse ${units 1e15 1/s} / time_scaling}'
release_prefactor = '${fparse ${units 1e13 1/s} / time_scaling}'
epsilon=${units 10000 K}
trapping_fraction = 0.1 # -
trap_per_free = 1e3

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${node_num}
  xmax = ${thickness}
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
    Ct0 = ${trapping_fraction}
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
    diffusivity = ${diffusivity}
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
    alpha_t = ${trapping_prefactor}
    N = '${fparse N / cl}'
    Ct0 = ${trapping_fraction}
    mobile_concentration = 'mobile'
    temperature = ${temperature}
    trap_per_free = ${trap_per_free}
    extra_vector_tags = ref
  []
  [release]
    type = ReleasingNodalKernel
    alpha_r = ${release_prefactor}
    temperature = ${temperature}
    detrapping_energy = ${epsilon}
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
    expression = '${fparse cl / cl}*tanh( 3 * t )'
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
  end_time = ${end_time}
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
