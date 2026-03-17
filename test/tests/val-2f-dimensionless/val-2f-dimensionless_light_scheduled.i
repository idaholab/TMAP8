# Validation Problem #2f — Scheduled light replay for serial/parallel comparison
# This is the light occupancy-based dimensionless case run on an explicit sequence of
# accepted times extracted from the reference serial CSV. The purpose is to eliminate
# divergence caused solely by adaptive time-step history when comparing serial and parallel.

!include parameters_val-2f-dimensionless.params

[Mesh]
  [cartesian_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${dx1_hat} ${dx2_hat} ${dx3_hat} ${dx4_hat} ${dx5_hat}'
    ix = '${ix1} ${ix2} ${ix3} ${ix4} ${ix5}'
    subdomain_id = '0 0 0 0 0'
  []
[]

[Variables]
  [deuterium_concentration_W]
  []
[]

[AuxVariables]
  active = 'bounds_dummy temperature'
  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
  []
  [temperature]
    initial_condition = ${temperature_initial}
  []
[]

[Bounds]
  [deuterium_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_concentration_W
    bound_type = lower
    bound_value = 0
  []
  [trapped_intrinsic_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_intrinsic
    bound_type = lower
    bound_value = 0
  []
  [trapped_1_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_1
    bound_type = lower
    bound_value = 0
  []
  [trapped_2_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_2
    bound_type = lower
    bound_value = 0
  []
  [trapped_3_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_3
    bound_type = lower
    bound_value = 0
  []
  [trapped_4_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_4
    bound_type = lower
    bound_value = 0
  []
  [trapped_5_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = trapped_5
    bound_type = lower
    bound_value = 0
  []
[]

[Functions]
  [temperature_bc_func]
    type = ParsedFunction
    expression = 'if(t<${charge_time_hat}, ${temperature_initial},
                  if(t<${fparse charge_time_hat + cooldown_duration_hat}, ${temperature_cooldown},
                  ${temperature_desorption_min}+${desorption_heating_rate_hat}*(t-${fparse charge_time_hat + cooldown_duration_hat})))'
  []
  [source_distribution]
    type = ParsedFunction
    expression = '1 / (${sigma_hat} * sqrt(2 * pi)) * exp(-0.5 * ((x - ${R_p_hat}) / ${sigma_hat}) ^ 2)'
  []
  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t<${charge_time_hat}, ${surface_flux_hat}, 0)'
  []
  [source_deuterium]
    type = ParsedFunction
    symbol_names = 'source_distribution surface_flux_func'
    symbol_values = 'source_distribution surface_flux_func'
    expression = 'source_distribution * surface_flux_func'
  []
  [max_dt_size_function]
    type = ParsedFunction
    expression = 'if(t<${fparse 5 / time_reference}, ${fparse 1e-2 / time_reference},
                  if(t<${fparse 8 / time_reference}, ${fparse 1e2 / time_reference},
                  if(t<${fparse 12 / time_reference}, ${fparse 1e-2 / time_reference},
                  if(t<${fparse 20 / time_reference}, ${fparse 1e2 / time_reference},
                  if(t<${fparse 35 / time_reference}, ${fparse 1e-2 / time_reference},
                  if(t<${fparse 450 / time_reference}, ${fparse 1e2 / time_reference},
                  if(t<${fparse 5000 / time_reference}, ${fparse 1e1 / time_reference},
                  if(t<${fparse 11000 / time_reference}, ${fparse 1e2 / time_reference},
                  if(t<${fparse 13000 / time_reference}, ${fparse 1e1 / time_reference},
                  if(t<${fparse (charge_time + cooldown_duration + 4500) / time_reference}, ${fparse 1e2 / time_reference},
                  if(t<${fparse 313000 / time_reference}, ${fparse 1e2 / time_reference},
                  if(t<${fparse 315000 / time_reference}, ${fparse 1e1 / time_reference}, ${fparse 1e3 / time_reference}))))))))))))'
  []
  [max_dt_size_function_coarse]
    type = ParsedFunction
    expression = 'if(t<${fparse 1e-1 / time_reference}, ${fparse 1e4 / time_reference}, ${fparse 1e5 / time_reference})'
  []
  # Trap distribution functions (Fermi-Dirac depth profiles for damage traps)
  [trap_distribution_function_1]
    type = ParsedFunction
    expression = '${trapping_site_fraction_1} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_2]
    type = ParsedFunction
    expression = '${trapping_site_fraction_2} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_3]
    type = ParsedFunction
    expression = '${trapping_site_fraction_3} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_4]
    type = ParsedFunction
    expression = '${trapping_site_fraction_4} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
  [trap_distribution_function_5]
    type = ParsedFunction
    expression = '${trapping_site_fraction_5} / (1 + exp((x - ${depth_center_hat}) / ${depth_width_hat}))'
  []
[]

[Physics]
  [SpeciesTrapping]
    [trapping]
      species = 'trapped_intrinsic trapped_1 trapped_2 trapped_3 trapped_4 trapped_5'
      species_scaling_factors = '1 1 1 1 1 1'
      species_initial_concentrations = '0 0 0 0 0 0'
      # All 6 trapped species couple to the same mobile variable
      mobile = 'deuterium_concentration_W deuterium_concentration_W deuterium_concentration_W
                deuterium_concentration_W deuterium_concentration_W deuterium_concentration_W'
      dimensionless_trapping_rate = '${dimensionless_trapping_rate_intrinsic}
                                     ${dimensionless_trapping_rate_1}
                                     ${dimensionless_trapping_rate_2}
                                     ${dimensionless_trapping_rate_3}
                                     ${dimensionless_trapping_rate_4}
                                     ${dimensionless_trapping_rate_5}'
      trapping_energy = '${trapping_energy_intrinsic} ${trapping_energy_1} ${trapping_energy_2}
                         ${trapping_energy_3} ${trapping_energy_4} ${trapping_energy_5}'
      N = ${tungsten_density}
      Ct0 = '${trapping_site_fraction_intrinsic} trap_distribution_function_1 trap_distribution_function_2
             trap_distribution_function_3 trap_distribution_function_4 trap_distribution_function_5'
      trap_concentration_reference = '${trap_concentration_reference_intrinsic}
                                      ${trap_concentration_reference_1}
                                      ${trap_concentration_reference_2}
                                      ${trap_concentration_reference_3}
                                      ${trap_concentration_reference_4}
                                      ${trap_concentration_reference_5}'
      mobile_concentration_reference = ${mobile_concentration_reference}
      dimensionless_release_rate = '${dimensionless_release_rate_intrinsic}
                                    ${dimensionless_release_rate_1}
                                    ${dimensionless_release_rate_2}
                                    ${dimensionless_release_rate_3}
                                    ${dimensionless_release_rate_4}
                                    ${dimensionless_release_rate_5}'
      detrapping_energy = '${detrapping_energy_intrinsic} ${detrapping_energy_1} ${detrapping_energy_2}
                           ${detrapping_energy_3} ${detrapping_energy_4} ${detrapping_energy_5}'
      temperature = 'temperature'
      dimensionless_trapped_species = true
      dimensionless_mobile_species = true
      # Each trap type occupies distinct defect sites — no cross-coupling between species
      different_traps_for_each_species = true
    []
  []
[]

[Kernels]
  [time_W]
    type = TimeDerivative
    variable = deuterium_concentration_W
  []
  [diffusion_W]
    type = ADMatDiffusion
    variable = deuterium_concentration_W
    diffusivity = diffusivity_W_hat
  []
  [source_deuterium]
    type = BodyForce
    variable = deuterium_concentration_W
    function = source_deuterium
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_bc_func
    execute_on = 'INITIAL LINEAR'
  []
[]

[BCs]
  active = 'left_recombination_flux right_recombination_flux'
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = left
    value = 1
    boundary_material = flux_recombination_surface
  []
  [right_recombination_flux]
    type = ADMatNeumannBC
    variable = deuterium_concentration_W
    boundary = right
    value = 1
    boundary_material = flux_recombination_surface
  []
  [left_concentration_sieverts]
    type = ADDirichletBC
    value = '${sieverts_boundary_hat}'
    boundary = left
    variable = deuterium_concentration_W
  []
  [right_concentration_sieverts]
    type = ADDirichletBC
    value = '${sieverts_boundary_hat}'
    boundary = right
    variable = deuterium_concentration_W
  []
[]

[Materials]
  active = 'diffusivity_W_func recombination_rate_surface flux_recombination_surface'
  [diffusivity_W_func]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_W_hat'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${diffusion_W_preexponential_hat} * exp(- ${diffusion_W_energy} / ${kb_eV} / temperature)'
  []
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = 'Kr_hat'
    functor_names = 'temperature_bc_func'
    functor_symbols = 'temperature'
    expression = '${recombination_coefficient_hat} * exp(- ${recombination_energy} / ${kb_eV} / temperature)'
  []
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'deuterium_concentration_W'
    property_name = 'flux_recombination_surface'
    material_property_names = 'Kr_hat'
    expression = '- 2 * Kr_hat * deuterium_concentration_W ^ 2'
  []
[]

[Postprocessors]
  [mobile_integral_hat]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_concentration_W
  []
  [scaled_mobile_deuterium]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * mobile_concentration_reference}'
    value = mobile_integral_hat
    outputs = none
  []
  [trapped_intrinsic_integral]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_intrinsic
  []
  [trapped_1_integral]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_1
  []
  [trapped_2_integral]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_2
  []
  [trapped_3_integral]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_3
  []
  [trapped_4_integral]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_4
  []
  [trapped_5_integral]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_5
  []
  [scaled_trapped_deuterium_intrinsic]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * trap_concentration_reference_intrinsic}'
    value = trapped_intrinsic_integral
    outputs = none
  []
  [scaled_trapped_deuterium_1]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * trap_concentration_reference_1}'
    value = trapped_1_integral
    outputs = none
  []
  [scaled_trapped_deuterium_2]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * trap_concentration_reference_2}'
    value = trapped_2_integral
    outputs = none
  []
  [scaled_trapped_deuterium_3]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * trap_concentration_reference_3}'
    value = trapped_3_integral
    outputs = none
  []
  [scaled_trapped_deuterium_4]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * trap_concentration_reference_4}'
    value = trapped_4_integral
    outputs = none
  []
  [scaled_trapped_deuterium_5]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2} * trap_concentration_reference_5}'
    value = trapped_5_integral
    outputs = none
  []
  [temperature]
    type = ElementAverageValue
    variable = temperature
    execute_on = 'initial timestep_end'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
  [max_time_step_size_coarse]
    type = FunctionValuePostprocessor
    function = max_dt_size_function_coarse
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
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
  start_time = 0
  scheme = implicit-euler
  solve_type = 'Newton'
  abort_on_solve_fail = true
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type -snes_type'
  petsc_options_value = 'lu       mumps                      vinewtonrsls'
  end_time = ${endtime_hat}
  line_search = 'none'
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-14
  nl_max_its = 34
  [TimeStepper]
    type = CSVTimeSequenceStepper
    file_name = val-2f-dimensionless_light_time_sequence.csv
  []
[]

[Outputs]
  file_base = 'val-2f-dimensionless_out'
  [csv]
    type = CSV
  []
[]
