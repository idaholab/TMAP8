# Validation Problem #val-2k
# Incremental validation case for deuterium release from self-irradiated tungsten with
# natural and artificial oxide layers based on:
# Kremer, K., Brucker, M., Jacob, W., Schwarz-Selinger, T. (2022)
# "Influence of thin surface oxide films on hydrogen isotope release from ion-irradiated tungsten"
#
# This first implementation stage only models the natural-oxide baseline.
# Included physics:
# - deuterium diffusion in tungsten
# - six scaled val-2f trap families in the self-irradiated layer
# - D2 surface recombination on both surfaces
# Deferred to later stages:
# - explicit hydrogen-containing species
# - water formation
# - explicit oxide transport layer
# - oxide reduction

!include parameters_val-2k.params
!include val-2k_traps.i
!include val-2k_surface_natural_oxide.i

[Mesh]
  active = mesh_fine
  [mesh_fine]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${damage_depth} ${buffer_depth} ${bulk_depth}'
    ix = '${ix_damage_fine} ${ix_buffer_fine} ${ix_bulk_fine}'
    subdomain_id = '0 0 0'
  []
  [mesh_coarse]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${damage_depth} ${buffer_depth} ${bulk_depth}'
    ix = '${ix_damage_coarse} ${ix_buffer_coarse} ${ix_bulk_coarse}'
    subdomain_id = '0 0 0'
  []
[]

[Variables]
  [deuterium_mobile]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${initial_mobile_concentration}
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = ${temperature_initial}
  []
[]

[Kernels]
  [mobile_time]
    type = ADTimeDerivative
    variable = deuterium_mobile
  []
  [mobile_diffusion]
    type = ADMatDiffusion
    variable = deuterium_mobile
    diffusivity = diffusivity_W
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_history
    execute_on = 'INITIAL LINEAR TIMESTEP_END'
  []
[]

[Functions]
  [temperature_history]
    type = ParsedFunction
    expression = 'temperature_initial + temperature_rate * t'
    symbol_names = 'temperature_initial temperature_rate'
    symbol_values = '${temperature_initial} ${temperature_rate}'
  []
[]

[Materials]
  [diffusivity_W_material]
    type = ADDerivativeParsedMaterial
    property_name = diffusivity_W
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${diffusion_W_preexponential} * exp(-${diffusion_W_energy} / ${kb_eV} / temperature)'
  []
  [diffusivity_W_nonad]
    type = MaterialADConverter
    ad_props_in = diffusivity_W
    reg_props_out = diffusivity_W_nonad
  []
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = Kr
    functor_names = 'temperature_history'
    functor_symbols = temperature
    expression = '${recombination_coefficient} * exp(-${recombination_energy} / ${kb_eV} / temperature)'
  []
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = deuterium_mobile
    property_name = flux_recombination_surface
    material_property_names = Kr
    expression = '-2 * Kr * deuterium_mobile ^ 2'
  []
[]

[Postprocessors]
  [integral_mobile]
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_mobile
    outputs = none
  []
  [scaled_mobile]
    type = ScalePostprocessor
    scaling_factor = '${fparse ${units 1 m^2 -> mum^2}}'
    value = integral_mobile
  []
  [flux_surface_left]
    type = ADSideAverageMaterialProperty
    boundary = left
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_left
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [flux_surface_right]
    type = ADSideAverageMaterialProperty
    boundary = right
    property = flux_recombination_surface
    outputs = none
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
    value = flux_surface_right
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
[]

[VectorPostprocessors]
  [line_profile]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${profile_depth} 0 0'
    num_points = ${profile_num_points}
    sort_by = x
    variable = 'deuterium_mobile deuterium_trapped_intrinsic deuterium_trapped_1 deuterium_trapped_2 deuterium_trapped_3 deuterium_trapped_4 deuterium_trapped_5'
    execute_on = INITIAL
  []
[]

[Executioner]
  type = Transient
  end_time = ${end_time}
  solve_type = NEWTON
  scheme = bdf2
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
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
    dt = 1.0
    optimal_iterations = 8
    growth_factor = 1.2
    cutback_factor = 0.8
  []
[]

[Outputs]
  file_base = val-2k_out
  exodus = true
  [csv]
    type = CSV
  []
  [profile_out]
    type = CSV
    sync_only = true
    sync_times = '0'
    execute_vector_postprocessors_on = 'INITIAL'
    execute_postprocessors_on = NONE
    file_base = val-2k_profile_initial_out
  []
[]
