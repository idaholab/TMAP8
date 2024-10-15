length_scale = '${units 1e6 num/m}'
# length = '${units ${fparse 5e-4 * length_scale} m}'
# nx_num = 100
Temperature = '${units 703 K}'
simulation_time = '${units 2e4 s}'
diffusivity_D = '${units ${fparse 3e-10 * length_scale^2} m^2/s}'
dissociation_parameter_enclos2 = '${units ${fparse 1.7918e15 / length_scale^2} at/m^2/s/Pa^0.5}' # d2/m^2/s/pa^0.5
recombination_parameter_enclos2 = '${units ${fparse 2e-31 * length_scale^4} m^4/at/s}'    # m^4/atom/s
pressure_high = '${units 4e-5 Pa}'
pressure_low =  '${units 9e-6 Pa}'
pressure_right = '${units 2e-6 Pa}'
flux_high = '${units ${fparse 4.9e19 / length_scale^2} atom/m^2/s}'
flux_low =  '${units ${fparse 0 / length_scale^2}      atom/m^2/s}'
dissociation_coefficient_parameter_enclos1 = '${units ${fparse 8.959e18 / length_scale^2} at/m^2/s/Pa^0.5}'  # d2/m^2/s/pa^0.5
# Data in TMAP4
recombination_coefficient_parameter_enclos1_TMAP4 = '${units ${fparse 1e-27 * length_scale^4} m^4/at/s}'    # m^4/atom/s
# Data in TMAP7
recombination_coefficient_parameter_enclos1_TMAP7 = '${units ${fparse 7e-27 * length_scale^4} m^4/at/s}'    # m^4/atom/s


[Variables]
  [concentration]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  [diffusion]
    type = ADMatDiffusion
    variable = concentration
    diffusivity = ${diffusivity_D}
  []
  [time_diffusion]
    type = ADTimeDerivative
    variable = concentration
  []
  [source]
    type = ADBodyForce
    variable = concentration
    function = concentration_source_func
  []
[]

[AuxVariables]
  [pressure_left]
  []
  [concentration_source]
  []
  [recombination_TMAP4]
  []
  [recombination_TMAP7]
  []
[]

[AuxKernels]
  [pressure_aux]
    type = FunctionAux
    variable = pressure_left
    function = pressure_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_source_aux]
    type = FunctionAux
    variable = concentration_source
    function = concentration_source_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [recombination_aux_TMAP4]
    type = FunctionAux
    variable = recombination_TMAP4
    function = '${recombination_coefficient_parameter_enclos1_TMAP4}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [recombination_aux_TMAP7]
    type = FunctionAux
    variable = recombination_TMAP7
    function = '${recombination_coefficient_parameter_enclos1_TMAP7}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[BCs]
  # [right_balance]
  #   type = ADFunctionNeumannBC
  #   boundary = right
  #   variable = concentration
  #   function = 0
  # []
  [right_balance]
    type = EquilibriumBC
    Ko = '${fparse sqrt( ${dissociation_parameter_enclos2} / ${recombination_parameter_enclos2} )}'
    boundary = right
    enclosure_var = ${pressure_right}
    temperature = ${Temperature}
    variable = concentration
    p = 0.5
  []
[]

[Postprocessors]
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = '${diffusivity_D}'
    boundary = 'left'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${length_scale}^2}'
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = '${diffusivity_D}'
    boundary = 'right'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${length_scale}^2}'
    value = flux_surface_right
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-7
  l_tol = 1e-4
  end_time = ${simulation_time}
  automatic_scaling = true
  line_search = 'none'
  dtmax = 100

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 4
    growth_factor = 1.1
    cutback_factor = 0.5
  []
[]

# [Debug]
#   show_var_residual_norms = true
# []
