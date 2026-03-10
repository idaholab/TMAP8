# Verification Problem #1fc from TMAP7 V&V document
# Thermal conduction in composite structure with constant surface temperatures

# Data used in TMAP7 case
T_SA = '${units 600 K}'
T_SB = '${units 0 K}'
L_A = '${units 0.4 m}'
L_B = '${units 0.4 m}'
k_A = '${units 401 W/m/K}'
k_B = '${units 80.2 W/m/K}'
position_measurement = '${units 9e-2 m}'
density_Cu = '${units 8960 kg/m^3}'
specific_heat_Cu = '${units 383.8 J/kg/K}'
density_Fe = '${units 7870 kg/m^3}'
specific_heat_Fe = '${units 447.0 J/kg/K}'

# Data selected for TMAP8 case
num_nodes = 800 # (-)
simulation_time = '${units 10000 s}'

[Mesh]
  [whole_domain]
    type = GeneratedMeshGenerator
    xmin = 0
    xmax = '${fparse L_A + L_B}'
    dim = 1
    nx = ${num_nodes}
  []
  [injection_block_1]
    type = ParsedSubdomainMeshGenerator
    input = whole_domain
    combinatorial_geometry = 'x < ${L_A}'
    block_id = 0
  []
  [injection_block_2]
    type = ParsedSubdomainMeshGenerator
    input = injection_block_1
    combinatorial_geometry = 'x > ${L_A}'
    block_id = 1
  []
[]

[Variables]
  # temperature parameter in the slab in K
  [temperature]
    initial_condition = 0.0
    scaling = 1e-6
  []
[]

[Functions]
  [thermal_conductivity_func_Cu]
    type = ParsedFunction
    expression = ${k_A}
  []
  [thermal_conductivity_func_Fe]
    type = ParsedFunction
    expression = ${k_B}
  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temperature
  []
  [HeatTdot]
    type = HeatConductionTimeDerivative
    variable = temperature
  []
[]

[BCs]
  # The temperature on the left boundary of the slab is kept constant
  [lefttemperature]
    type = DirichletBC
    boundary = left
    variable = temperature
    value = ${T_SA}
  []
  # The temperature on the right boundary of the slab is kept constant
  [righttemperature]
    type = DirichletBC
    boundary = right
    variable = temperature
    value = ${T_SB}
  []
[]

[Materials]
  # the specific heat of Cu layer
  [specific_heat_Cu]
    type = GenericConstantMaterial
    block = '0'
    prop_names = 'density specific_heat'
    prop_values = '${density_Cu} ${specific_heat_Cu}'
  []
  # the specific heat of Fe layer
  [specific_heat_Fe]
    type = GenericConstantMaterial
    block = '1'
    prop_names = 'density specific_heat'
    prop_values = '${density_Fe} ${specific_heat_Fe}'
  []
  # the thermal conductivity of Cu layer
  [thermal_conductivity_Cu]
    type = GenericFunctionMaterial
    block = '0'
    prop_values = thermal_conductivity_func_Cu
    prop_names = thermal_conductivity
    outputs = exodus
  []
  # the thermal conductivity of Fe layer
  [thermal_conductivity_Fe]
    type = GenericFunctionMaterial
    block = '1'
    prop_values = thermal_conductivity_func_Fe
    prop_names = thermal_conductivity
    outputs = exodus
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
  nl_rel_tol = 1e-50
  nl_abs_tol = 1e-12
  l_tol = 1e-8
  dtmax = 5e2
  end_time = '${simulation_time}'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-1
    optimal_iterations = 3
    iteration_window = 1
    growth_factor = 1.2
    cutback_factor = 0.8
  []
[]

[Postprocessors]
  # Used to obtain varying temperature with time at x=0.09 m
  [temperature_at_x]
    type = PointValue
    variable = temperature
    point = '${position_measurement} 0 0'
    outputs = 'csv'
  []
[]

[VectorPostprocessors]
  # Used to obtain the temperature distribution with time at corresponding time
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${fparse L_A + L_B} 0 0'
    num_points = ${num_nodes}
    sort_by = 'x'
    variable = temperature
    outputs = vector_postproc
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = 'ver-1fc_temperature_at_x0.09'
  []
  [vector_postproc]
    type = CSV
    sync_times = '150 10000'
    sync_only = true
  []
[]
