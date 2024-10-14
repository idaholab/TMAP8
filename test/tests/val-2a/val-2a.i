length_scale = '${units 1e6 num/m}'
# length = '${units ${fparse 5e-4 * length_scale} m}'
# nx_num = 100
nx_scale = 1
Temperature = '${units 703 K}'
simulation_time = '${units 2e4 s}'
diffusivity_D = '${units ${fparse 3e-10 * length_scale^2} m^2/s}'
dissociation_parameter_enclos2 = '${units ${fparse 1.7918e15 / length_scale^2} at/m^2/s/Pa^0.5}' # d2/m^2/s/pa^0.5
recombination_parameter_enclos2 = '${units ${fparse 2e-31 * length_scale^4} m^4/at/s}'    # m^4/atom/s
pressure_right = '${units 2e-6 Pa}'
pressure_high = '${units 4e-5 Pa}'
pressure_low =  '${units 9e-6 Pa}'
flux_high = '${units ${fparse 4.9e19 / length_scale^2} atom/m^2/s}'
flux_low =  '${units ${fparse 0 / length_scale^2}      atom/m^2/s}'
dissociation_coefficient_parameter_enclos1 = '${units ${fparse 8.959e18 / length_scale^2} at/m^2/s/Pa^0.5}'  # d2/m^2/s/pa^0.5
# Data in TMAP7
recombination_coefficient_parameter_enclos1_TMAP7 = '${units ${fparse 7e-27 * length_scale^4} m^4/at/s}'    # m^4/atom/s
# Data in TMAP4
recombination_coefficient_parameter_enclos1_TMAP4 = '${units ${fparse 1e-27 * length_scale^4} m^4/at/s}'    # m^4/atom/s



[Mesh]
  active = 'cartesian_mesh_TMAP7'
  # [uniform_mesh]
  #   type = GeneratedMeshGenerator
  #   dim = 1
  #   nx = ${nx_num}
  #   xmax = ${length}
  # []
  [cartesian_mesh_TMAP4]
    type = CartesianMeshGenerator
    dim = 1
    #     num
    dx = '${fparse 5 * 4e-3}        1e-2        1e-1        1e0         1e1         ${fparse 10 * 4.88e1}'
    ix = '${fparse 5 * ${nx_scale}} ${nx_scale} ${nx_scale} ${nx_scale} ${nx_scale} ${fparse 10 * ${nx_scale}}'
  []
  [cartesian_mesh_TMAP7]
    type = CartesianMeshGenerator
    dim = 1

    # #     0    1    2    3    4    5    6    7    8    9    num
    # dx = '1e-3 4e-3 4e-3 4e-3 4e-3 4e-3 1e-2 1e-1 1e-0 1e1
    #       5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1  5.4319e1'
    # #     10        11        12        13        14        15        16        17        18

    #     num
    dx = '1e-3        ${fparse 5 * 4e-3}        1e-2        1e-1        1e0         1e1         ${fparse 9 * 5.4319e1}'
    ix = '${nx_scale} ${fparse 5 * ${nx_scale}} ${nx_scale} ${nx_scale} ${nx_scale} ${nx_scale} ${fparse 9 * ${nx_scale}}'
  []
[]

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
    function = concentration_source_func_TMAP7
  []
[]

[AuxVariables]
  [pressure_left_TMAP4]
  []
  [pressure_left_TMAP7]
  []
  [concentration_source_TMAP4]
  []
  [concentration_source_TMAP7]
  []
[]

[AuxKernels]
  [pressure_TMAP4_aux]
    type = FunctionAux
    variable = pressure_left_TMAP4
    function = pressure_func_TMAP4
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [pressure_TMAP7_aux]
    type = FunctionAux
    variable = pressure_left_TMAP7
    function = pressure_func_TMAP7
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_source_TMAP4_aux]
    type = FunctionAux
    variable = concentration_source_TMAP4
    function = concentration_source_func_TMAP4
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_source_TMAP7_aux]
    type = FunctionAux
    variable = concentration_source_TMAP7
    function = concentration_source_func_TMAP7
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[BCs]
  active = 'left_balance_TMAP7 right_balance'
  [left_balance]
    type = ADFunctionNeumannBC
    boundary = left
    variable = concentration
    function = 0
  []
  # [right_balance]
  #   type = ADFunctionNeumannBC
  #   boundary = right
  #   variable = concentration
  #   function = 0
  # []
  [left_balance_TMAP4]
    type = EquilibriumBC
    Ko = '${fparse sqrt( ${dissociation_coefficient_parameter_enclos1} / ${recombination_coefficient_parameter_enclos1_TMAP4} )}'
    boundary = left
    enclosure_var = pressure_left_TMAP4
    temperature = ${Temperature}
    variable = concentration
    p = 0.5
  []
  [left_balance_TMAP7]
    type = EquilibriumBC
    Ko = '${fparse sqrt( ${dissociation_coefficient_parameter_enclos1} / ${recombination_coefficient_parameter_enclos1_TMAP7} )}'
    boundary = left
    enclosure_var = pressure_left_TMAP7
    temperature = ${Temperature}
    variable = concentration
    p = 0.5
  []
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

