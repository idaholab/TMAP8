temperature=2.373e3
initial_pressure=1e6
kb=1.38e-23
length_unit=1e6 # number of length units in a meter
pressure_unit=1 # number of pressure units in a Pascal

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 10
  xmax = ${fparse 3.3e-5 * length_unit}
[]

[Kernels]
  [diff]
    type = MatDiffusion
    variable = u
    diffusivity = ${fparse 1.58e-4*exp(-308000/(8.314*temperature))*length_unit^2}
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]

[ScalarKernels]
  [time]
    type = ODETimeDerivative
    variable = v
  []
  [flux_sink]
    type = EnclosureSinkScalarKernel
    variable = v
    flux = scale_flux
    surface_area = ${fparse 2.16e-6*length_unit^2}
    volume = ${fparse 5.2e-11*length_unit^3}
    concentration_to_pressure_conversion_factor = ${fparse kb*length_unit^3*temperature*pressure_unit}
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
    enclosure_scalar_var = v
    boundary = 'left'
    K = ${fparse 7.244e22/(temperature * length_unit^3 * pressure_unit)}
    temp = ${temperature}
  []
[]

[Variables]
  [u]
  []
  [v]
    family = SCALAR
    order = FIRST
    initial_condition = ${fparse initial_pressure*pressure_unit}
  []
[]

[Postprocessors]
  [flux]
    type = SideFluxIntegral
    variable = u
    diffusivity = ${fparse 1.58e-4*exp(-308000/(8.314*temperature))*length_unit^2}
    boundary = 'left'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = ''
  []
  [scale_flux]
    type = ScalePostprocessor
    scaling_factor = -1
    value = flux
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [rhs_timestep]
    type = PressureReleaseFluxIntegral
    variable = u
    boundary = 'right'
    diffusivity = ${fparse 1.58e-4*exp(-308000/(8.314*temperature))*length_unit^2}
    surface_area = ${fparse 2.16e-6*length_unit^2}
    volume = ${fparse 5.2e-11*length_unit^3}
    concentration_to_pressure_conversion_factor = ${fparse kb*length_unit^3*temperature*pressure_unit}
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
