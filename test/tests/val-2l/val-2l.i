# This input file serves as the main phyiscs model of deuterium permeation in neutron-irradiated tungsten.

!include val-2l.params

[Mesh]
  [temp_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${seg1}  ${seg2}  ${seg3}  ${seg4}  ${seg5}  ${seg6}'
    ix = '${fparse 10  * ${nx_scale}}
          ${fparse 3  * ${nx_scale}}
          ${fparse 2  * ${nx_scale}}
          ${fparse 5  * ${nx_scale}}
          ${fparse 5  * ${nx_scale}}
          ${fparse 10 * ${nx_scale}}'
  []
  [tungsten_disc]
    type = RenameBoundaryGenerator
    input = temp_mesh
    old_boundary = 'left right'
    new_boundary = 'upstream downstream'
  []
[]


[Variables]
  [mobile]
  []
  [trapped_1]
  []
[]

[ICs]
  [trapped_ic]
    type = FunctionIC
    function = trapped_initial_condition
    variable = trapped_1
  []
[]

# [Problem]
#   # Reference-based convergence: compare each variable's residual to the magnitude of the physical
#   # terms (diffusion + time derivative + source, tagged 'ref') rather than to the initial residual
#   type = ReferenceResidualProblem
#   extra_tag_vectors = 'ref'
#   reference_vector = 'ref'
# []

[Kernels]
  [mobile_time_derivative]
    type = ADTimeDerivative
    variable = mobile
    # extra_vector_tags = 'ref'
  []
  [mobile_diffusion]
    type = ADMatDiffusion
    variable = mobile
    diffusivity = diffusivity_mat
    # extra_vector_tags = 'ref'
  []
  [coupled_time]
    type = ADCoefCoupledTimeDerivative
    variable = mobile
    v = trapped_1
    coef = ${trap_per_free}
    # extra_vector_tags = 'ref'
  []
[]

[NodalKernels]
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    mobile_concentration = mobile
    alpha_t = '${alpha_t_0}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free}
    # extra_vector_tags = ref
  []
  [release_1]
    type = ReleasingNodalKernel
    variable = trapped_1
    alpha_r = '${alpha_r_0}'
    detrapping_energy = '${detrapping_energy}'
    temperature = 'temperature'
  []
[]

[AuxVariables]
  [temperature]
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_function
    execute_on = 'INITIAL LINEAR TIMESTEP_END'
  []
[]


[BCs]
  active = 'left_recombination_flux right_recombination_flux'

  # Infinite recombination
  [left]
    type = ADDirichletBC
    boundary = upstream
    value = 0
    variable = mobile
  []
  [right]
    type = ADDirichletBC
    boundary = downstream
    value = 0
    variable = mobile
  []

  # Finite recombination
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = mobile
    boundary = upstream
    value = 1
    boundary_material = flux_recombination_surface
    # extra_vector_tags = 'ref'
  []

   [right_recombination_flux]
    type = ADMatNeumannBC
    variable = mobile
    boundary = downstream
    value = 1
    boundary_material = flux_recombination_surface
    # extra_vector_tags = 'ref'
  []
[]

[Materials]

  # Temperature-dependent deuterium diffusivity in tungsten
  [diffusivity_mat]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_mat'
    functor_names = 'temperature_function'
    functor_symbols = 'temperature'
    expression = '${diffusivity_preexponential_factor} * exp(- ${diffusivity_activation_energy} / ${kb_eV} / temperature)'
    output_properties = 'diffusivity_mat'
    outputs = 'exodus'
  []

  # Temperature-dependent recombination coefficient
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = 'Kr'
    functor_names = 'temperature_function'
    functor_symbols = 'temperature'
    expression = '${recombination_preexponential_factor} * exp(- ${recombination_energy} / ${kb_eV} / temperature)'
  []

  # Finite recombination Boundary Material
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'mobile'
    property_name = 'flux_recombination_surface'
    material_property_names = 'Kr'
    expression = '- 2 * Kr * mobile ^ 2'
  []
[]

[Functions]

  [temperature_function]
    type = PiecewiseLinear
    data_file = temperature_data.csv
    x_title = time
    y_title = temperature
    format = columns
  []

  [trapped_initial_condition]
    type = ParsedFunction
    expression = 'if(x < ${trap_depth}, ${trap_site_density} / ${trap_per_free}, 0.0)'
  []

  [trap_distribution_function]
    type = ParsedFunction
    expression = 'if(x < ${trap_depth}, ${trap_fraction}, 0.0)'
  []

[]

[Postprocessors]

  [trap_depth]
    type = ConstantPostprocessor
    value = ${trap_depth}
    execute_on = 'initial'
    outputs = csv
  []

  [trap_per_free]
    type = ConstantPostprocessor
    value = ${trap_per_free}
    execute_on = 'initial'
    outputs = csv
  []

  [temperature]
    type = FunctionValuePostprocessor
    function = temperature_function
    outputs = csv
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [diffusivity_pp]
    type = ADElementAverageMaterialProperty
    mat_prop = diffusivity_mat
    outputs = csv
  []

  ### Conservation of Mass ###

  # Total deuterium inventory currently in the sample, M(t)

  [total_mobile_retention]
    type = ElementIntegralVariablePostprocessor
    variable = mobile
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [total_trapped_retention] # Physical concentration = variable * trap_per_free
    type = ElementIntegralVariablePostprocessor
    variable = trapped_1
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [total_deuterium_retention]
    type = ParsedPostprocessor
    expression = 'total_mobile_retention + total_trapped_retention * ${trap_per_free}'
    pp_names = 'total_mobile_retention total_trapped_retention'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = csv
  []

  # Change in domain inventory relative to the initial mass, M(t) - M(0).
  [deuterium_inventory_change] # atoms / mum^2
    type = ChangeOverTimePostprocessor
    postprocessor = total_deuterium_retention
    change_with_respect_to_initial = true
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []

  # Desorption flux through upstream and downstream surfaces

  [upstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'upstream'
    variable = mobile
    diffusivity = diffusivity_mat
    execute_on = 'TIMESTEP_END'
  []

  [downstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'downstream'
    variable = mobile
    diffusivity = diffusivity_mat
    execute_on = 'TIMESTEP_END'
  []

  [deuterium_release_flux_total]
    type = SumPostprocessor
    values = 'upstream_flux downstream_flux'
    execute_on = 'TIMESTEP_END'
    outputs = csv
  []

  # Cumulative deuterium released through both surfaces
  [deuterium_released_physical] # atoms / mum^2
    type = TimeIntegratedPostprocessor
    value = deuterium_release_flux_total
    time_integration_scheme = TRAPEZOIDAL-RULE
    execute_on = 'TIMESTEP_END'
    outputs = csv
  []

  # Conservation residual = (M(t) - M(0)) + released; ideally 0 at all times.
  [deuterium_mass_conservation_residual] # atoms / mum^2
    type = SumPostprocessor
    values = 'deuterium_inventory_change deuterium_released_physical'
    execute_on = 'TIMESTEP_END'
    outputs = csv
  []
[]

[VectorPostprocessors]
  [mobile_profile]
    type = NodalValueSampler
    variable = mobile
    sort_by = x
    execute_on = 'TIMESTEP_END'
    outputs = profile_csv
  []
  [trapped_1_profile]
    type = NodalValueSampler
    variable = trapped_1
    sort_by = x
    execute_on = 'TIMESTEP_END'
    outputs = trapped_profile_csv
  []
[]

[Outputs]
  file_base = 'val-2l_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
  [profile_csv]
    type = CSV
    file_base = 'deuterium_mobile_concentration_profile/val-2l_out'
  []
  [trapped_profile_csv]
    type = CSV
    file_base = 'deuterium_trapped_concentration_profile/val-2l_out'
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
  line_search = 'none'
  nl_abs_tol = 1e-12
  nl_rel_tol = 1e-5
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = ${simulation_time}
  automatic_scaling = true
  dtmin = ${dt_min}
  dtmax = ${dt_max}
  [TimeStepper]
      type = IterationAdaptiveDT
      dt = ${dt_start}
      optimal_iterations = 5
      growth_factor = 1.1
      cutback_factor_at_failure = 0.5
  []
[]
