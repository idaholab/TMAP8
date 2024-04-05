T_SA = 600 # K
T_SB = 0 # K
L_A = 40e-2 # m
L_B = 40e-2 # m
k_A = 401 # W/m/K
k_B = 80.2 # W/m/K
num_nodes = 800 # (-)
position_measurement = 9e-2 # m

[Mesh]
  [whole_domain]
    type = GeneratedMeshGenerator
    xmin = 0
    xmax = ${fparse L_A + L_B}
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
  [temperature]
    initial_condition = 0.0
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
  [lefttemperature]
    type = DirichletBC
    boundary = left
    variable = temperature
    value = ${T_SA}
  []
  [righttemperature]
    type = DirichletBC
    boundary = right
    variable = temperature
    value = ${T_SB}
  []
[]

[Materials]
  [specific_heat_Cu]
    type = GenericConstantMaterial
    block = '0'
    prop_names = 'density specific_heat'
    prop_values = '8940.0 384.70'
  []
  [specific_heat_Fe]
    type = GenericConstantMaterial
    block = '1'
    prop_names = 'density specific_heat'
    prop_values = '7860.0 447.57'
  []
  [thermal_conductivity_Cu]
    type = GenericFunctionMaterial
    block = '0'
    prop_values = thermal_conductivity_func_Cu
    prop_names = thermal_conductivity
    outputs = exodus
  []
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
  dtmax = 1e3
  end_time = 10000
  automatic_scaling = true
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 6
    growth_factor = 1.1
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
