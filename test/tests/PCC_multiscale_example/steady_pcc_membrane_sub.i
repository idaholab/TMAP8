# Sub-app (component level) for the PCC membrane <-> fuel-cycle MultiApp coupling.
# Derived from tritium_transport_PCC/jouleheating_Voltage_BCY_real_LEE2005.i.
# Real (H2+H2O) BCY proton-conducting-ceramic membrane with applied voltage and Joule heating.
# Temperature is a nonlinear Variable coupled to the Joule heating source.
#
# Unit system: the membrane model uses nm for length, Pa for gas pressure, at/nm^3 for
# concentrations, at/nm^2/s for surface fluxes, and kg/s for transferred tritium flow.
#
# Coupling interface:
#   IN  (from parent): received_pressure  -- upstream T2 partial pressure [Pa] set from the
#                      fuel-cycle membrane feed-plenum holdup (T_11_membrane) via ideal gas.
#   OUT (to parent):   permeation_rate_kg_per_s -- tritium mass flow permeated to the downstream
#                      side [kg/s], obtained from the steady permeation flux at the right boundary.
# The sub-app is run to (pseudo-)steady state each parent timestep (see steady_state_detection).

# Physical constants
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h
N_a = '${units 6.02214076e23 at/mol}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h
q = '${units 1.602176634e-19 C}' # quantity of charge
F = '${fparse N_a * q}'

# Thermal properties of BCY20
# thermal conductivity: 1.05 W/(m*K) for dense BaCeO3
# Ref: Tenevich et al. 2023, Ceramics International, Vol. 49, 31087-31095
thermal_conductivity_BCY20 = '${units 1.05 W/m/K -> W/nm/K}'

# thermal parameters
temperature_initial = '${units 773 K}' # 500C

# Model parameters
endtime = '140'
dt_max = '2e0'
dt_start_charging = '${units 1e-5 s}'
bound_value_min = '${units -1e-20 at/nm^3}'

# Geometry and mesh
length = '${units 10 mum -> nm}' # BCY20
num_nodes = 300

# Material properties
density_BCY20 = '${units ${fparse 1.0 * 6.154} g/cm^3 -> g/m^3}'
molar_mass_BCY20 = '${units 283.42 g/mol}'
N = '${units ${fparse density_BCY20 / molar_mass_BCY20 * N_a} at/m^3 -> at/nm^3}'
# density in g/nm^3 for pairing with specific_heat in J/(g*K)
density_BCY20_thermal = '${fparse density_BCY20 * 1e-27}' # g/m^3 -> g/nm^3
# specific heat: ~120 J/(mol*K) for BaCeO3 at high temperature
# Ref: Yamanaka et al. 2003, J. Alloys and Compounds, Vol. 359, 109-113
specific_heat_BCY20_molar = '${units 120 J/mol/K}'
specific_heat_BCY20 = '${fparse specific_heat_BCY20_molar / molar_mass_BCY20}' # 120/283.42 = 0.4233 J/(g*K)

# Initial concentrations
OT_concentration_initial = 1e-5
hydration_limit_S = 0.2
oxygen_vacancy_concentration_initial = '${units ${fparse hydration_limit_S / 2 * N} at/nm^3}'
oxygen_concentration_initial = '${units ${fparse 3 * N - oxygen_vacancy_concentration_initial - OT_concentration_initial} at/nm^3}'

##### Dry Pressure conditions
pressure_atm = '${units 101315 Pa}'
pressure_T2_low = '${units 0 Pa}'      # downstream (permeate) T2 partial pressure
pressure_T2_high = '${units ${fparse 5 / 101315 * pressure_atm} Pa}' # default standalone upstream T2 pressure
# In the fuel-cycle coupling the membrane separates tritium (T2): permeation must be driven only by
# the tritium partial pressure supplied by the parent. The independent water (T2O) source of the
# "real" model is therefore disabled (set to 0) so it does not inject a tritium-independent,
# voltage-pumped baseline flux. Set non-zero only for standalone wet-gas studies.
pressure_T2O_constant = '${units 0 Pa}'