[Functions]
  ################## TMAP7
  [Kd_left_func_TMAP7]
    type = ParsedFunction
    expression = '${dissociation_coefficient_parameter_enclos1} * (1 - 0.999997 * exp(-1.2e-4 * t))'
  []

  [Kr_left_func_TMAP7]
    type = ParsedFunction
    expression = '${recombination_coefficient_parameter_enclos1_TMAP7} * (1 - 0.999997 * exp(-1.2e-4 * t))'
  []

  [pressure_func_TMAP7]
    type = ParsedFunction
    expression = 'if(t<5820.0, ${pressure_high},
                  if(t<9060.0, ${pressure_low},
                  if(t<12160,  ${pressure_high},
                  if(t<14472,  ${pressure_low},
                  if(t<17678,  ${pressure_high}, ${pressure_low})))))'
  []

  [surface_flux_func_TMAP7]
    type = ParsedFunction
    expression = 'if(t<5820.0, ${flux_high},
                  if(t<9060.0, ${flux_low},
                  if(t<12160,  ${flux_high},
                  if(t<14472,  ${flux_low},
                  if(t<17678,  ${flux_high}, ${flux_low}))))) * 0.75'
  []

  [concentration_source_func_TMAP7]
    type = ParsedFunction
    symbol_names = 'surface_flux_func pressure_func Kd_left_func Kr_left_func'
    symbol_values = 'surface_flux_func_TMAP7 pressure_func_TMAP7 Kd_left_func_TMAP7 Kr_left_func_TMAP7'
    expression = 'if(x<5e-3,  0,
                  if(x<9e-3,  sqrt((0.15 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<13e-3, sqrt((0.70 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<17e-3, sqrt((0.15 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func), 0))))'
  []

  ################# TMAP4
  [Kd_left_func_TMAP4]
    type = ParsedFunction
    expression = '${dissociation_coefficient_parameter_enclos1} * (1 - 0.9999 * exp(-6e-5 * t))'
  []

  [Kr_left_func_TMAP4]
    type = ParsedFunction
    expression = '${recombination_coefficient_parameter_enclos1_TMAP4} * (1 - 0.9999 * exp(-6e-5 * t))'
  []

  [pressure_func_TMAP4]
    type = ParsedFunction
    expression = 'if(t<6420.0, ${pressure_high},
                  if(t<9420.0, ${pressure_low},
                  if(t<12480,  ${pressure_high},
                  if(t<14940,  ${pressure_low},
                  if(t<18180,  ${pressure_high}, ${pressure_low})))))'
  []

  [surface_flux_func_TMAP4]
    type = ParsedFunction
    expression = 'if(t<6420.0, ${flux_high},
                  if(t<9420.0, ${flux_low},
                  if(t<12480,  ${flux_high},
                  if(t<14940,  ${flux_low},
                  if(t<18180,  ${flux_high}, ${flux_low}))))) * 0.75'
  []

  [concentration_source_func_TMAP4]
    type = ParsedFunction
    symbol_names = 'surface_flux_func pressure_func Kd_left_func Kr_left_func'
    symbol_values = 'surface_flux_func_TMAP4 pressure_func_TMAP4 Kd_left_func_TMAP4 Kr_left_func_TMAP4'
    expression = 'if(x<8e-3,  0,
                  if(x<12e-3, sqrt((0.25 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<16e-3, sqrt((1.00 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func),
                  if(x<20e-3, sqrt((0.25 * surface_flux_func  + pressure_func * Kd_left_func) / Kr_left_func), 0))))'
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

[Outputs]
  # checkpoint = true
  file_base = 'val-2a_TMAP7_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
