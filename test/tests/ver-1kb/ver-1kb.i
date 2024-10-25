nb_segments = 20
long_segment = ${units 1.25e-5 m}
long_total = ${fparse nb_segments * long_segment} # m
simulation_time = ${units 10000 s}
T = ${units 500 K}
R = ${units 8.31446261815324 J/mol/K} # ideal gas constant from PhysicalConstants.h
Na = ${units 6.02214076e23 /mol} # Avogadro's number from /PhysicalConstants.h
initial_pressure_1 = ${units 1e5 Pa} 
initial_pressure_2 = ${units 1e-10 Pa}  
initial_concentration_1 = ${fparse initial_pressure_1 / (R*T)} # mol/m^3
initial_concentration_2 = ${fparse initial_pressure_2 / (R*T)} # mol/m^3
solubility = ${fparse 1.082e20/Na} # Henry's law constant J/mol
diffusivity = ${fparse 4.31e-6 * exp(-2818/T)} # m^2/s
n_sorption = 1
unit_scale = 1
unit_scale_neighbor = 1

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${fparse nb_segments}
    xmax = ${fparse long_total}
  []
  [left_block]
    type = SubdomainBoundingBoxGenerator
    input = generated
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '${fparse 1/3 * long_total} 0 0'
  []
  [right_block]
    type = SubdomainBoundingBoxGenerator
    input = left_block
    block_id = 2
    bottom_left = '${fparse 1/3 * long_total} 0 0'
    top_right = '${fparse long_total} 0 0'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = right_block
    primary_block = 1
    paired_block = 2
    new_boundary = interface
  []
[]

[Variables]
  [concentration_enclosure_1]
    block = 1
    order = FIRST
    family = LAGRANGE
    initial_condition = '${fparse initial_concentration_1}'
  []
  [concentration_enclosure_2]
    block = 2
    order = FIRST
    family = LAGRANGE
    initial_condition = '${fparse initial_concentration_2}'
  []
[]

[AuxVariables]
  [pressure_enclosure_1]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [pressure_enclosure_2]
    order = CONSTANT
    family = MONOMIAL
    block = 2
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
    expression = '${fparse R*T}*concentration_enclosure_1'
    block = 1
  []
  [pressure_enclosure_2]
    type = ParsedAux
    variable = pressure_enclosure_2
    coupled_variables = 'concentration_enclosure_2'
    expression = '${fparse R*T}*concentration_enclosure_2'
    block = 2
  []
[]

[InterfaceKernels]
  [interface_diffusion]
    type = InterfaceDiffusion
    variable = concentration_enclosure_1
    neighbor_var = concentration_enclosure_2
    boundary = interface
    D = ${diffusivity}  
    D_neighbor = ${diffusivity}
  []
  [interface_sorption]
    type = InterfaceSorption
    K0 = ${solubility}                    
    Ea = 0
    n_sorption = ${n_sorption}
    diffusivity = ${diffusivity}
    unit_scale = ${unit_scale}
    unit_scale_neighbor = ${unit_scale_neighbor}
    temperature = ${fparse T}
    variable = concentration_enclosure_1
    neighbor_var = concentration_enclosure_2
    sorption_penalty = 1e1
    boundary = interface
  []
[]

[Postprocessors]
  [pressure_enclosure_1]
    type = ElementAverageValue
    variable = pressure_enclosure_1
    block = 1
  []
  [pressure_enclosure_2]
    type = ElementAverageValue
    variable = pressure_enclosure_2
    block = 2
  []
[]

[Executioner]
  type = Transient
  dt = 100
  end_time = ${simulation_time}
  dtmax = 10
  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-6
  scheme = 'bdf2'
  petsc_options_iname = '-ksp_type -pc_type'
  petsc_options_value = 'gmres ilu'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 8
    growth_factor = 1.1
    cutback_factor = 0.5
  []
[]

[Outputs]
  file_base = 'ver-1kb_out'
  csv = true
[]