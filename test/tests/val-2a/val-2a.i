nx_scale = 5
high_dt_max = 100
low_dt_max = 1
simulation_time = '${units 2e4 s}'
diffusivity_D = '${units 3e-10 m^2/s -> mum^2/s}'
recombination_parameter_enclos2 = '${units 2e-31 m^4/at/s -> mum^4/at/s}'
flux_high = '${units 4.9e19 at/m^2/s -> at/mum^2/s}'
flux_low =  '${units 0      at/mum^2/s}'
dissociation_coefficient_parameter_enclos1 = '${units 8.959e18 at/m^2/s/Pa -> at/mum^2/s/Pa}'
recombination_coefficient_parameter_enclos1_TMAP4 = '${units 1e-27 m^4/at/s -> mum^4/at/s}'
width = '${units 2.4e-9 m -> mum}'
depth = '${units 14e-9 m -> mum}'
time_1 = '${units 5820 s}'
time_2 = '${units 9056 s}'
time_3 = '${units 12062 s}'
time_4 = '${units 14572 s}'
time_5 = '${units 17678 s}'

[Variables]
  [concentration]
    order = FIRST
    family = LAGRANGE
  []
[]

[Mesh]
  [cartesian]
    type = CartesianMeshGenerator
    dim = 1
    #     num
    dx = '${fparse 5 * ${units 4e-9 m -> mum}}  ${units 1e-8 m -> mum}  ${units 1e-7 m -> mum}
          ${units 1e-6 m -> mum}                ${units 1e-5 m -> mum}  ${fparse 10 * ${units 4.88e-5 m -> mum}}'
    ix = '${fparse 5 * ${nx_scale}}             ${nx_scale}             ${nx_scale}
          ${nx_scale}                           ${nx_scale}             ${fparse 10 * ${nx_scale}}'
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
    function = concentration_source_norm_func
  []
[]

[AuxVariables]
  [concentration_source]
  []
  [recombination_TMAP4]
  []
[]

[AuxKernels]
  [concentration_source_aux]
    type = FunctionAux
    variable = concentration_source
    function = concentration_source_norm_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [recombination_aux_TMAP4]
    type = FunctionAux
    variable = recombination_TMAP4
    function = '${recombination_coefficient_parameter_enclos1_TMAP4}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[BCs]
  [left]
    type = MatNeumannBC
    variable = concentration
    boundary = left
    value = 1
    boundary_material = flux_on_left
  []
  [right]
    type = MatNeumannBC
    variable = concentration
    boundary = right
    value = 1
    boundary_material = flux_on_right
  []
[]

[Materials]
  [flux_on_left]
    type = DerivativeParsedMaterial
    coupled_variables = 'concentration'
    property_name = 'flux_on_left'
    functor_names = 'Kr_left_func'
    functor_symbols = 'Kr_left_func'
    expression = '- 2 * Kr_left_func * concentration ^ 2'
  []
  [flux_on_right]
    type = DerivativeParsedMaterial
    coupled_variables = 'concentration'
    property_name = 'flux_on_right'
    expression = '- 2 * ${recombination_parameter_enclos2} * concentration ^ 2'
  []
[]

[Functions]
  [Kd_left_func]
    type = ParsedFunction
    expression = '${dissociation_coefficient_parameter_enclos1} * (1 - 0.9999 * exp(-6e-5 * t))'
  []

  [Kr_left_func]
    type = ParsedFunction
    expression = '${recombination_coefficient_parameter_enclos1_TMAP4} * (1 - 0.9999 * exp(-6e-5 * t))'
  []

  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t < ${time_1}, ${flux_high},
                  if(t < ${time_2}, ${flux_low},
                  if(t < ${time_3},  ${flux_high},
                  if(t < ${time_4},  ${flux_low},
                  if(t < ${time_5},  ${flux_high}, ${flux_low}))))) * 0.75'
  []

  [source_distribution]
    type = ParsedFunction
    expression = '1.5 / ( ${width} * sqrt(2 * pi) ) * exp(-0.5 * ((x - ${depth}) / ${width}) ^ 2)'
  []

  [concentration_source_norm_func]
    type = ParsedFunction
    symbol_names = 'source_distribution surface_flux_func'
    symbol_values = 'source_distribution surface_flux_func'
    expression = 'source_distribution * surface_flux_func'
  []

  [max_dt_size_func]
    type = ParsedFunction
    expression = 'if(t<${time_1}-100,  ${high_dt_max},
                  if(t<${time_1}+100,  ${low_dt_max},
                  if(t<${time_2}-100,  ${high_dt_max},
                  if(t<${time_2}+100,  ${low_dt_max},
                  if(t<${time_3}-100,  ${high_dt_max},
                  if(t<${time_3}+100,  ${low_dt_max},
                  if(t<${time_4}-100,  ${high_dt_max},
                  if(t<${time_4}+100,  ${low_dt_max},
                  if(t<${time_5}-100,  ${high_dt_max},
                  if(t<${time_5}+100,  ${low_dt_max}, ${high_dt_max}))))))))))'
  []
[]

[Postprocessors]
  [dcdx_left]
    type = SideAverageMaterialProperty
    boundary = left
    property = flux_on_left
    outputs = none
  []
  [scaled_recombination_flux_left]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = dcdx_left
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [dcdx_right]
    type = SideAverageMaterialProperty
    boundary = right
    property = flux_on_right
    outputs = none
  []
  [scaled_recombination_flux_right]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = dcdx_right
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_func
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
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

  end_time = ${simulation_time}
  automatic_scaling = true
  # nl_abs_tol = 1e-12
  nl_rel_tol = 1e-2
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 3.125
    optimal_iterations = 12
    growth_factor = 1.1
    cutback_factor = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Outputs]
  file_base = 'val-2a_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
    time_step_interval = 100
  []
[]
