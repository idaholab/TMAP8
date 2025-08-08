cl = 3.1622e18 # atom/m^3
nx_num = 200 # (-)
diffusivity = 1 # m^2/s
simulation_time = 3 # s
interval_time_min = 0.01 # s
interval_time = 0.01 # s

[Physics]
  [Diffusion]
    [multi-D]
      variable_name = 'mobile'
      diffusivity_matprop = '1'

      preconditioning = 'defer'
    []
  []
[]

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'mobile'
    physics = 'multi-D'

    # Boundary conditions
    fixed_value_bc_variables = 'mobile'
    fixed_value_bc_boundaries = 'structure_left structure_right'
    fixed_value_bc_values = '${fparse cl / cl} 0'

    # Geometry
    nx = ${nx_num}
    xmax = 1
    length_unit_scaling = 1
  []
[]

# We dont use the Physics-created PPs to match the names used in the reference
# input file that does not use Physics
[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'structure_right'
    diffusivity = ${diffusivity}
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = ${cl}
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  end_time = ${simulation_time}
  dt = ${interval_time}
  dtmin = ${interval_time_min}

  solve_type = NEWTON
  scheme = BDF2
  nl_abs_tol = 1e-13
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
[]

[Outputs]
  exodus = true
  csv = true
[]
