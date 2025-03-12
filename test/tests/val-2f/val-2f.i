# Physical constants
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h

# Pressure conditions
pressure_enclosure_init = '${units 13300 Pa}'
pressure_enclosure_cooldown = '${units 1e-6 Pa}' # vaccum
pressure_enclosure_desorption = '${units 1e-3 Pa}' # vaccum, assumed

# Temperature conditions
temperature_initial = '${units 773 K}'
temperature_desorption_min = '${units 300 K}'
temperature_desorption_max = '${units 1073 K}'
temperature_cooldown_min = ${temperature_desorption_min}
desorption_heating_rate = '${units ${fparse 3/60} K/s}'

# Important times
charge_time = '${units 50 h -> s}'
cooldown_time_constant = '${units ${fparse 45*60} s}'
# TMAP4 and TMAP7 used 40 minutes for the cooldown duration,
# We use a 5 hour cooldown period to let the temperature decrease to around 300 K for the start of the desorption.
# R.G. Macaulay-Newcombe et al. (1991) is not very clear on how long samples cooled down.
cooldown_duration = '${units 5 h -> s}'
desorption_duration = '${fparse (temperature_desorption_max-temperature_desorption_min)/desorption_heating_rate}'
endtime = '${fparse charge_time + cooldown_duration + desorption_duration}'

# Materials properties
concentration_scaling = 1e10 # (-)
diffusion_Be_preexponential = '${units 8.0e-9 m^2/s -> mum^2/s}'
diffusion_Be_energy = '${units 4220 K}'
solubility_order = .5 # order of the solubility law (Here, we use Sievert's law)
solubility_constant_Be = '${fparse 7.156e27 / 1e18 / concentration_scaling}' # at/m^3/Pa^0.5 -> at/mum^3/Pa^0.5}
solubility_energy_Be = '${units 11606 K}'
solubility_constant_BeO = '${fparse 5.00e20 / 1e18 / concentration_scaling}' # at/m^3/Pa^0.5 -> at/mum^3/Pa^0.5}
solubility_energy_BeO = '${units -9377.7 K}'

# Numerical parameters
dt_max_large = '${units 100 s}'
dt_max_small = '${units 10 s}'
dt_start_charging = '${units 1 s}'
dt_start_cooldown = '${units 10 s}'
dt_start_desorption = '${units 1 s}'

# Geometry and mesh
length_Be = '${units 0.4 mm -> mum}'
length_Be_modeled = '${fparse length_Be/2}'
num_nodes_Be = 40
node_length_Be = '${fparse length_Be_modeled / num_nodes_Be}'

[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 1

    # Define cell lengths for only the Be subdomain
    dx = '${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be}
          ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be}
          ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be}
          ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be} ${node_length_Be}'

    # Set all cells to subdomain 1 (now renumbered starting from 0)
    subdomain_id = '1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1'
  []
[]

[Variables]
  [deuterium_concentration_Be] # (atoms/microns^3) / concentration_scaling
    block = 1
  []
[]

[AuxVariables]
  [enclosure_pressure]
    family = SCALAR
    initial_condition = ${pressure_enclosure_init}
  []
  [temperature]
    initial_condition = ${temperature_initial}
  []
  [flux_x]
    order = FIRST
    family = MONOMIAL
  []
[]

[Kernels]
  [time_Be]
    type = TimeDerivative
    variable = deuterium_concentration_Be
    block = 1
  []
  [diffusion_Be]
    type = ADMatDiffusion
    variable = deuterium_concentration_Be
    diffusivity = diffusivity_Be
    block = 1
  []
[]

[AuxScalarKernels]
  [enclosure_pressure_aux]
    type = FunctionScalarAux
    variable = enclosure_pressure
    function = enclosure_pressure_func
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_bc_func
    execute_on = 'INITIAL LINEAR'
  []
  [flux_x_Be]
    type = DiffusionFluxAux
    diffusivity = diffusivity_Be
    variable = flux_x
    diffusion_variable = deuterium_concentration_Be
    component = x
    block = 1
  []
[]

[BCs]
  [left_flux]
    type = EquilibriumBC
    Ko = ${solubility_constant_BeO}
    activation_energy = '${fparse solubility_energy_BeO * R}'
    boundary = left
    enclosure_var = enclosure_pressure
    temperature = temperature
    variable = deuterium_concentration_Be
    p = ${solubility_order}
  []
  [right_flux]
    type = ADNeumannBC
    boundary = right
    variable = deuterium_concentration_Be
    value = 0
  []
[]

[Functions]
  [temperature_bc_func]
    type = ParsedFunction
    expression = 'if(t<${charge_time}, ${temperature_initial}, if(t<${fparse charge_time + cooldown_duration}, ${temperature_initial}-((1-exp(-(t-${charge_time})/${cooldown_time_constant}))*${fparse temperature_initial - temperature_cooldown_min}), ${temperature_desorption_min}+${desorption_heating_rate}*(t-${fparse charge_time + cooldown_duration})))'
  []
  [diffusivity_Be_func]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = 'temperature_bc_func'
    expression = '${diffusion_Be_preexponential}*exp(-${diffusion_Be_energy}/T)'
  []
  [enclosure_pressure_func]
    type = ParsedFunction
    expression = 'if(t<${charge_time}, ${pressure_enclosure_init}, if(t<${fparse charge_time + cooldown_duration}, ${pressure_enclosure_cooldown}, ${pressure_enclosure_desorption}))'
  []
  [solubility_Be_func]
    type = ParsedFunction
    symbol_names = 'T'
    symbol_values = 'temperature_bc_func'
    expression = '${solubility_constant_Be} * exp(-${solubility_energy_Be}/T)'
  []
  [max_time_step_size_func]
    type = ParsedFunction
    expression = 'if(t < ${fparse charge_time-dt_max_large}, ${dt_max_large}, ${dt_max_small})'
  []
[]

[Materials]
  [diffusion_solubility]
    type = ADGenericFunctionMaterial
    prop_names = 'diffusivity_Be solubility_Be'
    prop_values = 'diffusivity_Be_func solubility_Be_func'
    outputs = all
  []
  [converter_to_nonAD]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_Be'
    reg_props_out = 'diffusivity_Be_nonAD'
  []
[]

[Postprocessors]
  [avg_flux_left]
    type = SideDiffusiveFluxAverage
    variable = deuterium_concentration_Be
    boundary = left
    diffusivity = diffusivity_Be_nonAD
  []
  [avg_flux_total] # total flux coming out of the sample in atoms/microns^2/s
    type = ScalePostprocessor
    value = avg_flux_left
    scaling_factor = '${fparse 2 * concentration_scaling}'
    # Factor of 2 because symmetry is assumed and only one-half of the specimen is modeled.
    # Thus, the total flux coming out of the specimen (per unit area)
    # is twice the flux calculated at the left side of the domain.
    # The 'concentration_scaling' parameter is used to get a consistent concentration unit
  []
  [temperature]
    type = ElementAverageValue
    block = 1
    variable = temperature
    execute_on = 'initial timestep_end'
  []
  [diffusion_Be]
    type = ElementAverageValue
    block = 1
    variable = diffusivity_Be
  []
  [solubility_Be]
    type = ElementAverageValue
    block = 1
    variable = solubility_Be
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
  nl_abs_tol = 5e-12
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
