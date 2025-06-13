cl = 3.1622e18
N = '${fparse 3.1622e22/cl}'

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'trapped'
    species_initial_concentrations = '0'

    physics = 'mobile_diff trapped'

    # Material properties
    property_names = 'alpha_t trapping_energy    N  Ct0 trap_per_free alpha_r detrapping_energy diff'
    property_values = '1e15   0                ${N} 0.1 1             1e13    100                1'

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

      discretization = 'nodal'
      dont_create_kernels = true

      # Trapping parameters are specified using functors on the structure component
      # Releasing parameters are specified using functors on the structure component
      temperature = 'temp' # we can use component ICs to set the temperature on the component
    []
  []
[]

[Kernels]
  [trapped_trapping_loss_of_mobile_to_trapped]
    type = TrappingKernel
    Ct0 = 0.1
    N = 10000
    alpha_t = -1e+15
    block = structure
    mobile_concentration = mobile
    temperature = temp
    trap_per_free = 1
    trapped_concentration = trapped
    trapping_energy = 0
    variable = mobile
  []
  [trapped_release_of_mobile_from_trapped]
    type = ReleasingKernel
    alpha_r = -1e+13
    block = structure
    detrapping_energy = 100
    temperature = temp
    trapped_concentration = trapped
    variable = mobile
  []
[]

[NodalKernels]
  [trapped_trapped_time]
    type = TimeDerivativeNodalKernel
    block = structure
    matrix_tags = 'system time'
    variable = trapped
    vector_tags = time
  []
  [trapped_trapping_of_mobile_to_trapped]
    type = TrappingNodalKernel
    Ct0 = 0.1
    N = 10000
    alpha_t = 1e+15
    block = structure
    mobile_concentration = mobile
    temperature = temp
    trap_per_free = 1
    trapping_energy = 0
    variable = trapped
  []
  [trapped_release_loss_of_trapped_to_mobile]
    type = ReleasingNodalKernel
    alpha_r = 1e+13
    block = structure
    detrapping_energy = 100
    temperature = temp
    variable = trapped
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

  num_steps = 2
  end_time = 3
  dt = .01
  dtmin = .01
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  line_search = 'none'
[]

[Outputs]
  csv = true
  exodus = true
  # Not present in the test we compare to
  hide = 'temp'
[]
