# Verification Problem #1fa from TMAP4/TMAP7 V&V document
# Heat conduction with heat generation using a Physics and Components syntax

# Data used in TMAP4/TMAP7 case
length = '${units 1.6 m}'
initial_temperature = '${units 300 K}'
density = '${units 1 kg/m^3}'
specific_heat = '${units 1 J/kg/K}'
thermal_conductivity = '${units 10 W/m/K}'
volumetric_heat = '${units 1e4 W/m^3}'
simulation_time = '${units 10 s}'

[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = '${length}'
  nx = 20
[]

[Physics]
  [HeatConduction]
    [h1]
      temperature_name = 'temperature'
      heat_source_functor = 'volumetric_heat'

      initial_temperature = '${initial_temperature}'

      # Thermal properties
      thermal_conductivity = 'thermal_conductivity'

      # Boundary conditions
      fixed_temperature_boundaries = 'right'
      boundary_temperatures = '${initial_temperature}'
      heat_flux_boundaries = 'left'
      boundary_heat_fluxes = '0'
    []
  []
[]

[Materials]
  [density]
    type = ADGenericConstantMaterial
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
  end_time = ${simulation_time}
  automatic_scaling = true
[]

[VectorPostprocessors]
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
