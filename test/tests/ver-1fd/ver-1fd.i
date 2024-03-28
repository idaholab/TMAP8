[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 5.0
  nx = 1000
[]

[Variables]
  [temp]
    initial_condition = 100.0
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
    boundary = left
    variable = temp
    value = 100
  []
  [rightflux]
    type = ConvectiveHeatFluxBC
    boundary = right
    variable = temp
    T_infinity = 500
    heat_transfer_coefficient = 200
  []
[]

[Materials]
  [diffusivity]
    type = GenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '3439.0 401.0 1000.0' # arbitrary values for diffusivity (=k/rho-Cp) to be 1.0
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
  end_time = 180
  automatic_scaling = true
[]

# [VectorPostprocessors]
#   [line]
#     type = LineValueSampler
#     start_point = '0 0 0'
#     end_point = '1.0 0 0'
#     num_points = 200
#     sort_by = 'x'
#     variable = temp
#   []
# []
[Postprocessors]
  [5cm_node_temp]
    type = NodalVariableValue
    nodeid = 989 # Paraview GlobalNodeID 990 at (0.95)
    variable = temp
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  #execute_on = FINAL
  exodus = true
  csv = true
[]
