!include parameters_val-2f.params
!include val-2f_trapping_2.i
!include val-2f_trapping_1.i

[Mesh]
  active = 'cartesian_mesh'
  [cartesian_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${dx1} ${dx2} ${dx3} ${dx4}'
    ix = '${ix1} ${ix2} ${ix3} ${ix4}'
    subdomain_id = '0 0 0 0'
  []
[]

[Variables]
  [deuterium_concentration_W]
  []
[]

[AuxVariables]
  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  [deuterium_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_concentration_W
    bound_type = lower
    bound_value = '${fparse -1e-20}'
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = ${temperature_initial}
  []
  [flux_x]
    order = FIRST
    family = MONOMIAL
  []
[]

[Kernels]
  [time_W]
    type = TimeDerivative
    variable = deuterium_concentration_W
  []
  [diffusion_W]
    type = ADMatDiffusion
    variable = deuterium_concentration_W
    diffusivity = diffusivity_W
  []
  [source_deuterium]
    type = BodyForce
    variable = deuterium_concentration_W
    function = source_deuterium
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_bc_func
    execute_on = 'INITIAL LINEAR'
  []
  [flux_x_W]
    type = DiffusionFluxAux
    diffusivity = diffusivity_W
    variable = flux_x
    diffusion_variable = deuterium_concentration_W
    component = x
  []
[]

[BCs]
  [left_concentration]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface
  []
  [right_concentration]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface
  []
[]

[Functions]
  [temperature_bc_func]
    type = ParsedFunction
    expression = 'if(t<${charge_time}, ${temperature_initial},
                  if(t<${fparse charge_time + cooldown_duration}, ${temperature_cooldown},
                  ${temperature_desorption_min}+${desorption_heating_rate}*(t-${fparse charge_time + cooldown_duration})))'
  []
  [source_distribution]
    type = ParsedFunction
    expression = '1 / (${sigma} * sqrt(2 * pi)) * exp(-0.5 * ((x - ${R_p}) / ${sigma}) ^ 2)'
  []
  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t<${charge_time}, ${flux}, 0)'
  []
  [source_deuterium]
    type = ParsedFunction
    symbol_names = 'source_distribution surface_flux_func'
    symbol_values = 'source_distribution surface_flux_func'
    expression = 'source_distribution * surface_flux_func'
  []
  [max_dt_size_function]
    type = ParsedFunction
    expression = 'if(t<${fparse 3700}, ${fparse 1e1},
                  if(t<${fparse 3900}, ${fparse 1e0},
                  if(t<${fparse 6400}, ${fparse 1e1},
                  if(t<${fparse 7400}, ${fparse 1e0},
                  if(t<${fparse 10000}, ${fparse 1e1},
                  if(t<${fparse 1e5-1e4}, ${fparse 1e2},
                  if(t<${fparse 1e5+1e4}, ${fparse 5},
                  if(t<${fparse charge_time + cooldown_duration + 4500}, ${fparse 1e2},
                  if(t<${fparse 308500}, ${fparse 1e0},
                  if(t<${endtime}, ${fparse 2e2}, ${fparse 1e2}))))))))))'
  []
  [max_dt_size_function_coarse]
    type = ParsedFunction
    expression = 'if(t<${fparse 150}, ${fparse 1e1},
                  if(t<${fparse 195}, ${fparse 1e1},
                  if(t<${fparse 205}, ${fparse 1e-1},
                  if(t<${fparse 220}, ${fparse 1e0},${fparse 1e1}))))'
  []
[]

[Materials]
  [diffusivity_W_func]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_W'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${diffusion_W_preexponential} * exp(- ${diffusion_W_energy} / ${kb_eV} / temperature)'
    output_properties = 'diffusivity_W'
  []
  [diffusivity_nonAD]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_W'
    reg_props_out = 'diffusivity_W_nonAD'
  []
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = 'Kr'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${recombination_coefficient}* exp(${recombination_energy} / ${kb_eV} / temperature)'
    output_properties = 'Kr'
  []
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'deuterium_concentration_W'
    property_name = 'flux_recombination_surface'
    material_property_names = 'Kr'
    expression = '- 2 * Kr * deuterium_concentration_W ^ 2'
  []
[]

[Postprocessors]
  [integral_source_deuterium]
    type = FunctionElementIntegral
    function = source_deuterium
    outputs = none
  []
  [scaled_implanted_deuterium]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2}}'
    value = integral_source_deuterium
  []
  [integral_deuterium_concentration]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_concentration_W
    outputs = none
  []
  [scaled_mobile_deuterium]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2}}'
    value = integral_deuterium_concentration
  []
  [flux_surface_left]
    type = ADSideAverageMaterialProperty
    boundary = 'left'
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [flux_surface_right]
    type = ADSideAverageMaterialProperty
    boundary = 'right'
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_right
    execute_on = 'initial nonlinear linear timestep_end'
  []
  [temperature]
    type = ElementAverageValue
    variable = temperature
    execute_on = 'initial timestep_end'
  []
  [diffusion_W]
    type = ElementAverageValue
    variable = diffusivity_W
    outputs = none
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
  [max_time_step_size_coarse]
    type = FunctionValuePostprocessor
    function = max_dt_size_function_coarse
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
  solve_type = 'Newton'
  petsc_options_iname = '-pc_type -sub_pc_type -snes_type'
  petsc_options_value = 'asm      lu           vinewtonrsls' # This petsc option helps prevent negative concentrations with bounds'
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = false
  line_search = 'none'
  nl_rel_tol = 5e-7
  nl_abs_tol = 6e-11
  nl_max_its = 34
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_init}
    optimal_iterations = 25
    growth_factor = 1.1
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Debug]
  show_var_residual = 'deuterium_concentration_W'
  show_var_residual_norms = true
[]

[Outputs]
  file_base = 'val-2f_out'
  [csv]
    type = CSV
  []
  [exodus]
    type = Exodus
    output_material_properties = true
    time_step_interval = 60
  []
[]
