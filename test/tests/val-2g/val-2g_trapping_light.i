# Physical constants
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h

# Critical parameters
diffusivity_V_O_energy = 89216.77
diffusivity_e_energy = 103818.22
delta_H_T2O = -79.5e3
delta_S_T2O = -88.9
delta_H_T2 = -79.5e3
delta_S_T2 = -124.53

# thermal parameters
temperature_low = '${units 1000 K}'
temperature_initial = '${units 873 K}'
temperature_high = '${units 1400 K}'
temperature_rate = '${units 0.5 K/s}'

# Model parameters
dissolve_duration = '${units 1 s}'
cooldown_duration = '${units 1 s}'
desorption_duration = '${fparse (temperature_high - temperature_low) / temperature_rate}'
endtime = '${units ${fparse dissolve_duration + cooldown_duration + desorption_duration} s}'
dt_start_charging = '${units 1e-1 s}'

# Geometry and mesh
length = '${units 0.5 mm -> mum}'
num_nodes = 600

# Material properties
N = '${units 1.3043954487e28 at/m^3 -> at/mum^3}'

# Initial concentrations
oxygen_vacancy_concentration_initial = '${units ${fparse 0.05 * N} at/mum^3}'
oxygen_concentration_initial = '${units ${fparse 2.95 * N} at/mum^3}'
electron_concentration_initial = '${units ${fparse 1e-5 * N} at/mum^3}'

# ##### Dry Pressure conditions
##### Wet Pressure conditions
pressure_T2O_high = '${units 2.8e3 Pa}'
pressure_T2O_low = '${units 1e-5 Pa}'
pressure_T2_wet = '${units 0 Pa}' # We assume the pressure of T2O is 0

# chemical_reaction
T2O_reaction_forward_value = '${units 2e-33 m^4/at/s -> mum^4/at/s}'
T2_reaction_forward_value = '${units 2e-41 m^4/at/s -> mum^4/at/s}'

# Materials diffusivities
diffusivity_OT_prefactor = '${units 2e-9 m^2/s -> mum^2/s}'
diffusivity_OT_energy = '${units 22191 J/mol}'
diffusivity_V_O_prefactor = '${units 1.021e-7 m^2/s -> mum^2/s}'
diffusivity_e_prefactor = '${units 2.05e-2 m^2/s -> mum^2/s}'

[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${fparse length}'
    ix = '${fparse num_nodes}'
    subdomain_id = '0'
  []
[]

[Variables]
  #### Wet variable
  [OT_concentration_wet] # (atoms/microns^3)
    initial_condition = 0
  []
  [Oxygen_vacancy_concentration_wet]
    initial_condition = ${oxygen_vacancy_concentration_initial}
  []
  [electron_concentration_wet]
    initial_condition = ${electron_concentration_initial}
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = ${temperature_initial}
  []
  #### Wet auxvariable
  [pressure_T2O_wet]
    initial_condition = ${pressure_T2O_high}
  []
  [Oxygen_concentration_wet]
    initial_condition = ${oxygen_concentration_initial}
  []
[]

[AuxKernels]
  [temperature_Aux]
    type = FunctionAux
    variable = temperature
    function = Temperature_function
  []
  #### Wet auxkernels
  [pressure_T2O_wet_Aux]
    type = FunctionAux
    variable = pressure_T2O_wet
    function = Pressure_T2O_wet_function
  []
  [Oxygen_concentration_wet_Aux] # at/mum^3
    type = ParsedAux
    variable = Oxygen_concentration_wet
    coupled_variables = 'Oxygen_vacancy_concentration_wet OT_concentration_wet'
    expression = '3  * ${N} - Oxygen_vacancy_concentration_wet - OT_concentration_wet'
  []
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Kernels]
  #### Wet kernels
  [time_OT_wet]
    type = ADTimeDerivative
    variable = OT_concentration_wet
    extra_vector_tags = ref
  []
  [diffusion_OT_wet]
    type = ADMatDiffusion
    variable = OT_concentration_wet
    diffusivity = diffusivity_OT
    extra_vector_tags = ref
  []
  [time_V_O_wet]
    type = ADTimeDerivative
    variable = Oxygen_vacancy_concentration_wet
    extra_vector_tags = ref
  []
  [diffusion_V_O_wet]
    type = ADMatDiffusion
    variable = Oxygen_vacancy_concentration_wet
    diffusivity = diffusivity_V_O
    extra_vector_tags = ref
  []
  [time_e_wet]
    type = ADTimeDerivative
    variable = electron_concentration_wet
    extra_vector_tags = ref
  []
  [diffusion_e_wet]
    type = ADMatDiffusion
    variable = electron_concentration_wet
    diffusivity = diffusivity_e
    extra_vector_tags = ref
  []
