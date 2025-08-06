## This input is used to test errors on the 1D structure

cl = 3.1622e18
N = ${fparse 3.1622e22/cl}

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped extra'
    # only the matching index for trapped should be used
    species_initial_concentrations = '2 1'
    species_scaling_factors = '1 1'

    physics = 'mobile_diff trapped'
    temperature = '200'

    # Material properties
    property_names = 'alpha_t  N  trapping_energy Ct0 trap_per_free alpha_r detrapping_energy diff'
    property_values = '1e15   ${N} 0               0.1 1             1e13    100                1'

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
      preconditioning = 'defer'
    []
  []
  [SpeciesTrapping]
    [trapped]
      species = 'trapped'
      mobile = 'mobile'
      verbose = true
    []
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
[]

[Postprocessors]
  [ave_trapped]
    type = ElementAverageValue
    variable = 'trapped'
  []
  [ave_mobile]
    type = ElementAverageValue
    variable = 'mobile'
  []
[]
