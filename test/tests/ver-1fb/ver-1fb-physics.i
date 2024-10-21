[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 4.0
  nx = 20
[]

[Physics]
  [HeatConduction]
    [FiniteElement]
      [h1]
        temperature_name = 'temp'

        initial_temperature = 300

        # Thermal properties
        thermal_conductivity = 'thermal_conductivity'

        # Boundary conditions
        fixed_temperature_boundaries = 'right left'
        boundary_temperatures = '300 400'
      []
    []
  []
[]

[Materials]
  [diffusivity]
    type = ADGenericConstantMaterial
    prop_names = 'density  thermal_conductivity specific_heat'
    prop_values = '1.0 10.0 10.0' # arbitrary values for diffusivity (=k/rho-Cp) to be 1.0
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
    end_point = '4.0 0 0'
    num_points = 40
    sort_by = 'x'
    variable = temp
  []
[]

[Outputs]
  #execute_on = FINAL
  exodus = true
  csv = false
[]