[]

[BCs]
  #### Wet BCs
  [left_OT_wet]
    type = ADMatNeumannBC
    variable = OT_concentration_wet
    boundary = left
    value = 1
    boundary_material = flux_on_OT_wet
  []
  [right_OT_wet]
    type = ADMatNeumannBC
    variable = OT_concentration_wet
    boundary = right
    value = 1
    boundary_material = flux_on_OT_wet
  []
  [left_V_O_wet]
    type = ADMatNeumannBC
    variable = Oxygen_vacancy_concentration_wet
    boundary = left
    value = 1
    boundary_material = flux_on_V_O_wet
  []
  [right_V_O_wet]
    type = ADMatNeumannBC
    variable = Oxygen_vacancy_concentration_wet
    boundary = right
    value = 1
    boundary_material = flux_on_V_O_wet
  []
  [left_e_wet]
    type = ADMatNeumannBC
    variable = electron_concentration_wet
    boundary = left
    value = 1
    boundary_material = flux_on_e_wet
  []
  [right_e_wet]
    type = ADMatNeumannBC
    variable = electron_concentration_wet
    boundary = right
    value = 1
    boundary_material = flux_on_e_wet
  []
[]

[Functions]
  [Temperature_function]
    type = ParsedFunction
    expression = 'if(t<${dissolve_duration},
                              ${temperature_initial},
                  if(t<${dissolve_duration} + ${cooldown_duration},
                              ${temperature_low},
                  if(t<${dissolve_duration} + ${cooldown_duration} + ${desorption_duration},
                              ${temperature_low} + ${temperature_rate} * (t - ${dissolve_duration} - ${cooldown_duration}),
                              ${temperature_high})))'
  []
  [Pressure_T2O_wet_function]
    type = ParsedFunction
    expression = 'if(t<${dissolve_duration} + ${cooldown_duration} - 1000, ${pressure_T2O_high},
                  if(t<${dissolve_duration} + ${cooldown_duration}, ${pressure_T2O_low},
                                                                    ${pressure_T2O_low}))'
  []
  [max_dt_size_function]
    type = ParsedFunction
    expression = 'if(t<${dissolve_duration} + 200,                      50,
                  if(t<${dissolve_duration} + ${cooldown_duration} + 100, 10, 10))'
  []
[]

