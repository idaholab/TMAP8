[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 1.6
  nx = 20
[]

[Variables]
  [./temp]
    initial_condition = 300.0
  [../]
[]

[Kernels]
  [./heat]
    type = HeatConduction
    variable = temp
  [../]
  [./heatsource]
    type = HeatSource
    function = volumetric_heat
    variable = temp
  [../]
  [./HeatTdot]
    type = HeatConductionTimeDerivative
    variable = temp
  [../]
[]

[BCs]
  [./lefttemp]
    type = DirichletBC
    boundary = right
    variable = temp
    value = 300
  [../]
  [./rightflux]
    type = NeumannBC
    boundary = left
    variable = temp
    value = 0
  [../]
[]

[Materials]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '1.0 10.0 1.0'
  [../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = 1.0e4
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
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
  dt = 1
  end_time = 10
  automatic_scaling = true
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '1.6 0 0'
    num_points = 40
    sort_by = 'x'
    variable = temp
  []
[]

[Outputs]
  execute_on = FINAL
  exodus = true
  csv = false
[]
