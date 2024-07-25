# This test is to verify the implementation of InterfaceSorption and its AD counterpart.
# It contains two 2D blocks separated by a continuous interface.
# InterfaceSorption is used to enforce the sorption law and preserve flux between the blocks.
# Checks are performed to verify concentration conservation, sorption behavior, and flux preservation.
# This input file uses BreakMeshByBlockGenerator, which is currently only supported for replicated
# meshes, so this file should not be run with the `parallel_type = DISTRIBUTED` flag

# In this input file, we apply the Sievert law with n_sorption=1/2.

# Physical Constants
R = 8.31446261815324 # Based on PhysicalConstants


[GlobalParams]
  order = FIRST
  family = LAGRANGE
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    nx = 10
    ny = 10
    dim = 2
  []
  [block1]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '0.5 1 0'
    input = gen
  []
  [block2]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '0.5 0 0'
    top_right = '1 1 0'
    input = block1
  []
  [breakmesh]
    input = block2
    type = BreakMeshByBlockGenerator
    block_pairs = '1 2'
    split_interface = true
    add_interface_on_two_sides = true
  []
[]

[Variables]
  [u1]
    block = 1
  []
  [u2]
    block = 2
  []
  [temperature]
  []
[]

[Kernels]
  [u1]
    type = MatDiffusion
    variable = u1
    diffusivity = diffusivity
    block = 1
  []
  [u2]
    type = MatDiffusion
    variable = u2
    diffusivity = diffusivity
    block = 2
  []
  [temperature]
    type = HeatConduction
    variable = temperature
  []
[]

[BCs]
  [left_u1]
    type = DirichletBC
    value = 1
    variable = u1
    boundary = left
  []
  [right_u2]
    type = DirichletBC
    value = 1
    variable = u2
    boundary = right
  []
  [left_temperature]
    type = DirichletBC
    value = 1100
    variable = temperature
    boundary = left
  []
  [right_temperature]
    type = DirichletBC
    value = 0
    variable = temperature
    boundary = right
  []
  [block1_2_temperature]
    type = DirichletBC
    value = 1000
    variable = temperature
    boundary = Block1_Block2
  []
  [block2_1_temperature]
    type = DirichletBC
    value = 900
    variable = temperature
    boundary = Block2_Block1
  []
[]

[InterfaceKernels]
  [interface]
    type = InterfaceSorption
    K0 = 1.e-2
    Ea = 0
    n_sorption = 0.5
    diffusivity = diffusivity
    unit_scale = 1
    unit_scale_neighbor = 1
    temperature = temperature
    variable = u2
    neighbor_var = u1
    sorption_penalty = 1e1
    boundary = Block2_Block1
  []
[]

[Materials]
  [properties_1]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity diffusivity'
    prop_values = '1 1'
    block = 1
  []
  [properties_2]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity diffusivity solubility'
    prop_values = '2 2 1e-2'
    block = 2
  []
[]

[Functions]
  [u_mid_diff]
    type = ParsedFunction
    symbol_names = 'u_mid_inner u_mid_outer'
    symbol_values = 'u_mid_inner u_mid_outer'
    expression = '(abs(u_mid_outer) - abs(u_mid_inner)) / abs(u_mid_inner)'
  []
  [residual_concentration]
    type = ParsedFunction
    symbol_names = 'u_mid_inner u_mid_outer T R solubility'
    symbol_values = 'u_mid_inner u_mid_outer temperature_mid_inner ${R} 1e-2'
    expression = 'u_mid_outer - solubility*sqrt(u_mid_inner*R*T)'
  []
  [flux_error]
    type = ParsedFunction
    symbol_names = 'flux_inner flux_outer'
    symbol_values = 'flux_inner flux_outer'
    expression = '(abs(flux_outer) - abs(flux_inner)) / abs(flux_inner)'
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  # automatic_scaling = true
  # scaling_group_variables = 'u1; u2; temperature'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'
  line_search = none

  nl_rel_tol = 1e-15
  nl_abs_tol = 1e-9
  l_tol = 1e-3
  l_max_its = 50
  nl_max_its = 50
[]

[Postprocessors]
  [u_mid_inner]
    type = PointValue
    variable = u1
    point = '0.49999 0.5 0'
    outputs = 'csv console'
  []
  [u_mid_outer]
    type = PointValue
    variable = u2
    point = '0.50001 0.5 0'
    outputs = 'csv console'
  []
  [u_mid_diff]
    type = FunctionValuePostprocessor
    function = u_mid_diff
    outputs = 'csv console'
  []
  [temperature_mid_inner]
    type = PointValue
    variable = temperature
    point = '0.49999 0.5 0'
    outputs = csv
  []
  [temperature_mid_outer]
    type = PointValue
    variable = temperature
    point = '0.50001 0.5 0'
    outputs = csv
  []
  [residual_concentration]
    type = FunctionValuePostprocessor
    function = residual_concentration
    outputs = 'csv console'
  []

  [flux_inner] # verify flux preservation
    type = SideDiffusiveFluxIntegral
    variable = u1
    boundary = Block1_Block2
    diffusivity = diffusivity
    outputs = 'csv console'
  []
  [flux_outer]
    type = SideDiffusiveFluxIntegral
    variable = u2
    boundary = Block2_Block1
    diffusivity = diffusivity
    outputs = 'csv console'
  []
  [flux_error]
    type = FunctionValuePostprocessor
    function = flux_error
    outputs = 'csv console'
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

[Debug]
  show_var_residual_norms = true
[]