[Materials]
  [diffusivity_OT]
    type = ADParsedMaterial
    property_name = 'diffusivity_OT'
    coupled_variables = 'temperature'
    expression = '${diffusivity_OT_prefactor} * exp(-${diffusivity_OT_energy} / ${R} / temperature)'
  []
  [diffusivity_V_O]
    type = ADParsedMaterial
    property_name = 'diffusivity_V_O'
    coupled_variables = 'temperature'
    expression = '${diffusivity_V_O_prefactor} * exp(-${diffusivity_V_O_energy} / ${R} / temperature)'
  []
  [diffusivity_e]
    type = ADParsedMaterial
    property_name = 'diffusivity_e'
    coupled_variables = 'temperature'
    expression = '${diffusivity_e_prefactor} * exp(-${diffusivity_e_energy} / ${R} / temperature)'
  []
  [reaction_equilibrium_constant_T2O]
    type = ADParsedMaterial
    property_name = 'T2O_K_eq'
    coupled_variables = 'temperature'
    expression = 'exp( (temperature * ${delta_S_T2O} - ${delta_H_T2O}) / ${R} / temperature )'
  []
  [reaction_forward_T2O]
    type = ADParsedMaterial
    property_name = 'T2O_K_forward'
    expression = '${T2O_reaction_forward_value}'
  []
  [reaction_reverse_T2O]
    type = ADParsedMaterial
    property_name = 'T2O_K_reverse'
    material_property_names = 'T2O_K_forward T2O_K_eq'
    expression = 'T2O_K_forward / T2O_K_eq'
  []
  [reaction_equilibrium_constant_T2]
    type = ADParsedMaterial
    property_name = 'T2_K_eq'
    coupled_variables = 'temperature'
    expression = 'exp( (temperature * ${delta_S_T2} - ${delta_H_T2}) / ${R} / temperature )'
  []
  [reaction_forward_T2]
    type = ADParsedMaterial
    property_name = 'T2_K_forward'
    expression = '${T2_reaction_forward_value}'
  []
  [reaction_reverse_T2]
    type = ADParsedMaterial
    property_name = 'T2_K_reverse'
    material_property_names = 'T2_K_forward T2_K_eq'
    expression = 'T2_K_forward / T2_K_eq'
  []
  #### Reaction for wet
  [flux_base_on_T2O_wet] # T2O + V_O + O -> 2 OT
    type = ADDerivativeParsedMaterial
    coupled_variables = 'OT_concentration_wet pressure_T2O_wet Oxygen_concentration_wet Oxygen_vacancy_concentration_wet'
    property_name = 'flux_base_on_T2O_wet'
    material_property_names = 'T2O_K_forward T2O_K_reverse'
    expression = '(T2O_K_forward * pressure_T2O_wet * Oxygen_concentration_wet * Oxygen_vacancy_concentration_wet - T2O_K_reverse * OT_concentration_wet^2)'
  []
  [flux_base_on_T2_wet] # T2 + 2 O -> 2 OT + 2 e
    type = ADDerivativeParsedMaterial
    coupled_variables = 'OT_concentration_wet Oxygen_concentration_wet electron_concentration_wet'
    property_name = 'flux_base_on_T2_wet'
    material_property_names = 'T2_K_forward T2_K_reverse'
    expression = '(T2_K_forward * ${pressure_T2_wet} * Oxygen_concentration_wet^2 - T2_K_reverse * OT_concentration_wet^2 * electron_concentration_wet^2)'
  []
  #### Flux for wet
  [flux_on_e_wet] # electron
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_e_wet'
    material_property_names = 'flux_base_on_T2_wet'
    expression = '2 * flux_base_on_T2_wet'
  []
  [flux_on_OT_wet] # OT
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_OT_wet'
    material_property_names = 'flux_base_on_T2O_wet'
    expression = '2 * flux_base_on_T2O_wet'
  []
  [flux_on_T2_wet] # T2
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_T2_wet'
    material_property_names = 'flux_base_on_T2_wet'
    expression = '-1 * flux_base_on_T2_wet'
  []
  [flux_on_V_O_wet] # V_O
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_V_O_wet'
    material_property_names = 'flux_base_on_T2O_wet'
    expression = '-1 * flux_base_on_T2O_wet'
  []
  [flux_on_T2O_wet] # T2O
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_T2O_wet'
    material_property_names = 'flux_base_on_T2O_wet'
    expression = '-1 * flux_base_on_T2O_wet'
  []
[]

[Postprocessors]
  #### Postprocessors for flux under wet
  [recombination_flux_T2O_wet_left]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_T2O_wet
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv exodus'
  []
  [recombination_flux_T2_wet_left]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_T2_wet
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv exodus'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-10
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = true
  line_search = none
  nl_max_its = 10
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start_charging}
    optimal_iterations = 7
    growth_factor = 1.1
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Outputs]
  [csv]
    type = CSV
  []
  [exodus]
    type = Exodus
    start_time = ${fparse dissolve_duration + cooldown_duration}
  []
[]
