# Global parameters
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant from PhysicalConstants.h
simulation_time = '${units 140000 s}'
temperature = '${units 823 K}'

# Sorption law parameters
n_sorption = 1 # Henry's law power
unit_scale = 1
unit_scale_neighbor = 1

# Materials properties
## diffusivity of tritium in FLiBe
D_FLiBe_prefactor = '${units 9.3e-7 m^2/s}'
D_FLiBe_energy = '${units 42e3 J/mol}'
D_FLiBe = '${units ${fparse D_FLiBe_prefactor * exp(- D_FLiBe_energy / (R*temperature))} m^2/s}'
## diffusivity of tritium in nickel
D_Ni_prefactor = '${units 7e-7 m^2/s}'
D_Ni_energy = '${units 39.5e3 J/mol}'
D_Ni = '${units ${fparse D_Ni_prefactor * exp(- D_Ni_energy / (R*temperature))} m^2/s}'
## Sieverts' law solubility for tritium in nickel
K_s_Ni_prefactor = '${units 564e-3 mol/m^3/Pa^0.5}'
K_s_Ni_energy = '${units 15.8e3 J/mol}'
K_s_Ni = '${units ${fparse K_s_Ni_prefactor * exp(- K_s_Ni_energy / (R*temperature))} mol/m^3/Pa^0.5}'
## Henry's law solubility for tritium in FLiBe
K_s_FLiBe_prefactor = '${units 7.9e-2 mol/m^3/Pa}'
K_s_FLiBe_energy = '${units 35e3 J/mol}'
K_s_FLiBe = '${units ${fparse K_s_FLiBe_prefactor * exp(- K_s_FLiBe_energy / (R*temperature))} mol/m^3/Pa}'

# K_d_Ni = '${units 1.9e-8 mol/m^2/s/Pa}' # surface rate of tritium in nickel

# Initial conditions
initial_pressure = '${units 1210 Pa}' # input pressure
initial_pressure_Ni = '${units 1e-10 Pa}' # initial pressure in the nickel membrane
initial_concentration_Ni = '${units ${fparse initial_pressure_Ni / (R*temperature)} mol/m^3}'
initial_pressure_FLiBe = '${units 1e-10 Pa}' # initial pressure in FLiBe
initial_concentration_FLiBe = '${units ${fparse initial_pressure_FLiBe / (R*temperature)} mol/m^3}'

# Geometry and mesh
length_Ni = '${units 2 mm -> m}' # Ni membrane thickness
num_nodes_Ni = 10
length_FLiBe = '${units 81 mm -> m}' # FLiBe membrane thickness
num_nodes_FLiBe = 100

