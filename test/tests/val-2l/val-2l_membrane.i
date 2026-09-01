# val-2l: BCY20 hydrogen permeation under applied voltage.
# Unit system: length is converted to nm for the spatial solve, time is s,
# temperature is K, pressure is Pa, concentrations are atoms/nm^3,
# and fluxes reported by the membrane model are atoms/nm^2/s.

# 14 optimized parameters used by the val-2l validation runs
# Polycrystalline, Porous NiO-BCY base assumed having no impact on hydrogen diffusion

# Physical constants
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h
N_a = '${units 6.02214076e23 at/mol}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h
q = '${units 1.602176634e-19 C}' # quantity of charge
F = '${fparse N_a * q}'

# thermal parameters
temperature_initial = '${units 773 K}' # 500C

# Model parameters
endtime = '1e5'
dt_max = '2e3'
dt_start_charging = '${units 1e-5 s}'
bound_value_min = '${units -1e-20 at/nm^3}'

# Geometry and mesh
length = '${units 10 mum -> nm}' # BCY20
num_nodes = 300

# Material properties
density_BCY20 = '${units ${fparse 1.0 * 6.154} g/cm^3 -> g/m^3}'
molar_mass_BCY20 = '${units 283.42 g/mol}'
N = '${units ${fparse density_BCY20 / molar_mass_BCY20 * N_a} at/m^3 -> at/nm^3}' # 1.3076089986e10

# Initial concentrations
OT_concentration_initial = 1e-5
hydration_limit_S = 0.2
oxygen_vacancy_concentration_initial = '${units ${fparse hydration_limit_S / 2 * N} at/nm^3}'
oxygen_concentration_initial = '${units ${fparse 3 * N - oxygen_vacancy_concentration_initial - OT_concentration_initial} at/nm^3}'

##### Dry Pressure conditions
pressure_atm = '${units 101315 Pa}'
pressure_T2_low = '${units 0 Pa}'      # pure N2 and 3% H2O
pressure_T2_high = '${units ${fparse 0.8 * pressure_atm} Pa}' # 80% H2 in N2 and 3% H2O
pressure_T2O_constant = '${units ${fparse 0.03 * pressure_atm} Pa}' # 80% H2 in N2 and 3% H2O

# chemical_reaction - optimized parameters used for val-2l no-Joule validation
delta_H_T2O = '${units -1.54415211e+05 J/mol}'
delta_S_T2O = '${units -1.67187585e+02 J/mol/K}'
delta_H_T2 = '${units -5.46037663e+04 J/mol}'
delta_S_T2 = '${units -3.36929406e+01 J/mol/K}'
T2O_reaction_forward_mol_exponent = -1.19792592e+01
ramp_time = 1
T2O_reaction_forward_mol = '${units ${fparse 8.0 * 10 ^ T2O_reaction_forward_mol_exponent} m^4/mol/s}'
T2O_reaction_forward_value = '${units ${fparse T2O_reaction_forward_mol / N_a} m^4/at/s -> nm^4/at/s}'
T2O_reaction_forward_energy = '${units -7.31595474e+03 J/mol}'
T2_reaction_forward_mol_exponent = -4.05998297e+00
T2_reaction_forward_mol = '${units ${fparse 8.0 * 10 ^ T2_reaction_forward_mol_exponent} m^4/mol/s}'
T2_reaction_forward_value = '${units ${fparse T2_reaction_forward_mol / N_a} m^4/at/s -> nm^4/at/s}'
T2_reaction_forward_energy = '${units 5.13385478e+03 J/mol}'
diffusivity_OT_prefactor_exponent = -1.26000119e+01
diffusivity_OT_prefactor = '${units ${fparse 2.03 * 10 ^ diffusivity_OT_prefactor_exponent} m^2/s -> nm^2/s}'
diffusivity_OT_energy = '${units 8.65880079e+03 J/mol}'
diffusivity_V_O_prefactor_exponent = -5.33084375e+00
diffusivity_V_O_prefactor = '${units ${fparse 1.1 * 10 ^ diffusivity_V_O_prefactor_exponent} m^2/s -> nm^2/s}'
diffusivity_V_O_energy = '${units 5.87658926e+04 J/mol}'
diffusivity_e_prefactor = '${units 2.06292148e-02 m^2/s -> nm^2/s}' # data from Yang 2026
diffusivity_e_energy = '${units 9.53470966e+04 J/mol}'
# ELECTRON
electron_concentration_initial_expo = 4.94096686e-01
electron_concentration_initial_energy = '${units 5.90846106e+04 J/mol}'
electron_concentration_initial = '${units ${fparse 10 ^ electron_concentration_initial_expo * N} at/nm^3}'

