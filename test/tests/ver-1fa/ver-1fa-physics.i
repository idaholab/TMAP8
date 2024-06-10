[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 1.6
  nx = 20
[]

[Physics]
  [HeatConduction]
    [FiniteElement]
      [h1]
        temperature_name = 'temp'
        heat_source_functor = 'volumetric_heat'

        initial_temperature = 300

        # Thermal properties
        thermal_conductivity = 'thermal_conductivity'

        # Boundary conditions
        fixed_temperature_boundaries = 'right'
        boundary_temperatures = '300'
        heat_flux_boundaries = 'left'
        boundary_heat_fluxes = '0'
      []
    []
  []
[]

[Materials]
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '1.0 10.0 1.0'
  []
[]

[Functions]
  [volumetric_heat]
    type = ParsedFunction
    value = 1.0e4
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
    end_point = '1.6 0 0'
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
