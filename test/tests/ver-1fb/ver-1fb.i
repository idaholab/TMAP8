length = '${units 4.0 m}'
initial_temperature = '${units 300 K}'
T_0 = '${units 300 K}'
T_1 = '${units 400 K}'
density = '${units 1 kg/m^3}'
specific_heat = '${units 10 J/kg/K}'
thermal_conductivity = '${units 10 W/m/K}'

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = '${length}'
  nx = 20
[]

[Variables]
  [temp]
    initial_condition = '${initial_temperature}'
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
    value = '${T_0}'
  []
  [rightflux]
    type = DirichletBC
    boundary = left
    variable = temp
    value = '${T_1}'
  []
[]

[Materials]
  [diffusivity]
    type = GenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '${density} ${thermal_conductivity} ${specific_heat}' # arbitrary values for diffusivity (=k/rho-Cp) to be 1.0
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
  dt = 0.01
  end_time = 10
  automatic_scaling = true
[]

[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${length} 0 0'
    num_points = 40
    sort_by = 'x'
    variable = temp
  []
[]

[Outputs]
  exodus = true
  csv = false
[]
