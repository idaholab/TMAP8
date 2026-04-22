# Validation Problem #val-2k
# Validation case for deuterium release from self-irradiated tungsten with
# natural and artificial oxide layers based on:
# Kremer, K., Brucker, M., Jacob, W., Schwarz-Selinger, T. (2022)
# "Influence of thin surface oxide films on hydrogen isotope release from ion-irradiated tungsten"
#
# This companion stage adds the explicit 5 nm oxide-layer comparison while
# leaving the tungsten-only natural-oxide baseline untouched.
# Included physics:
# - dimensionless deuterium diffusion in a front 5 nm oxide layer and tungsten substrate
# - six scaled val-2f trap families introduced through SpeciesTrapping physics blocks in the tungsten
# - phenomenological D2 and D2O surface release on the front oxide surface and back tungsten surface
# Deferred to later stages:
# - explicit hydrogen-containing species
# - water formation
# - oxide reduction

!include parameters_val-2k_5nm_oxide.params
!include val-2k_5nm_oxide_layer.i
!include val-2k_traps_5nm_oxide.i
!include val-2k_surface_5nm_oxide.i

[Mesh]
  active = mesh_fine
  [mesh_fine]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${oxide_thickness_hat} ${left_refined_tungsten_depth_hat} ${damage_remainder_depth_hat} ${oxide_buffer_fine_depth_hat} ${oxide_buffer_coarse_depth_hat} ${oxide_bulk_depth_hat}'
    ix = '${ix_oxide_fine} ${ix_left_refined_tungsten_fine} ${ix_damage_remainder_fine} ${ix_buffer_fine} ${ix_buffer_coarse_fine} ${ix_bulk_fine}'
    subdomain_id = '0 1 1 1 1 1'
  []
  [mesh_coarse]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${oxide_thickness_hat} ${left_refined_tungsten_depth_hat} ${damage_remainder_depth_hat} ${oxide_buffer_fine_depth_hat} ${oxide_buffer_coarse_depth_hat} ${oxide_bulk_depth_hat}'
    ix = '${ix_oxide_coarse} ${ix_left_refined_tungsten_coarse} ${ix_damage_remainder_coarse} ${ix_buffer_coarse} ${ix_buffer_coarse_coarse} ${ix_bulk_coarse}'
    subdomain_id = '0 1 1 1 1 1'
  []
[]

[Variables]
  [deuterium_mobile]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${initial_mobile_concentration_hat}
  []
[]

[AuxVariables]
  active = 'bounds_dummy temperature deuterium_mobile_physical deuterium_trapped_intrinsic_physical
  deuterium_trapped_1_physical deuterium_trapped_2_physical deuterium_trapped_3_physical
  deuterium_trapped_4_physical deuterium_trapped_5_physical deuterium_total_physical'
  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
  []
  [temperature]
    initial_condition = ${temperature_initial}
  []
  [deuterium_mobile_physical]
  []
  [deuterium_trapped_intrinsic_physical]
    initial_condition = 0
  []
  [deuterium_trapped_1_physical]
    initial_condition = 0
  []
  [deuterium_trapped_2_physical]
    initial_condition = 0
  []
  [deuterium_trapped_3_physical]
    initial_condition = 0
  []
  [deuterium_trapped_4_physical]
    initial_condition = 0
  []
  [deuterium_trapped_5_physical]
    initial_condition = 0
  []
  [deuterium_total_physical]
  []
[]

[Bounds]
  [deuterium_mobile_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = deuterium_mobile
    bound_type = lower
    bound_value = 0
  []
[]

[Kernels]
  [mobile_time]
    type = TimeDerivative
    variable = deuterium_mobile
  []
  [mobile_diffusion]
    type = ADMatDiffusion
    variable = deuterium_mobile
    diffusivity = diffusivity_mobile
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_history
    execute_on = 'INITIAL LINEAR'
  []
  [deuterium_mobile_physical_aux]
    type = NormalizationAux
    variable = deuterium_mobile_physical
    normal_factor = ${mobile_concentration_reference_m3}
    source_variable = deuterium_mobile
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_trapped_intrinsic_physical_aux]
    type = NormalizationAux
    block = 1
    variable = deuterium_trapped_intrinsic_physical
    normal_factor = ${trap_concentration_reference_intrinsic_m3}
    source_variable = deuterium_trapped_intrinsic
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_trapped_1_physical_aux]
    type = NormalizationAux
    block = 1
    variable = deuterium_trapped_1_physical
    normal_factor = ${trap_concentration_reference_1_m3}
    source_variable = deuterium_trapped_1
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_trapped_2_physical_aux]
    type = NormalizationAux
    block = 1
    variable = deuterium_trapped_2_physical
    normal_factor = ${trap_concentration_reference_2_m3}
    source_variable = deuterium_trapped_2
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_trapped_3_physical_aux]
    type = NormalizationAux
    block = 1
    variable = deuterium_trapped_3_physical
    normal_factor = ${trap_concentration_reference_3_m3}
    source_variable = deuterium_trapped_3
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_trapped_4_physical_aux]
    type = NormalizationAux
    block = 1
    variable = deuterium_trapped_4_physical
    normal_factor = ${trap_concentration_reference_4_m3}
    source_variable = deuterium_trapped_4
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_trapped_5_physical_aux]
    type = NormalizationAux
    block = 1
    variable = deuterium_trapped_5_physical
    normal_factor = ${trap_concentration_reference_5_m3}
    source_variable = deuterium_trapped_5
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [deuterium_total_physical_aux]
    type = ParsedAux
    variable = deuterium_total_physical
    coupled_variables = 'deuterium_mobile_physical deuterium_trapped_intrinsic_physical
    deuterium_trapped_1_physical deuterium_trapped_2_physical deuterium_trapped_3_physical
    deuterium_trapped_4_physical deuterium_trapped_5_physical'
    expression = 'deuterium_mobile_physical + deuterium_trapped_intrinsic_physical +
    deuterium_trapped_1_physical + deuterium_trapped_2_physical + deuterium_trapped_3_physical +
    deuterium_trapped_4_physical + deuterium_trapped_5_physical'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Functions]
  [temperature_history]
    type = PiecewiseLinear
    data_file = gold/Experimental_desorption_temperature.csv
    format = columns
    x_title = 'time (s)'
    y_title = 'Temperature (K)'
  []
