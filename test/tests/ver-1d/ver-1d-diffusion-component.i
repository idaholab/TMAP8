cl = 3.1622e18

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped'

    physics = 'mobile_diff'
    # cannot be added to SpeciesTrapping there because it requires
    # additional data that is specified there


    material_property_names = 'alpha_t1 alpha_t2'
    material_property_values = '1e-15 1e-12' # functor

    # Geometry
    nx = 200
    xmax = 1
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [ContinuousGalerkin]
      [mobile_diff]
        variable_name = 'mobile'
        diffusivity_matprop = 1

        dirichlet_boundaries = 'structure_left structure_right'
        boundary_values = '${fparse 3.1622e18 / cl} 0'

        # Test differences are too large with default preconditioning
        preconditioning = 'none'
      []
    []
  []
  [SpeciesTrapping]
    [trapped]
      species = 'trapped1 trapped2'
      mobile = 'mobile'
      components = structure
      verbose = true

      # Trapping parameters
      alpha_t = 'alpha_t1 alpha_t2'
      N = '${fparse 3.1622e22 / cl}'  # ok distribute
      Ct0 = '0.1'
      trap_per_free = 1

      # Releasing parameters
      alpha_r = 1e13
      temperatures = 'temp'  # ok distribute
      trapping_energy = 100
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
