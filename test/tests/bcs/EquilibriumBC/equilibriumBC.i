# Simple test to ensure that EquilibriumBC's enclosure_var can take in a field variable

[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Variables]
  [u]
  []
[]

[AuxVariables]
  [v]
    initial_condition = 1
  []
[]

[Kernels]
  [diff]
    type = MatDiffusion
    variable = u
    diffusivity = 1
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]

[BCs]
  [right]
    type = DirichletBC
    value = 0
    variable = u
    boundary = 'right'
  []
  [left]
    type = EquilibriumBC
    variable = u
    enclosure_var = v
    boundary = 'left'
    Ko = 1
    temperature = 1
  []
[]

[Postprocessors]
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = u
    diffusivity = 1
    boundary = 'left'
    execute_on = 'initial nonlinear linear timestep_end'
  []
[]

[Executioner]
  type = Transient
  dt = .1
  num_steps = 1
  solve_type = PJFNK
  automatic_scaling = true
  dtmin = .1
  l_max_its = 30
  nl_max_its = 5
  petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
  scheme = 'bdf2'
  timestep_tolerance = 1e-8
[]

[Outputs]
  file_base = equilibriumBC_out
  perf_graph = true
  [csv]
    type = CSV
    execute_on = 'initial timestep_end'
  []
[]
