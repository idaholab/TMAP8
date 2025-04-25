# Physical constants
kb = '${units 1.380649e-23 J/K}' # Boltzmann constant J/K - from PhysicalConstants.h
eV_to_J = '${units 1.602176634e-19 J/eV}' # Conversion coefficient from eV to Joules - from PhysicalConstants.h
kb_eV = '${units ${fparse kb / eV_to_J} eV/K}' # Boltzmann constant eV/K

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
diffusion_W_preexponential = '${units 1.6e-7 m^2/s -> mum^2/s}'
diffusion_W_energy = '${units 0.28 eV -> J}'
recombination_coefficient = '${units ${fparse 2e-49} m^4/at/s -> mum^4/at/s}'
recombination_energy = '${units 2.06 eV}'

# Source term parameters
sigma = '${units 0.5e-9 m -> mum}'
R_p = '${units 0.7e-9 m -> mum}'
flux = '${units ${fparse 5.79e19} at/m^2/s -> at/mum^2/s}'

# Numerical parameters
dt_start_charging = '${units 1 s}'
dt_start_cooldown = '${units 10 s}'
dt_start_desorption = '${units 1 s}'

# Mesh parameters
sample_thickness = '${units 0.8e-3 m -> mum}'
dx1 = '${fparse 5*sigma}'
dx2 = '${fparse 10*sigma}'
dx3 = '${fparse 50*sigma}'
dx4 = '${fparse sample_thickness-(dx1+dx2+dx3)}'
ix1 = 50
ix2 = '${fparse dx2/dx1 * ix1}'
ix3 = '${fparse dx3/dx2 * ix2}'
ix4 = 100
ix1_coarse = 25
ix2_coarse = '${fparse dx2/dx1 * ix1_coarse}'
ix3_coarse = '${fparse dx3/dx2 * ix2_coarse}'
ix4_coarse = 50

[Mesh]
  active = 'cartesian_mesh'
  [cartesian_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${dx1}
          ${dx2}
          ${dx3}
          ${dx4}'
    ix = '${ix1}
          ${ix2}
          ${ix3}
          ${ix4}'
    subdomain_id = '0 0 0 0'
  []
  [cartesian_mesh_coarse]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${dx1}
          ${dx2}
          ${dx3}
          ${dx4}'
    ix = '${ix1_coarse}
          ${ix2_coarse}
          ${ix3_coarse}
          ${ix4_coarse}'
    subdomain_id = '0 0 0 0'
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
  [left_concentration]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = left
    value = 1
    boundary_material = flux_on_left
  []
  [right_concentration]
    type = DirichletBC
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
[]

[Materials]
  [diffusivity_W_func]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_W'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${diffusion_W_preexponential} * exp(- ${diffusion_W_energy} / ${kb} / temperature)'
    output_properties = 'diffusivity_W'
  []
  [diffusivity_nonAD]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_W'
    reg_props_out = 'diffusivity_W_nonAD'
  []
  [Kr_left_func]
    type = ADDerivativeParsedMaterial
    property_name = 'Kr_left'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${recombination_coefficient} / (temperature ^ 0.5) * exp(${recombination_energy} / ${kb_eV} / temperature)'
    output_properties = 'Kr_left'
  []
  [flux_on_left]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'deuterium_concentration_W'
    property_name = 'flux_on_left'
    material_property_names = 'Kr_left'
    expression = '- 2 * Kr_left * deuterium_concentration_W ^ 2'
  []
[]

[Postprocessors]
  [average]
    type = ElementAverageValue
    variable = deuterium_concentration_W
    execute_on = 'initial timestep_end'
  []
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = deuterium_concentration_W
    diffusivity = 'diffusivity_W_nonAD'
    boundary = 'left'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = deuterium_concentration_W
    diffusivity = 'diffusivity_W_nonAD'
    boundary = 'right'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${fparse 1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_right
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
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
  [dt]
    type = TimestepSize
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
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm lu'
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = false
  line_search = 'none'
  nl_rel_tol = 5e-7
  nl_abs_tol = 6e-11
  nl_max_its = 34
  dtmax = 100
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 25
    growth_factor = 1.1
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
    time_t = '0 ${charge_time} ${fparse charge_time + cooldown_duration}'
    time_dt = '${dt_start_charging} ${dt_start_cooldown} ${dt_start_desorption}'
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
