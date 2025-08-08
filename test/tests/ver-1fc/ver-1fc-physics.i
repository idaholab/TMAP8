T_SA = 600 # K
T_SB = 0 # K
L_A = 40e-2 # m
L_B = 40e-2 # m
k_A = 401 # W/m/K
k_B = 80.2 # W/m/K
num_nodes = 800 # (-)
position_measurement = 9e-2 # m

density_Cu = 8960 # kg/m^3
specific_heat_Cu = 383.8 # J/kg/K
density_Fe = 7870 # kg/m^3
specific_heat_Fe = 447.0 # J/kg/K

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

[Physics]
  [HeatConduction]
    [h1]
      temperature_name = 'temperature'

      initial_temperature = 0

      # Thermal properties
      thermal_conductivity = 'thermal_conductivity'

      # Boundary conditions
      fixed_temperature_boundaries = 'right left'
      boundary_temperatures = '${T_SB} ${T_SA}'
      # default preconditioning does not work
      preconditioning = 'defer'
    []
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

[Materials]
  [specific_heat_Cu]
    type = ADGenericConstantMaterial
    block = '0'
    prop_names = 'density specific_heat'
    prop_values = '${density_Cu} ${specific_heat_Cu}'
  []
  [specific_heat_Fe]
    type = ADGenericConstantMaterial
    block = '1'
    prop_names = 'density specific_heat'
    prop_values = '${density_Fe} ${specific_heat_Fe}'
  []
  [thermal_conductivity_Cu]
    type = ADGenericFunctionMaterial
    block = '0'
    prop_values = thermal_conductivity_func_Cu
    prop_names = thermal_conductivity
    outputs = exodus
  []
  [thermal_conductivity_Fe]
    type = ADGenericFunctionMaterial
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
  nl_abs_tol = 1e-6
  dtmax = 5e2
  end_time = 10000
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
