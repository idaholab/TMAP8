[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 10000
  xmax = 200
[]

[Variables]
  [./u]
  [../]
[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
  [../]
  [./time]
    type = TimeDerivative
    variable = u
  [../]
[]

[BCs]
  [./left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 1
  [../]
  [./right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 0
  [../]
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '2 0 0'
    num_points = 41
    sort_by = 'x'
    variable = u
  []
[]

[Postprocessors]
  [point]
    type = PointValue
    variable = u
    point = '.2 0 0'
  []
[]

[Executioner]
  type = Transient
  end_time = 50
  dt = .1
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  l_tol = 1e-8
  scheme = 'crank-nicolson'
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    interval = 10
  []
  perf_graph = true
[]
