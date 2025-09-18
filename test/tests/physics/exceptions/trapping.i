# This input is used to test the errors / warnings from the SpeciesTrappingPhysics

cl = 3.1622e18
N = ${fparse 3.1622e22/cl}

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped'
    species_initial_concentrations = '0'

    physics = 'mobile_diff trapped'

    # Material properties
    property_names = 'alpha_t trapping_energy   N  Ct0 trap_per_free alpha_r detrapping_energy diff'
    property_values = '1e15   0               ${N} 0.1 1             1e13    100                1'

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

      # Trapping parameters are specified using functors on the structure component
      # Releasing parameters are specified using functors on the structure component
      temperature = '1000'  # we can use component ICs to set the temperature on the component
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
