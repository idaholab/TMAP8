top_level_temperature=2.373e3
initial_pressure=1e6
kb=1.38e-23
top_level_length_unit=1e6 # number of length units in a meter
pressure_unit=1 # number of pressure units in a Pascal

[Problem]
  error_on_jacobian_nonzero_reallocation = false
[]

[GlobalParams]
  species = 'u'
  length_unit = ${top_level_length_unit}
  temperature = ${top_level_temperature}
[]

[Functions]
  [D_u]
    type = ParsedFunction
    value = '1.58e-4*exp(-308000/(8.314*temperature))'
    vars = 'temperature'
    vals = '${top_level_temperature}'
  []
  [K_u]
    type = ParsedFunction
    value = '7.244e22/temperature'
    vars = 'temperature'
    vals = '${top_level_temperature}'
  []
[]

[Components]
  [structure]
    type = Structure1D
    diffusivities = 'D_u'
    nx = 10
    xmax = 3.3e-5
  []

  [enc]
    type = FunctionalEnclosure0D
    species_initial_pressures = '${initial_pressure}'
    pressure_unit = ${pressure_unit}
    surface_area = 2.16e-6
    volume = 5.2e-11
    equilibrium_constants = 'K_u'
    structure = 'structure'
    boundary = 'left'
  []
[]

[BCs]
  [right]
    type = DirichletBC
    value = 0
    variable = u
    boundary = 'structure_right'
  []
[]

[Postprocessors]
  [rhs_timestep]
    type = PressureReleaseFluxIntegral
    variable = u
    boundary = 'structure_right'
    diffusivity = ${fparse 1.58e-4*exp(-308000/(8.314*top_level_temperature))*top_level_length_unit^2}
    surface_area = ${fparse 2.16e-6*top_level_length_unit^2}
    volume = ${fparse 5.2e-11*top_level_length_unit^3}
    concentration_to_pressure_conversion_factor = ${fparse kb*top_level_length_unit^3*top_level_temperature*pressure_unit}
    outputs = 'console'
  []
  [rhs_aggregate]
    type = CumulativeValuePostprocessor
    postprocessor = 'rhs_timestep'
    outputs = 'console'
  []
  [rhs_release]
    type = ScalePostprocessor
    value = rhs_aggregate
    scaling_factor = ${fparse 1./(initial_pressure*pressure_unit)}
    outputs = 'console csv exodus'
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
  dt = .1
  end_time = 140
  solve_type = PJFNK
  automatic_scaling = true
  dtmin = .1
  l_max_its = 30
  nl_max_its = 5
  petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
  scheme = 'crank-nicolson'
  timestep_tolerance = 1e-8
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  perf_graph = true
  [dof]
    type = DOFMap
    execute_on = 'initial'
  []
  [csv]
    type = CSV
    execute_on = 'initial timestep_end'
  []
[]