[]

[Postprocessors]
  [temperature_pps]
    type = ElementAverageValue
    variable = temperature
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [integral_mobile]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_mobile
    outputs = none
  []
  [scaled_mobile]
    type = ScalePostprocessor
    scaling_factor = '${fparse mobile_concentration_reference * length_reference * ${units 1 m^2 -> mum^2}}'
    value = integral_mobile
  []
  [mobile_inventory_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_mobile
  []
  [flux_surface_left_d2]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_left_d2]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * mobile_concentration_reference * length_reference * ${units 1 m^2 -> mum^2} / time_reference}'
    value = flux_surface_left_d2
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_left_d2_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_flux_surface_left_d2
  []
  [flux_surface_left_d2o]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_recombination_surface_d2o
    outputs = none
  []
  [scaled_flux_surface_left_d2o]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * mobile_concentration_reference * length_reference * ${units 1 m^2 -> mum^2} / time_reference}'
    value = flux_surface_left_d2o
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_left_d2o_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_flux_surface_left_d2o
  []
  [scaled_flux_surface_left]
    type = SumPostprocessor
    values = 'scaled_flux_surface_left_d2 scaled_flux_surface_left_d2o'
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_left_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_flux_surface_left
  []
  [flux_surface_right_d2]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_right_d2]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * mobile_concentration_reference * length_reference * ${units 1 m^2 -> mum^2} / time_reference}'
    value = flux_surface_right_d2
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_right_d2_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_flux_surface_right_d2
  []
  [flux_surface_right_d2o]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_recombination_surface_d2o
    outputs = none
  []
  [scaled_flux_surface_right_d2o]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * mobile_concentration_reference * length_reference * ${units 1 m^2 -> mum^2} / time_reference}'
    value = flux_surface_right_d2o
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_right_d2o_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_flux_surface_right_d2o
  []
  [scaled_flux_surface_right]
    type = SumPostprocessor
    values = 'scaled_flux_surface_right_d2 scaled_flux_surface_right_d2o'
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_right_physical]
    type = ScalePostprocessor
    scaling_factor = 1
    value = scaled_flux_surface_right
  []
[]

[VectorPostprocessors]
  [line_profile]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${profile_depth_hat} 0 0'
    num_points = ${profile_num_points}
    sort_by = x
    variable = 'deuterium_total_physical deuterium_mobile_physical deuterium_trapped_intrinsic_physical
    deuterium_trapped_1_physical deuterium_trapped_2_physical deuterium_trapped_3_physical
    deuterium_trapped_4_physical deuterium_trapped_5_physical'
    execute_on = INITIAL
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
  end_time = ${end_time_hat}
  solve_type = Newton
  scheme = bdf2
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_type -snes_type'
  petsc_options_value = 'lu       mumps                      vinewtonrsls'
  line_search = none
  automatic_scaling = true
  nl_rel_tol = 1e-9
  nl_abs_tol = 1e-10
  nl_max_its = 30
  l_tol = 1e-8
  dtmax = 20
  abort_on_solve_fail = true
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = '${fparse 1 / time_reference}'
    optimal_iterations = 8
    growth_factor = 1.2
    cutback_factor = 0.8
  []
  [Predictor]
    type = SimplePredictor
    scale = 1.0
  []
[]

[Outputs]
  file_base = val-2k_5nm_oxide_out
  [exodus]
    type = Exodus
    time_step_interval = 10
  []
  [csv]
    type = CSV
  []
  [profile_out]
    type = CSV
    sync_only = true
    sync_times = '0'
    execute_vector_postprocessors_on = 'INITIAL'
    execute_postprocessors_on = NONE
    file_base = val-2k_5nm_oxide_profile_initial_out
  []
[]
