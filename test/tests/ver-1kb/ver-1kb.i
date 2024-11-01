nb_segments_TMAP7 = 20
node_size_TMAP7 = '${units 1.25e-5 m}'
long_total = '${fparse nb_segments_TMAP7 * node_size_TMAP7}' # m
nb_segments_TMAP8 = 100
node_size_TMAP8 = '${fparse long_total / nb_segments_TMAP8}' # m
simulation_time = '${units 10000 s}'
temperature = '${units 500 K}'
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant from PhysicalConstants.h
initial_pressure_1 = '${units 1e5 Pa}'
initial_pressure_2 = '${units 1e-10 Pa}'
initial_concentration_1 = '${units ${fparse initial_pressure_1 / (R*temperature)} mol/m^3}'
initial_concentration_2 = '${units ${fparse initial_pressure_2 / (R*temperature)} mol/m^3}'
solubility = '${units ${fparse 1/(R*temperature)} mol/m^3/Pa}' # Henry's law solubility
diffusivity = '${units ${fparse 4.31e-6 * exp(-2818/temperature)} m^2/s}'
n_sorption = 1
unit_scale = 1
unit_scale_neighbor = 1

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${nb_segments_TMAP8}
    xmax = ${long_total}
  []
  [enclosure_1]
    type = SubdomainBoundingBoxGenerator
    input = generated
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '${fparse 1/3 * long_total} 0 0'
  []
  [enclosure_2]
    type = SubdomainBoundingBoxGenerator
    input = enclosure_1
    block_id = 2
    bottom_left = '${fparse 1/3 * long_total} 0 0'
    top_right = '${fparse long_total} 0 0'
  []
  [breakmesh]
    input = enclosure_2
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
    add_interface_on_two_sides = true
  []
[]

[Variables]
  [concentration_enclosure_1]
    block = 1
    order = FIRST
    family = LAGRANGE
    initial_condition = '${initial_concentration_1}'
  []
  [concentration_enclosure_2]
    block = 2
    order = FIRST
    family = LAGRANGE
    initial_condition = '${initial_concentration_2}'
  []
[]

[AuxVariables]
  [pressure_enclosure_1]
    order = CONSTANT
    family = MONOMIAL
    block = 1
    initial_condition = '${initial_pressure_1}'
  []
  [pressure_enclosure_2]
    order = CONSTANT
    family = MONOMIAL
    block = 2
    initial_condition = '${initial_pressure_2}'
  []
[]

[Kernels]
  [diffusion_enclosure_1]
    type = MatDiffusion
    variable = concentration_enclosure_1
    diffusivity = ${diffusivity}
    block = '1'
  []
  [time_enclosure_1]
    type = TimeDerivative
    variable = concentration_enclosure_1
    block = '1'
  []
  [diffusion_enclosure_2]
    type = MatDiffusion
    variable = concentration_enclosure_2
    diffusivity = ${diffusivity}
    block = '2'
  []
  [time_enclosure_2]
    type = TimeDerivative
    variable = concentration_enclosure_2
    block = '2'
  []
[]

[AuxKernels]
  [pressure_enclosure_1]
    type = ParsedAux
    variable = pressure_enclosure_1
    coupled_variables = 'concentration_enclosure_1'
    expression = '${fparse R*temperature}*concentration_enclosure_1'
    block = 1
    execute_on = 'initial timestep_end'
  []
  [pressure_enclosure_2]
    type = ParsedAux
    variable = pressure_enclosure_2
    coupled_variables = 'concentration_enclosure_2'
    expression = '${fparse R*temperature}*concentration_enclosure_2'
    block = 2
    execute_on = 'initial timestep_end'
  []
[]

[InterfaceKernels]
  [interface_sorption]
    type = InterfaceSorption
    K0 = ${solubility}
    Ea = 0
    n_sorption = ${n_sorption}
    diffusivity = ${diffusivity}
    unit_scale = ${unit_scale}
    unit_scale_neighbor = ${unit_scale_neighbor}
    temperature = ${temperature}
    variable = concentration_enclosure_2
    neighbor_var = concentration_enclosure_1
    sorption_penalty = 1e1
    boundary = Block2_Block1
  []
[]

[Postprocessors]
  [pressure_enclosure_1]
    type = ElementAverageValue
    variable = pressure_enclosure_1
    block = 1
    execute_on = 'initial timestep_end'
  []
  [pressure_enclosure_2]
    type = ElementAverageValue
    variable = pressure_enclosure_2
    block = 2
    execute_on = 'initial timestep_end'
  []
  [concentration_enclosure_1_at_interface]
    type = PointValue
    variable = concentration_enclosure_1
    point = '${fparse 1/3 * long_total - node_size_TMAP8} 0 0'
    outputs = 'csv console'
    execute_on = 'initial timestep_end'
  []
  [concentration_enclosure_2_at_interface]
    type = PointValue
    variable = concentration_enclosure_2
    point = '${fparse 1/3 * long_total + node_size_TMAP8} 0 0'
    outputs = 'csv console'
    execute_on = 'initial timestep_end'
  []
  [pressure_enclosure_1_at_interface]
    type = PointValue
    variable = pressure_enclosure_1
    point = '${fparse 1/3 * long_total - node_size_TMAP8} 0 0'
    outputs = 'csv console'
    execute_on = 'initial timestep_end'
  []
  [pressure_enclosure_2_at_interface]
    type = PointValue
    variable = pressure_enclosure_2
    point = '${fparse 1/3 * long_total + node_size_TMAP8} 0 0'
    outputs = 'csv console'
    execute_on = 'initial timestep_end'
  []
  [concentration_encl_1_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = concentration_enclosure_1
    block = 1
    execute_on = 'initial timestep_end'
  []
  [concentration_encl_2_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = concentration_enclosure_2
    block = 2
    execute_on = 'initial timestep_end'
  []
  [mass_conservation_sum_encl1_encl2]
    type = LinearCombinationPostprocessor
    pp_names = 'concentration_encl_1_inventory concentration_encl_2_inventory'
    pp_coefs = '1            1'
    execute_on = 'initial timestep_end'
  []
[]

[Executioner]
  type = Transient
  end_time = ${simulation_time}
  dtmax = 10
  nl_abs_tol = 1e-14
  nl_rel_tol = 1e-10
  scheme = 'bdf2'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_max_its = 6
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 4
    iteration_window = 1
    growth_factor = 1.1
    cutback_factor_at_failure = 0.9
  []
[]

[Outputs]
  file_base = 'ver-1kb_out_k1'
  csv = true
  execute_on = 'initial timestep_end'
[]
