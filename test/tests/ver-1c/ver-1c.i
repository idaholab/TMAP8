# Locations for concentration comparison
# TMAP7 - 12, 0.25, h (10)
# TMAP4 - 12, 0,    h (10)
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1e4
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
    function = 'if(x<10.0,1,0)'
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
  [point0.25]
    type = PointValue
    variable = u
    point = '0.25 0 0'
  []
  [point10]
    type = PointValue
    variable = u
    point = '10.0 0 0'
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
  solve_type = NEWTON
  scheme = bdf2
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_tol = 1e-9
  timestep_tolerance = 1e-8
  dtmax = 2
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.001
    growth_factor = 1.25
    cutback_factor = 0.8
    optimal_iterations = 4
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
  []
  perf_graph = true
[]
