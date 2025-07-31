# This input file provides the common structure for both the finite and the infinite recombination cases.
# It is included in val-2f.i and val-2f_infinite_recombination.i

!include val-2f_trapping_intrinsic.i
!include val-2f_trapping_5.i
!include val-2f_trapping_4.i
!include val-2f_trapping_3.i
!include val-2f_trapping_2.i
!include val-2f_trapping_1.i

[Mesh]
  [cartesian_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${dx1} ${dx2} ${dx3} ${dx4} ${dx5}'
    ix = '${ix1} ${ix2} ${ix3} ${ix4} ${ix5}'
    subdomain_id = '0 0 0 0 0'
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
  [temperature]
    initial_condition = ${temperature_initial}
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
  [max_dt_size_function_coarse]
    type = ParsedFunction
    expression = 'if(t<${fparse 1e-1}, ${fparse 1e4}, ${fparse 1e5})'
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
  petsc_options_value = 'asm lu vinewtonrsls' # This petsc option helps prevent negative concentrations with bounds'
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = false
  line_search = 'none'
  nl_rel_tol = 5e-7
  nl_abs_tol = 5e-9
  nl_max_its = 34
  dtmin = 1e-8
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_init}
    optimal_iterations = 25
    growth_factor = 1.1
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.5
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Debug]
  show_var_residual = 'deuterium_concentration_W'
  show_var_residual_norms = true
[]

[Outputs]
  [csv]
    type = CSV
  []
  [exodus]
    type = Exodus
    output_material_properties = true
    time_step_interval = 200
  []
[]
