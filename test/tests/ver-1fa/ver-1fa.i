length = '${units 1.6 m}'
initial_temperature = '${units 300 K}'
density = '${units 1 kg/m^3}'
specific_heat = '${units 1 J/kg/K}'
thermal_conductivity = '${units 10 W/m/K}'
volumetric_heat = '${units 1e4 W/m^3}'

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
  [heatsource]
    type = HeatSource
    function = volumetric_heat
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
    value = '${initial_temperature}'
  []
  [rightflux]
    type = NeumannBC
    boundary = left
    variable = temp
    value = 0
  []
[]

[Materials]
  [density]
    type = GenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '${density} ${thermal_conductivity} ${specific_heat}'
  []
[]

[Functions]
  [volumetric_heat]
    type = ParsedFunction
    expression = '${volumetric_heat}'
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
    end_point = '${length} 0 0'
    num_points = 40
    sort_by = 'x'
    variable = temp
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    execute_on = FINAL
  []
[]
