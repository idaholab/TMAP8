[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  xmax = 99e-6
[]

[Variables]
  [u]
  []
[]

[Functions]
  [diffusivity_value]
    type = ParsedFunction
    value = 'if(x<33e-6, 1.274e-7, 2.622e-11)'
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
# [VectorPostprocessors]
#   [line]
#     type = LineValueSampler
#     start_point = '0 0 0'
#     end_point = '99e-6 0 0'
#     num_points = 199
#     sort_by = 'x'
#     variable = u
#   []
# []

[Postprocessors]
  [conc_point1]
    type = PointValue
    variable = u
    point = '48.75e-6 0 0'
  []
[]

[Executioner]
  type = Transient
  # end_time = 5000 # for obtaining steady-state solution
  # dtmax = 2.0 # for obtaining steady-state solution
  end_time = 50
  dtmax = 0.2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  scheme = 'crank-nicolson'
  nl_rel_tol = 1e-9
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 4
  []
[]

[Outputs]
  exodus = true
  [csv]
    # interval = 10 # can be used while obtaining steady-state solution
    type = CSV
  []
  perf_graph = true
[]
