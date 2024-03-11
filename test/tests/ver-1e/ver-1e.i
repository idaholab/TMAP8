[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  xmax = 99e-6
  allow_renumbering = false
[]

[Variables]
  [u]
  []
[]

[Functions]
  [diffusivity_value]
    type = ParsedFunction
    expression = 'if(x<33e-6, 1.274e-7, 2.622e-11)'
  []
[]

[Kernels]
  [diff]
    type = FunctionDiffusion
    variable = u
    function = diffusivity_value
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 50.7079 # moles/m^3
  []
  [right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 0
  []
[]

# Used while obtaining steady-state solution
#
[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '99e-6 0 0'
    num_points = 1000
    sort_by = 'x'
    variable = u
    outputs = vector_postproc
  []
[]

# Used to obtain varying concentration with time at a
# point in SiC layer 15.75 micrometer away from the
# PyC-SiC interface

[Postprocessors]
  [conc_point1]
    type = PointValue
    variable = u
    point = '48.75e-6 0 0'
    outputs = 'csv'
  []
[]

[Executioner]
  type = Transient
  end_time = 5000
  dtmax = 2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  scheme = 'bdf2'
  nl_rel_tol = 1e-50 # Make this really tight so that our absolute tolerance criterion is the one
  # we must meet
  nl_abs_tol = 1e-12
  abort_on_solve_fail = true
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-4
    optimal_iterations = 4
    growth_factor = 1.25
    cutback_factor = 0.8
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
  []
  [vector_postproc]
    type = CSV
    sync_times = 5000
    sync_only = true
  []
[]
