[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  xmax = 100
[]

[Variables]
  [./u]
  [../]
[]

[ICs]
  [function]
    type = FunctionIC
    variable = u
    function = 'if(x<10,1,0)'
  []
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

[Postprocessors]
  [point0]
    type = PointValue
    variable = u
    point = '0 0 0'
  []
  [point10]
    type = PointValue
    variable = u
    point = '10 0 0'
  []
  [point12]
    type = PointValue
    variable = u
    point = '12 0 0'
  []
[]

[Executioner]
  type = Transient
  end_time = 100
  dt = .05
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  l_tol = 1e-8
  # scheme = 'crank-nicolson'
  timestep_tolerance = 1e-8
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
  []
  perf_graph = true
[]
