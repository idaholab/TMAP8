# This input file models the heating of a semi-infinite slab by convection at the left boundary.
# provided by TMAP7 V&V documentation
position_measurement = 5e-2 # m
initial_temperature = 100 # T_i in K
enclosure_temperature = 500 # T_infinity in K
conduction_coefficient = 200 # h in W/m^2/K
thermal_conductivity = 401 # k in W/m/K
rho_Cp = 3.439e6 # J/m^3/K

# Selected for TMAP8 case
slab_length = 100e-2 # m semi-infinite slab
num_nodes = 500 # (-)
end_time = 1500 # s
density = 1000 # kg/m^3
specific_heat = '${fparse rho_Cp/density}' # J/kg/K

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = ${slab_length}
  nx = ${num_nodes}
[]

[Physics]
  [HeatConduction]
    [FiniteElement]
      [h1]
        temperature_name = 'temperature'

        initial_temperature = ${initial_temperature}

        # Thermal properties
        thermal_conductivity = 'thermal_conductivity'

        # Boundary conditions
        insulated_boundaries = 'right'
        fixed_convection_boundaries = 'left'
        fixed_convection_T_infinity = ${enclosure_temperature}
        fixed_convection_htc = ${conduction_coefficient}
      []
    []
  []
[]

[Materials]
  [diffusivity]
    type = ADGenericConstantMaterial
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
