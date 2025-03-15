# Physical constants
kb = '${units 1.380649e-23 J/K}' # Boltzmann constant eV/K - from PhysicalConstants.h

# Temperature conditions
temperature_initial = '${units 370 K}'
temperature_cooldown = '${units 295 K}'
temperature_desorption_min = '${units 300 K}'
temperature_desorption_max = '${units 1000 K}'
desorption_heating_rate = '${units ${fparse 3/60} K/s}'

# Important times
charge_time = '${units 72 h -> s}'
cooldown_duration = '${units 12 h -> s}'
desorption_duration = '${fparse (temperature_desorption_max-temperature_desorption_min)/desorption_heating_rate}'
endtime = '${fparse charge_time + cooldown_duration + desorption_duration}'

# Materials properties
diffusion_W_preexponential = '${units 1.6e-7 m^2/s}'
diffusion_W_energy = '${units 0.28 eV -> J}'

# Source term parameters
sigma = '${units 0.5e-9 m}'
R_p = '${units 0.7e-9 m}'
fluence = '${units 1.5e25 atoms/m^2}'
flux = '${units ${fparse fluence / charge_time} atoms/m^2/s}'

# Numerical parameters
dt_max_large = '${units 100 s}'
dt_max_small = '${units 10 s}'
dt_start_charging = '${units 1 s}'
dt_start_cooldown = '${units 10 s}'
dt_start_desorption = '${units 1 s}'

# Geometry and mesh
length_W = '${units 0.8 mm}'
num_nodes_W = 40

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${num_nodes_W}
    xmax = ${length_W}
  []
[]

[Variables]
  [deuterium_concentration_W]
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
  [left_flux]
    type = ADDirichletBC
    boundary = right
    variable = deuterium_concentration_W
    value = 0
  []
  [right_flux]
    type = ADDirichletBC
    boundary = right
    variable = deuterium_concentration_W
    value = 0
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
  [max_time_step_size_func]
    type = ParsedFunction
    expression = 'if(t < ${fparse charge_time-dt_max_large}, ${dt_max_large}, ${dt_max_small})'
  []
[]

[Materials]
  [diffusivity_W_func]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_W'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'T'
    expression = '${diffusion_W_preexponential} * exp(- ${diffusion_W_energy} / ${kb} / T)'
    output_properties = 'diffusivity_W'
  []
  [converter_to_nonAD]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_W'
    reg_props_out = 'diffusivity_W_nonAD'
  []
[]

[Postprocessors]
  [average]
    type = ElementAverageValue
    variable = deuterium_concentration_W
    execute_on = 'initial timestep_end'
  []
  [avg_flux_left]
    type = SideDiffusiveFluxIntegral
    variable = deuterium_concentration_W
    diffusivity = 'diffusivity_W_nonAD'
    boundary = 'left'
  []
  [avg_flux_right]
    type = SideDiffusiveFluxIntegral
    variable = deuterium_concentration_W
    diffusivity = 'diffusivity_W_nonAD'
    boundary = 'right'
  []
  [temperature]
    type = ElementAverageValue
    variable = temperature
    execute_on = 'initial timestep_end'
  []
  [diffusion_W]
    type = ElementAverageValue
    variable = diffusivity_W
  []
  [dt]
    type = TimestepSize
  []
  [max_time_step_size_pp]
    type = FunctionValuePostprocessor
    function = max_time_step_size_func
    execute_on = 'INITIAL TIMESTEP_END'
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
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-12
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = false
  nl_max_its = 7
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start_charging}
    optimal_iterations = 5
    growth_factor = 1.1
    cutback_factor_at_failure = .9
    timestep_limiting_postprocessor = max_time_step_size_pp
    time_t = ' 0                    ${charge_time}        ${fparse charge_time + cooldown_duration}'
    time_dt = '${dt_start_charging} ${dt_start_cooldown}  ${dt_start_desorption}'
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
