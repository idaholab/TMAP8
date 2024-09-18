cl = 3.1622e18 # atom/m^3
nx_num = 100 # (-)
diffusivity = 1 # m^2/s
simulation_time = 3 # s
interval_time_min = 0.05 # s
interval_time = 0.05 # s

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
[]

[BCs]
  [left]
    type = DirichletBC
    variable = mobile
    value = '${fparse cl / cl}'
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
    diffusivity = ${diffusivity}
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
  end_time = ${simulation_time}
  dt = ${interval_time}
  dtmin = ${interval_time_min}
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  verbose = true
  compute_scaling_once = false
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
