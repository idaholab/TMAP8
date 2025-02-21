# Base input file for Validation Problem #2ea #2eb #2ec #2ed #2ee
# Include [Mesh], [Problem], [Kernels] for D2 and D, [Materials] for D,
# [Postprocessors] for D2 and D, [Debug], [Preconditioning],
# [Executioner] and [Outputs] blocks

# This input file is not meant to run on its own and is included in case-specific input files.

# Enclosure data used in TMAP7 case
surface_area = '${units 1.8e-4 m^2 -> mum^2}'
pressure_enclosure4 = '${units 1e-10 Pa}'
volume_enclosure = '${units 0.005 m^3 -> mum^3}'
flow_rate = '${units 0.1 m^3/s -> mum^3/s}'
flow_rate_by_V = '${fparse flow_rate / volume_enclosure}'

# Diffusion data used in TMAP7 case
diffusivity_pre_D = '${units 2.636e-4 m^2/s -> mum^2/s}'
diffusivity_energy_D = '${units ${fparse 1315.8 * R} J/mol}'

# Modeling data used in current case
num_node = 20 # -
concentration_to_pressure_conversion_factor = '${units ${fparse kb*temperature} Pa*m^3 -> Pa*mum^3}'

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 1
    nx = '${num_node}'
    xmax = '${slab_thickness}'
  []
[]

[Problem]
  type = ReferenceResidualProblem
  reference_vector = 'ref'
  extra_tag_vectors = 'ref'
[]

[Kernels]
  # Gas flow kernels
  # Equation for D2 in enclosure upstream
  [timeDerivative_upstream_D2]
    type = ADTimeDerivative
    variable = D2_pressure_upstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_D2_influx_5]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'D2_pressure_enclosure5'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_D2_influx_1]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'D2_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_D2_outflux_4]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'D2_pressure_upstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  # Equation for enclosure downstream
  [timeDerivative_D2_downstream]
    type = ADTimeDerivative
    variable = D2_pressure_downstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_D2_influx_1]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'D2_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_D2_outflux_4]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'D2_pressure_downstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []

  # Diffusion kernels
  [timeDerivative_diffusion_D]
    type = ADTimeDerivative
    variable = D_concentration
    extra_vector_tags = 'ref'
  []
  [MatDiffusion_diffusion_D]
    type = ADMatDiffusion
    variable = D_concentration
    diffusivity = diffusivity_D
    extra_vector_tags = 'ref'
  []
[]

[Materials]
  [diffusivity_D]
    type = ADParsedMaterial
    property_name = 'diffusivity_D'
    expression = '${diffusivity_pre_D} * exp( - ${diffusivity_energy_D} / ${R} / ${temperature})'
  []
[]

[Postprocessors]
  # Pressure
  [pressure_upstream_D2]
    type = SideAverageValue
    variable = D2_pressure_upstream
    boundary = right
  []
  [pressure_downstream_D2]
    type = SideAverageValue
    variable = D2_pressure_downstream
    boundary = left
  []
  # Flux
  [flux_surface_right_D]
    type = SideDiffusiveFluxIntegral
    variable = D_concentration
    diffusivity = diffusivity_D_nonAD
    boundary = 'right'
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_left_D]
    type = SideDiffusiveFluxIntegral
    variable = D_concentration
    diffusivity = diffusivity_D_nonAD
    boundary = 'left'
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true
  compute_scaling_once = true
  line_search = none
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  dtmax = 5
  end_time = ${simulation_time}
  nl_max_its = 15
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    optimal_iterations = 12
    iteration_window = 1
    growth_factor = 1.1
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
  []
[]

[Outputs]
  file_base = ${file_name}
  exodus = true
  perf_graph = true
  [csv]
    type = CSV
    execute_on = 'initial timestep_end'
  []
[]
