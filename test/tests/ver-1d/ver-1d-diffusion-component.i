cl = 3.1622e18
N = ${fparse 3.1622e22/cl}

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped'

    physics = 'mobile_diff'
    # cannot be added to SpeciesTrapping there because it requires
    # additional data that is specified there


    # Material properties
    property_names = 'alpha_t N    Ct_0 alpha_r trapping_E diff'
    property_values = '1e15   ${N} 0.1  1e13    100        1'

    # Boundary conditions
    fixed_value_bc_variables = 'mobile'
    fixed_value_bc_boundaries = 'structure_left structure_right'
    fixed_value_bc_values = '${fparse 3.1622e18 / cl} 0'

    # Geometry
    nx = 200
    xmax = 1
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [mobile_diff]
      variable_name = 'mobile'
      diffusivity_matprop = 'diff'

      # Test differences are too large with default preconditioning
      preconditioning = 'none'
    []
  []
  [SpeciesTrapping]
    [trapped]
      species = 'trapped'
      mobile = 'mobile'
      verbose = true

      # Trapping parameters
      alpha_t = 'alpha_t'
      N = 'N'
      Ct0 = 'Ct0'

      # Releasing parameters
      alpha_r = 'alpha_r'
      temperatures = 'temp'  # ok distribute
      trapping_energy = 'trapping_E'
    []
  []
[]

[AuxVariables]
  [temp]
    initial_condition = 1000
  []
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'structure_right'
    diffusivity = 1
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

  num_steps =  2
  end_time = 3
  dt = .01
  dtmin = .01
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
[]

[Outputs]
  csv = true
  exodus = true
  # Not present in the test we compare to
  hide = 'temp'
[]