[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${length_Ni} ${length_FLiBe}'
    ix = '${num_nodes_Ni} ${num_nodes_FLiBe}'
    subdomain_id = '1 2'
  []
  [interface_Ni_FLiBe]
    type = SideSetsBetweenSubdomainsGenerator
    input = cmg
    primary_block = '1'
    paired_block = '2'
    new_boundary = 'interface_Ni_FLiBe'
  []
  [interface_Ni_FLiBe_other_side]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface_Ni_FLiBe
    primary_block = '2'
    paired_block = '1'
    new_boundary = 'interface_Ni_FLiBe_other_side'
  []
[]

[Variables]
  [tritium_concentration_Ni]
    initial_condition = ${initial_concentration_Ni} # mol/m^3
    block = 1
  []
  [tritium_concentration_FLiBe]
    initial_condition = ${initial_concentration_FLiBe} # mol/m^3
    block = 2
  []
[]

[Kernels]
  # Diffusion in Ni membrane
  [diffusion_Ni]
    type = ADMatDiffusion
    variable = tritium_concentration_Ni
    diffusivity = ${D_Ni}
    block = 1
  []
  [time_diff_Ni]
    type = TimeDerivative
    variable = tritium_concentration_Ni
    block = 1
  []
  # Diffusion in FLiBe
  [diffusion_FLiBe]
    type = ADMatDiffusion
    variable = tritium_concentration_FLiBe
    diffusivity = ${D_FLiBe}
    block = 2
  []
  [time_diff_FLiBe]
    type = TimeDerivative
    variable = tritium_concentration_FLiBe
    block = 2
  []
[]

[BCs]
  [left_concentration]
    type = ADDirichletBC
    boundary = left
    variable = tritium_concentration_Ni
    value = '${fparse K_s_Ni * (initial_pressure)^0.5}'
  []
[]

[InterfaceKernels]
  [interface_sorption_Ni_FLiBe]
    type = InterfaceSorption
    K0 = ${K_s_FLiBe}
    Ea = 0
    n_sorption = ${n_sorption}
    diffusivity = ${D_Ni}
    unit_scale = ${unit_scale}
    unit_scale_neighbor = ${unit_scale_neighbor}
    temperature = ${temperature}
    variable = tritium_concentration_Ni
    neighbor_var = tritium_concentration_FLiBe
    sorption_penalty = 1e1
    boundary = 'interface_Ni_FLiBe'
  []
[]

[Functions]
  [max_dt_size_function]
    type = ParsedFunction
    expression = 'if(t<${fparse 8500}, ${fparse 1e2},
                  if(t<${fparse 37000}, ${fparse 1e1},
                  if(t<${fparse 38500}, ${fparse 1e0}, ${fparse 1e1})))'
  []
[]

[Postprocessors]
  [avg_flux_left]
    type = SideDiffusiveFluxAverage
    variable = tritium_concentration_Ni
    boundary = 'left'
    diffusivity = ${D_Ni}
  []
  [avg_flux_right]
    type = SideDiffusiveFluxAverage
    variable = tritium_concentration_Ni
    boundary = 'interface_Ni_FLiBe'
    diffusivity = ${D_Ni}
  []
  [Ni_left]
    type = SideAverageValue
    boundary = left
    variable = tritium_concentration_Ni
    execute_on = 'initial timestep_end'
  []
  [Ni_interface]
    type = SideAverageValue
    boundary = interface_Ni_FLiBe
    variable = tritium_concentration_Ni
    execute_on = 'initial timestep_end'
  []
  [FLiBe_interface]
    type = SideAverageValue
    boundary = interface_Ni_FLiBe_other_side
    variable = tritium_concentration_FLiBe
    execute_on = 'initial timestep_end'
  []
  [concentration_ratio_tritium]
    type = ParsedPostprocessor
    expression = 'Ni_interface / (FLiBe_interface^${n_sorption})'
    pp_names = 'Ni_interface FLiBe_interface'
    execute_on = 'initial timestep_end'
  []
  [concentration_tritium_Ni_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_concentration_Ni
    block = 1
    execute_on = 'initial timestep_end'
  []
  [concentration_tritium_FLiBe_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_concentration_FLiBe
    block = 2
    execute_on = 'initial timestep_end'
  []
  [mass_conservation]
    type = LinearCombinationPostprocessor
    pp_names = 'concentration_tritium_Ni_inventory concentration_tritium_FLiBe_inventory'
    pp_coefs = '1 1'
    execute_on = 'initial timestep_end'
  []
  [sieverts_ratio_tritium]
    type = ParsedPostprocessor
    expression = 'Ni_left / (${initial_pressure})^0.5'
    pp_names = 'Ni_left'
    execute_on = 'initial timestep_end'
    outputs = 'csv console'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function
    execute_on = 'initial nonlinear linear timestep_end'
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
  end_time = ${simulation_time}
  nl_max_its = 9
  l_max_its = 30
  scheme = 'bdf2'
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_abs_tol = 1e-11
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    optimal_iterations = 7
    iteration_window = 1
    growth_factor = 1.1
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Outputs]
  file_base = 'val-flibe_out'
  [csv]
    type = CSV
  []
  [exodus]
    type = Exodus
    time_step_interval = 200
  []
[]
