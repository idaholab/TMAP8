[Mesh]
  # type = GeneratedMesh
  # dim = 1
  # xmax = 4.0
  # nx = 20

  # [cmg]
  #   type = CartesianMeshGenerator
  #   dim = 1
  #   # dx = '4e-2 4e-2 4e-2 4e-2 4e-2 4e-2 4e-2 4e-2 4e-2 4e-2' # in meters
  #   dx = '4e-1 4e-1 4e-1 4e-1 4e-1 4e-1 4e-1 4e-1 4e-1 4e-1' # in meters
  #   subdomain_id = '0 0 0 0 0 1  1  1  1  1'
  # []

  [whole_domain]
    type = GeneratedMeshGenerator
    xmin = 0
    xmax = 80e-2

    dim = 1
    nx = 400

  []
  [injection_block_1]
    type = ParsedSubdomainMeshGenerator
    input = whole_domain
    combinatorial_geometry = 'x < 40e-2'
    block_id = 0
  []
  [injection_block_2]
    type = ParsedSubdomainMeshGenerator
    input = injection_block_1
    combinatorial_geometry = 'x > 40e-2'
    block_id = 1
  []

[]

[Variables]
  [temp]
    initial_condition = 0.0
  []
[]

[Functions]
  [thermal_conductivity_func_Cu]
    type = ParsedFunction
    expression = '401.0'
  []
  [thermal_conductivity_func_Fe]
    type = ParsedFunction
    expression = '80.2'
  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temp
  []
  [HeatTdot]
    type = HeatConductionTimeDerivative
    variable = temp
  []
[]

[BCs]
  [lefttemp]
    type = DirichletBC
    boundary = right
    variable = temp
    value = 0.0
  []
  [rightflux]
    type = DirichletBC
    boundary = left
    variable = temp
    value = 600.0
  []
[]

[Materials]
  [specific_heat_Cu]
    type = GenericConstantMaterial
    block = '0'
    prop_names = 'density specific_heat'
    prop_values = '8940.0 384.7'
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
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   ilu      1'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  dt = 0.1
  end_time = 150
  automatic_scaling = true
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '80e-2 0 0'
    num_points = 400
    sort_by = 'x'
    variable = temp
  []
[]

[Outputs]
  #execute_on = FINAL
  exodus = true
  csv = true
[]
