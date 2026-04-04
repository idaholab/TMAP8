# This input file tests the physics syntax and dimensionless capabilities with two traps.

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped_a trapped_b'
    species_initial_concentrations = '0 0.5'
    species_scaling_factors = '1 1'

    physics = 'trapped'
    temperature = '1'

    # Material properties
    property_names = 'dimensionless_trapping_rate_trapped_a
                      dimensionless_trapping_rate_trapped_b
                      N
                      Ct0_trapped_a
                      Ct0_trapped_b
                      trap_concentration_reference_trapped_a
                      trap_concentration_reference_trapped_b
                      trapping_energy_trapped_a
                      trapping_energy_trapped_b
                      dimensionless_release_rate_trapped_a
                      dimensionless_release_rate_trapped_b
                      detrapping_energy_trapped_a
                      detrapping_energy_trapped_b
                      mobile_concentration_reference'
    property_values = '1
                       1
                       10
                       0.5
                       0.5
                       2
                       3
                       1
                       1
                       0
                       0
                       0
                       0
                       1'

    # Geometry
    nx = 20
    xmax = 1
    length_unit_scaling = 1
  []
[]

[Variables]
  [mobile]
    initial_condition = 1
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapped]
      species = 'trapped_a trapped_b'
      mobile = 'mobile mobile'
      dimensionless_species = true
    []
  []
[]

[Kernels]
  [mobile_time]
    type = TimeDerivative
    variable = mobile
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
  solve_type = NEWTON

  num_steps = 5
  dt = 0.1

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type'
  petsc_options_value = 'lu       mumps'
[]

[Outputs]
  csv = true
[]

[Postprocessors]
  [ave_mobile]
    type = ElementAverageValue
    variable = mobile
  []
  [ave_trapped_a]
    type = ElementAverageValue
    variable = trapped_a
  []
  [ave_trapped_b]
    type = ElementAverageValue
    variable = trapped_b
  []
  [scale_trapped_a]
    type = ScalePostprocessor
    value = ave_trapped_a
    scaling_factor = 2
  []
  [scale_trapped_b]
    type = ScalePostprocessor
    value = ave_trapped_b
    scaling_factor = 3
  []
  [sum]
    type = ParsedPostprocessor
    expression = 'scale_trapped_a + scale_trapped_b + ave_mobile'
    pp_names = 'scale_trapped_a scale_trapped_b ave_mobile'
  []
[]
