# Verification Problem #1fa from TMAP4/TMAP7 V&V document
# Heat conduction with heat generation

# Data used in TMAP4/TMAP7 case
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
  # temperature parameter in the slab in K
  [temperature]
    initial_condition = '${initial_temperature}'
  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temperature
  []
  [heatsource]
    type = HeatSource
    function = volumetric_heat
    variable = temperature
  []
  [HeatTdot]
    type = HeatConductionTimeDerivative
    variable = temperature
  []
[]

[BCs]
  # The temerature on the right boundary of the slib is kept at 300 K
  [right_temp]
    type = DirichletBC
    boundary = right
    variable = temperature
    value = '${initial_temperature}'
  []
  # The left boundary of the slib is in adiabatic situation
  [left_flux]
    type = NeumannBC
    boundary = left
    variable = temperature
    value = 0
  []
[]

[Materials]
  # The density of the sample slab
  [density]
    type = GenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '${density} ${thermal_conductivity} ${specific_heat}'
  []
[]

[Functions]
  # The heat source in the sample slab
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
  # The temperature distribution on the sample at end of the simulation
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${length} 0 0'
    num_points = 40
    sort_by = 'x'
    variable = temperature
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    execute_on = FINAL
  []
[]
