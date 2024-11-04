# This input file models the heating of a semi-infinite slab by convection at the left boundary.
# provided by TMAP7 V&V documentation
position_measurement = '${units 5e-2 m}'
initial_temperature = '${units 100 K}' # T_i
enclosure_temperature = '${units 500 K}' # T_infinity
conduction_coefficient = '${units 200 W/m^2/K}' # h
thermal_conductivity = '${units 401 W/m/K}' # k
rho_Cp = '${units 3.439e6 J/m^3/K}'

# Selected for TMAP8 case
slab_length = '${units 1 m}' # semi-infinite slab
density = '${units 1000 kg/m^3}'
specific_heat = '${units ${fparse rho_Cp/density} J/kg/K}'
num_nodes = 500 # (-)
end_time = '${units 1500 s}'

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = ${slab_length}
  nx = ${num_nodes}
[]

[Variables]
  [temperature]
    initial_condition = ${initial_temperature}
  []
[]

[Kernels]
  [heat]
    type = HeatConduction
    variable = temperature
  []
  [heat_time_derivative]
    type = HeatConductionTimeDerivative
    variable = temperature
  []
[]

[BCs]
  [rightflux]
    type = NeumannBC
    boundary = right
    variable = temperature
    value = 0
  []
  [leftconvection]
    type = ConvectiveHeatFluxBC
    boundary = left
    variable = temperature
    T_infinity = ${enclosure_temperature}
    heat_transfer_coefficient = ${conduction_coefficient}
  []
[]

[Materials]
  [diffusivity]
    type = GenericConstantMaterial
    prop_names = 'density thermal_conductivity specific_heat'
    prop_values = '${density} ${thermal_conductivity} ${specific_heat}'
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
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-50
  l_tol = 1e-8
  end_time = ${end_time}
  dtmax = 2e2
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-2
    optimal_iterations = 3
    iteration_window = 1
    growth_factor = 1.2
    cutback_factor = 0.8
  []
[]

[Postprocessors]
  # Used to obtain varying temperature with time at the desired position
  [temperature_at_x]
    type = PointValue
    variable = temperature
    point = '${position_measurement} 0 0'
    execute_on = 'initial timestep_end'
    outputs = 'csv'
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