# voltage
V_current = 2.0 # CONSTANT_VOLTAGE - no ${units} wrapper so CLI override works

# target flux for error computation (overridden by parent via cli_args)
target_flux = 1e20

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
  #### Dry variable
  [OT_concentration_dry] # (atoms/nm^3)
    initial_condition = ${OT_concentration_initial}
  []
  [Oxygen_vacancy_concentration_dry]
    initial_condition = ${oxygen_vacancy_concentration_initial}
  []
[]

[Bounds]
  [concentration_dry_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = OT_concentration_dry
    bound_type = lower
    bound_value = ${bound_value_min}
  []
  [concentration_dry_V_O_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = Oxygen_vacancy_concentration_dry
    bound_type = lower
    bound_value = ${bound_value_min}
  []
  [concentration_dry_V_O_upper_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = Oxygen_vacancy_concentration_dry
    bound_type = upper
    bound_value = ${fparse 3 * N}
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
  #### Dry auxvariable
  [pressure_T2_dry]
  []
  [pressure_T2O_dry]
  []
  [Oxygen_concentration_dry]
    initial_condition = ${oxygen_concentration_initial}
  []
  [electron_concentration_dry]
  []

  # CONSTANT_VOLTAGE
  [voltage_phi]
  []
[]


[AuxKernels]
  [temperature_Aux]
    type = FunctionAux
    variable = temperature
    function = Temperature_function
  []

  #### Dry auxkernels
  [pressure_T2_dry_Aux]
    type = FunctionAux
    variable = pressure_T2_dry
    function = Pressure_T2_dry_function
  []
  [pressure_T2O_dry_Aux]
    type = FunctionAux
    variable = pressure_T2O_dry
    function = Pressure_T2O_dry_function
  []
  [Oxygen_concentration_dry_Aux] # at/nm^3
    type = ParsedAux
    variable = Oxygen_concentration_dry
    coupled_variables = 'Oxygen_vacancy_concentration_dry'
    expression = '3 * ${N} - Oxygen_vacancy_concentration_dry'
  []

  # ELECTRON
  [electron_concentration_dry_Aux]
    type = ParsedAux
    variable = electron_concentration_dry
    coupled_variables = 'temperature'
    expression = '${electron_concentration_initial} * 0.5 * exp(-${electron_concentration_initial_energy} / ${R} / temperature)'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  # CONSTANT_VOLTAGE
  [phi_auxkernel]
    type = FunctionAux
    variable = voltage_phi
    function = '${V_current} * (${length} - x) / ${length}'
    execute_on = 'INITIAL TIMESTEP_END'
  []

[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Kernels]
  #### Dry kernels
  [time_OT_dry]
    type = ADTimeDerivative
    variable = OT_concentration_dry
    extra_vector_tags = ref
  []
  [diffusion_OT_dry]
    type = ADMatDiffusion
    variable = OT_concentration_dry
    diffusivity = diffusivity_OT
    extra_vector_tags = ref
  []
  [time_V_O_dry]
    type = ADTimeDerivative
    variable = Oxygen_vacancy_concentration_dry
    extra_vector_tags = ref
  []
  [diffusion_V_O_dry]
    type = ADMatDiffusion
    variable = Oxygen_vacancy_concentration_dry
    diffusivity = diffusivity_V_O
    extra_vector_tags = ref
  []
  # voltage for OH
  [diffusion_phi_PCC_OH]
    type = ADMatDiffusion
    variable = OT_concentration_dry
    v = voltage_phi
    diffusivity = conductivity_OH
    extra_vector_tags = ref
  []
  # voltage for V_O
  [diffusion_phi_PCC_V_O]
    type = ADMatDiffusion
    variable = Oxygen_vacancy_concentration_dry
    v = voltage_phi
    diffusivity = conductivity_V_O
    extra_vector_tags = ref
  []
[]

[BCs]
  #### Dry BCs
  [left_OT_dry]
    type = ADMatNeumannBC
    variable = OT_concentration_dry
    boundary = left
    value = 1
    boundary_material = flux_on_OT_dry
  []
  [left_V_O_dry]
    type = ADMatNeumannBC
    variable = Oxygen_vacancy_concentration_dry
    boundary = left
    value = 1
    boundary_material = flux_on_V_O_dry
  []
  [right_OT_dry]
    type = ADMatNeumannBC
    variable = OT_concentration_dry
    boundary = right
    value = 1
    boundary_material = flux_on_OT_dry
  []
  [right_V_O_dry]
    type = ADMatNeumannBC
    variable = Oxygen_vacancy_concentration_dry
    boundary = right
    value = 1
    boundary_material = flux_on_V_O_dry
  []
[]

[Functions]
  [Temperature_function]
    type = ParsedFunction
    expression = '${temperature_initial}'
  []
  [Pressure_T2_dry_function]
    type = ParsedFunction
    expression = 'min(t / ${ramp_time}, 1.0) * (${pressure_T2_high} * (${length} - x) / ${length} + ${pressure_T2_low}) / ${pressure_atm}'
  []
  [Pressure_T2O_dry_function]
    type = ParsedFunction
    expression = 'min(t / ${ramp_time}, 1.0) * (${pressure_T2O_constant}) / ${pressure_atm}'
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
  [converter_to_nonAD]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_OT diffusivity_V_O diffusivity_e conductivity_OH conductivity_e'
    reg_props_out = 'diffusivity_OT_nonAD diffusivity_V_O_nonAD diffusivity_e_nonAD conductivity_OH_nonAD conductivity_e_nonAD'
    outputs = 'none'
  []
  [conductivity_OH]
    type = ADParsedMaterial
    property_name = 'conductivity_OH'
    coupled_variables = 'OT_concentration_dry temperature'
    material_property_names = 'diffusivity_OT'
    expression = 'diffusivity_OT * ${F} * OT_concentration_dry / ${R} / temperature'
  []
  [conductivity_V_O]
    type = ADParsedMaterial
    property_name = 'conductivity_V_O'
    coupled_variables = 'Oxygen_vacancy_concentration_dry temperature'
    material_property_names = 'diffusivity_V_O'
    expression = '2 * diffusivity_V_O * ${F} * Oxygen_vacancy_concentration_dry / ${R} / temperature'
  []
  [conductivity_e]
    type = ADParsedMaterial
    property_name = 'conductivity_e'
    coupled_variables = 'electron_concentration_dry temperature'
    material_property_names = 'diffusivity_e'
    expression = '- diffusivity_e * ${F} * electron_concentration_dry / ${R} / temperature'
  []
  [reaction_equilibrium_constant_T2]
    type = ADParsedMaterial
    property_name = 'T2_K_eq'
    coupled_variables = 'temperature'
    expression = 'exp( ( ${delta_H_T2} - temperature * ${delta_S_T2}) / ${R} / temperature )'
  []
  [reaction_forward_T2]
    type = ADParsedMaterial
    property_name = 'T2_K_forward'
    coupled_variables = 'temperature'
    expression = '${T2_reaction_forward_value} * exp(-${T2_reaction_forward_energy} / ${R} / temperature)'
  []
  [reaction_reverse_T2]
    type = ADParsedMaterial
    property_name = 'T2_K_reverse'
    material_property_names = 'T2_K_forward T2_K_eq'
    expression = 'T2_K_forward / T2_K_eq'
  []

  [reaction_equilibrium_constant_T2O]
    type = ADParsedMaterial
    property_name = 'T2O_K_eq'
    coupled_variables = 'temperature'
    expression = 'exp( ( ${delta_H_T2O} - temperature * ${delta_S_T2O}) / ${R} / temperature )'
  []
  [reaction_forward_T2O]
    type = ADParsedMaterial
    property_name = 'T2O_K_forward'
    coupled_variables = 'temperature'
    expression = '${T2O_reaction_forward_value} * exp(-${T2O_reaction_forward_energy} / ${R} / temperature)'
  []
  [reaction_reverse_T2O]
    type = ADParsedMaterial
    property_name = 'T2O_K_reverse'
    material_property_names = 'T2O_K_forward T2O_K_eq'
    expression = 'T2O_K_forward / T2O_K_eq'
  []

  #### Reaction for dry
  [flux_base_on_T2_dry] # T2 + 2 O -> 2 OT + 2 e
    type = ADDerivativeParsedMaterial
    coupled_variables = 'OT_concentration_dry pressure_T2_dry Oxygen_vacancy_concentration_dry electron_concentration_dry'
    property_name = 'flux_base_on_T2_dry'
    material_property_names = 'T2_K_forward T2_K_reverse'
    expression = '(T2_K_forward * pressure_T2_dry * (3 * ${N} - Oxygen_vacancy_concentration_dry)^2 - T2_K_reverse * OT_concentration_dry^2 * electron_concentration_dry^2)'
  []
  [flux_base_on_T2O_dry] # T2O + V_O + O -> 2 OT
    type = ADDerivativeParsedMaterial
    coupled_variables = 'OT_concentration_dry pressure_T2O_dry Oxygen_vacancy_concentration_dry'
    property_name = 'flux_base_on_T2O_dry'
    material_property_names = 'T2O_K_forward T2O_K_reverse'
    expression = '(T2O_K_forward * pressure_T2O_dry * (3 * ${N} - Oxygen_vacancy_concentration_dry) * Oxygen_vacancy_concentration_dry - T2O_K_reverse * OT_concentration_dry^2)'
  []


  #### Flux for dry
  [flux_on_e_dry] # electron
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_e_dry'
    material_property_names = 'flux_base_on_T2_dry'
    expression = '2 * flux_base_on_T2_dry'
  []
  [flux_on_OT_dry] # OT
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_OT_dry'
    material_property_names = 'flux_base_on_T2_dry flux_base_on_T2O_dry'
    expression = '2 * flux_base_on_T2_dry + 2 * flux_base_on_T2O_dry'
  []
  [flux_on_T2_dry] # T2
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_T2_dry'
    material_property_names = 'flux_base_on_T2_dry'
    expression = '-1 * flux_base_on_T2_dry'
  []
  [flux_on_V_O_dry] # V_O
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_V_O_dry'
    material_property_names = 'flux_base_on_T2O_dry'
    expression = '-1 * flux_base_on_T2O_dry'
  []
  [flux_on_T2O_dry] # T2O
    type = ADDerivativeParsedMaterial
    property_name = 'flux_on_T2O_dry'
    material_property_names = 'flux_base_on_T2O_dry'
    expression = '-1 * flux_base_on_T2O_dry'
  []
[]

[Postprocessors]
  #### Postprocessors for flux under dry
  [recombination_flux_T2_dry_left]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_T2_dry
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv'
  []
  [recombination_flux_T2O_dry_left]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_T2O_dry
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv'
  []
  [recombination_flux_OT_dry_left]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_on_OT_dry
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv'
  []
  [recombination_flux_OT_dry_right]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_OT_dry
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv'
  []
  [recombination_flux_T2O_dry_right]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_T2O_dry
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv'
  []
  [recombination_flux_T2_dry_right]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_on_T2_dry
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'console csv'
  []

  # necessary parameters
  [T2_K_eq_average]
    type = ADElementAverageMaterialProperty
    mat_prop = T2_K_eq
  []
  [T2_K_forward_average]
    type = ADElementAverageMaterialProperty
    mat_prop = T2_K_forward
  []
  [T2_K_reverse_average]
    type = ADElementAverageMaterialProperty
    mat_prop = T2_K_reverse
  []
  [T2O_K_eq_average]
    type = ADElementAverageMaterialProperty
    mat_prop = T2O_K_eq
  []
  [T2O_K_forward_average]
    type = ADElementAverageMaterialProperty
    mat_prop = T2O_K_forward
  []
  [T2O_K_reverse_average]
    type = ADElementAverageMaterialProperty
    mat_prop = T2O_K_reverse
  []
  [diffusivity_OT_average]
    type = ADElementAverageMaterialProperty
    mat_prop = diffusivity_OT
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [diffusivity_V_O_average]
    type = ADElementAverageMaterialProperty
    mat_prop = diffusivity_V_O
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [temperature_average]
    type = ElementAverageValue
    variable = temperature
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [voltage_value]
    type = ParsedPostprocessor
    expression = ${V_current}
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [pressure_T2_average]
    type = ElementAverageValue
    variable = pressure_T2_dry
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [log_error_sq]
    type = ParsedPostprocessor
    pp_names = 'recombination_flux_OT_dry_right'
    expression = '(log(abs(recombination_flux_OT_dry_right * 1e18)) - log(${target_flux}))^2'
    execute_on = 'TIMESTEP_END'
  []
  [relative_error_sq]
    type = ParsedPostprocessor
    pp_names = 'recombination_flux_OT_dry_right'
    expression = '(abs(recombination_flux_OT_dry_right * 1e18) - ${target_flux})^2'
    execute_on = 'TIMESTEP_END'
  []
[]

[Controls]
  [stochastic]
    type = SamplerReceiver
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -snes_type'
  petsc_options_value = 'lu vinewtonrsls'
  nl_rel_tol = 5e-6
  nl_abs_tol = 5e-7
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = true
  line_search = none
  error_on_dtmin = false  # must stay false for ignore_solve_not_converge to work in Level 2
  abort_on_solve_fail = true  # fast-fail on first NL divergence; prevents stutter at dtmin
  dtmin = 1e-10
  nl_max_its = 20
  dtmax = ${dt_max}
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start_charging}
    optimal_iterations = 15
    growth_factor = 2.0
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.5
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = false
  [csv]
    type = CSV
  []
  # [exodus]
  #   type = Exodus
  # []
[]