# chemical_reaction — n20_faster optimized parameters (71 steps)
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

# --- MultiApp coupling: feed-plenum bridge parameters (sub-app side) ---
# The membrane active area scales the permeation flux [at/m^2/s] to a tritium mass flow [kg/s].
# A_membrane must be physically paired with the parent feed-plenum volume V_feed: together they
# set the coupling gain. Documented placeholder; calibrate against a target membrane inventory.
# A_membrane is calibrated so the steady operating pressure sits in the well-behaved 10-80 kPa
# range given the fuel-cycle TES feed (~7e-7 kg/s). ~20 cm^2 is a realistic lab-membrane area.
A_membrane = '${units 2e-2 m^2}'      # 2.0e-3 membrane active area (TUNING PARAMETER; pair with V_feed)
M_T_atomic = '${units 3.016e-3 kg/mol}' # atomic tritium molar mass (each OT carries one T atom)

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
  # Temperature as nonlinear variable (promoted from AuxVariable for Joule heating coupling)
  [temperature]
    initial_condition = ${temperature_initial}
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
  [temperature_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = temperature
    bound_type = lower
    bound_value = 300
  []
  [temperature_upper_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = temperature
    bound_type = upper
    bound_value = 2000
  []
[]

[AuxVariables]
  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
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

  # --- Heat equation ---
  [heat_time]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    specific_heat = specific_heat_BCY20
    density_name = density_BCY20_thermal
    extra_vector_tags = ref
  []
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
    thermal_conductivity = thermal_conductivity_BCY20
    extra_vector_tags = ref
  []
  [joule_heating]
    type = ADJouleHeatingSource
    variable = temperature
    heating_term = joule_heating_Q
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

  # Thermal BCs: fixed temperature at both surfaces (furnace-controlled)
  [left_temperature]
    type = ADDirichletBC
    variable = temperature
    boundary = left
    value = ${temperature_initial}
  []
  [right_temperature]
    type = ADDirichletBC
    variable = temperature
    boundary = right
    value = ${temperature_initial}
  []
[]

[Functions]
  [Pressure_T2_dry_function]
    # P_up (upstream T2 partial pressure, Pa) is supplied by the parent via the received_pressure
    # postprocessor. The time ramp of the standalone model is removed here: FullSolveMultiApp
    # warm-starts the sub-app (keeps the solution between invocations) while resetting sub-time to 0,
    # so a time ramp would re-impose a zero-pressure shock onto an already-equilibrated field and
    # stall the solve. The pressure is therefore applied as a constant with the same spatial
    # (upstream->permeate) profile and /pressure_atm normalization.
    type = ParsedFunction
    symbol_names = 'P_up'
    symbol_values = 'received_pressure'
    expression = '(P_up * (${length} - x) / ${length} + ${pressure_T2_low}) / ${pressure_atm}'
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

  # --- Thermal material properties for BCY20 ---
  [thermal_conductivity_mat]
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity_BCY20'
    prop_values = '${thermal_conductivity_BCY20}'
  []
  [specific_heat_mat]
    type = ADGenericConstantMaterial
    prop_names = 'specific_heat_BCY20'
    prop_values = '${specific_heat_BCY20}'
  []
  [density_thermal_mat]
    type = ADGenericConstantMaterial
    prop_names = 'density_BCY20_thermal'
    prop_values = '${density_BCY20_thermal}'
  []

  # --- Joule heating ---
  # Total ionic electrical conductivity from Nernst-Einstein relation (excluding electrons)
  # sigma = q*F/(R*T) * (z_OH^2 * D_OT * c_OT + z_VO^2 * D_VO * c_VO)
  # z_OH = 1, z_VO = 2, so z^2 = 1 and 4
  [total_electrical_conductivity]
    type = ADParsedMaterial
    property_name = 'sigma_total'
    coupled_variables = 'OT_concentration_dry Oxygen_vacancy_concentration_dry temperature'
    material_property_names = 'diffusivity_OT diffusivity_V_O'
    expression = '${q} * ${F} / (${R} * temperature) * (diffusivity_OT * OT_concentration_dry + 4.0 * diffusivity_V_O * Oxygen_vacancy_concentration_dry)'
  []
  # Joule heating volumetric source: Q = sigma_total * |grad(phi)|^2
  # |grad(phi)|^2 = (V_current / length)^2 = constant (voltage_phi is linear AuxVariable)
  [joule_heating_material]
    type = ADParsedMaterial
    property_name = 'joule_heating_Q'
    material_property_names = 'sigma_total'
    expression = 'sigma_total * (${V_current} / ${length})^2'
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

  # --- MultiApp coupling postprocessors ---
  [received_pressure] # upstream T2 partial pressure [Pa] received from the parent fuel-cycle model
    type = Receiver
    default = ${pressure_T2_high} # fallback so standalone runs reproduce the base feed pressure
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
  [permeation_rate_kg_per_s] # tritium mass flow permeated to the downstream side [kg/s]
    # The downstream-boundary OT flux is negative when tritium permeates OUT to the permeate side,
    # so the forward permeation rate is max(-flux, 0): only net downstream transport is recovered.
    # flux[at/nm^2/s] * 1e18 -> at/m^2/s ; * A_membrane[m^2] -> at/s ; * M_T_atomic/N_a -> kg/s
    type = ParsedPostprocessor
    pp_names = 'recombination_flux_OT_dry_right'
    expression = 'max(-recombination_flux_OT_dry_right, 0) * 1e18 * ${A_membrane} * ${M_T_atomic} / ${N_a}'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  # Joule heating diagnostics
  [temperature_max]
    type = ElementExtremeValue
    variable = temperature
    value_type = max
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [temperature_min]
    type = ElementExtremeValue
    variable = temperature
    value_type = min
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [delta_T]
    type = ParsedPostprocessor
    pp_names = 'temperature_max temperature_min'
    expression = 'temperature_max - temperature_min'
    execute_on = 'TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  scheme = implicit-euler
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -snes_type'
  petsc_options_value = 'lu vinewtonrsls'
  nl_rel_tol = 5e-6
  # Slightly looser absolute tolerance than the standalone model: when driven across the full range
  # of upstream pressures by the fuel cycle, the residual can stall just above 5e-7 in some states.
  # 1e-6 (still 3+ orders below the initial residual) converges reliably without affecting the flux.
  nl_abs_tol = 1e-6
  end_time = ${endtime}
  # Run to (pseudo-)steady permeation each time the parent invokes this sub-app, then terminate
  # early. end_time is a hard cap; steady_state_start_time avoids declaring steady state during
  # the upstream-pressure ramp (ramp_time).
  # steady_state_detection = true
  # steady_state_tolerance = 1e-6
  # steady_state_start_time = '${fparse 10 * ramp_time}'
  automatic_scaling = true
  compute_scaling_once = true
  line_search = none
  error_on_dtmin = false  # must stay false for ignore_solve_not_converge to work in Level 2
  abort_on_solve_fail = true  # fast-fail on first NL divergence; prevents stutter at dtmin
  dtmin = 1e-10
  nl_max_its = 60
  dtmax = ${dt_max}
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start_charging}
    optimal_iterations = 20
    growth_factor = 1.5
    cutback_factor = 0.5
    cutback_factor_at_failure = 0.5
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = false
  # Save the membrane result for every fuel-cycle step into the membrane_steps/ subfolder. The parent
  # MultiApp sets keep_full_output_history = true so this CSV is accumulated (not overwritten) across
  # all steps, letting the membrane solution be inspected for correctness.
  file_base = 'membrane_steps/membrane_5_Pa_flux'
  [csv]
    type = CSV
  []
[]
