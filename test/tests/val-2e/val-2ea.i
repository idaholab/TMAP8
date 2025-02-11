# Validation Problem #2ea from TMAP4/TMAP7 V&V document
# Deuterium permeation through 0.05-mm Pd at 825 K.
# No Soret effect, or trapping included.

# Physical Constants
# Note that we do NOT use the same number of digits as in TMAP4/TMAP7.
# This is to be consistent with PhysicalConstant.h
kb = '${units 1.380649e-23 J/K}' # Boltzmann constant
R = '${units 8.31446261815324 J/mol/K}' # Gas constant

# Enclosure data used in TMAP7 case
surface_area = '${units 1.8e-4 m^2 -> mum^2}'
temperature = '${units 825 K}'
pressure_enclosure1 = '${units 1e-6 Pa}'
pressure_enclosure4 = '${units 1e-10 Pa}'
pressure_initial = '${units 1e-6 Pa}'
volume_enclosure = '${units 0.005 m^3 -> mum^3}'
flow_rate = '${units 0.1 m^3/s -> mum^3/s}'
flow_rate_by_V = '${fparse flow_rate / volume_enclosure}'

# Diffusion data used in TMAP7 case
diffusivity_pre_D = '${units 2.636e-4 m^2/s -> mum^2/s}'
diffusivity_energy_D = '${units ${fparse 1315.8 * R} J/mol}'
solubility_exponent = 0.9297 # -
solubility_pre = '${units ${fparse 9.355e22 / 1e18} at/mum^3/Pa^0.9297}'
solubility_energy = '${units ${fparse 5918 * R} J/mol}'

# Modeling data used in current case
slab_thickness = '${units 5e-5 m -> mum}'
num_node = 20 # -
concentration_to_pressure_conversion_factor = '${units ${fparse kb*temperature} Pa*m^3 -> Pa*mum^3}'
file_name = 'val-2ea_out'
simulation_time = '${units 1900 s}'

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

[Variables]
  # concentration in the SiC layer in atoms/microns^3
  [D2_pressure_upstream]
    initial_condition = '${pressure_initial}'
  []
  [D2_pressure_downstream]
    initial_condition = '${pressure_initial}'
  []
  [D_concentration]
    initial_condition = 0
  []
[]

[AuxVariables]
  [D2_pressure_enclosure1]
    initial_condition = '${pressure_enclosure1}'
  []
  [D2_pressure_enclosure4]
    initial_condition = '${pressure_enclosure4}'
  []
  [D2_pressure_enclosure5]
  []
[]

[AuxKernels]
  [D2_pressure_enclosure5_kernel]
    type = FunctionAux
    variable = D2_pressure_enclosure5
    function = D2_pressure_enclosure5_function
  []
[]

[Functions]
  [D2_pressure_enclosure5_function]
    type = ParsedFunction
    expression = 'if(t < 150, 1.20e-4,
                  if(t < 250, 2.41e-4,
                  if(t < 350, 6.06e-4,
                  if(t < 450, 1.30e-3,
                  if(t < 550, 2.53e-3,
                  if(t < 650, 7.08e-3,
                  if(t < 750, 1.45e-2,
                  if(t < 850, 2.63e-2,
                  if(t < 950, 6.51e-2,
                  if(t < 1050, 0.116,
                  if(t < 1150, 0.297,
                  if(t < 1250, 0.760,
                  if(t < 1350, 1.550,
                  if(t < 1900, 3.370, 3.370))))))))))))))'
  []
[]

[Kernels]
  # Gas flow kernels
  # Equation for enclosure upstream
  [timeDerivative_upstream]
    type = ADTimeDerivative
    variable = D2_pressure_upstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_influx_1]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'D2_pressure_enclosure5'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_influx_5]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'D2_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_outflux_4]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = 'D2_pressure_upstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_upstream_outflux_membrane]
    type = ADMatReaction
    variable = D2_pressure_upstream
    v = ''
    reaction_rate = 'membrane_reaction_rate_right'
    extra_vector_tags = 'ref'
  []
  # Equation for enclosure downstream
  [timeDerivative_downstream]
    type = ADTimeDerivative
    variable = D2_pressure_downstream
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_influx_1]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'D2_pressure_enclosure1'
    reaction_rate = ${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_influx_membrane]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = ''
    reaction_rate = 'membrane_reaction_rate_left'
    extra_vector_tags = 'ref'
  []
  [MatReaction_downstream_outflux_4]
    type = ADMatReaction
    variable = D2_pressure_downstream
    v = 'D2_pressure_downstream'
    reaction_rate = -${flow_rate_by_V}
    extra_vector_tags = 'ref'
  []
  # Diffusion kernels
  [timeDerivative_diffusion]
    type = ADTimeDerivative
    variable = D_concentration
    extra_vector_tags = 'ref'
  []
  [MatDiffusion_diffusion]
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
  [membrane_reaction_rate_right]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_right'
    postprocessor_names = flux_surface_right
    expression = 'flux_surface_right * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [membrane_reaction_rate_left]
    type = ADParsedMaterial
    property_name = 'membrane_reaction_rate_left'
    postprocessor_names = flux_surface_left
    expression = 'flux_surface_left * ${surface_area} / ${volume_enclosure} * ${concentration_to_pressure_conversion_factor}'
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_D'
    reg_props_out = 'diffusivity_D_nonAD'
    outputs = none
  []
[]

[BCs]
  # The surface of the slab in contact with the source is assumed to be in equilibrium with the source enclosure
  [right_diffusion]
    type = EquilibriumBC
    variable = D_concentration
    enclosure_var = D2_pressure_upstream
    boundary = 'right'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
  [left_diffusion]
    type = EquilibriumBC
    variable = D_concentration
    enclosure_var = D2_pressure_downstream
    boundary = 'left'
    Ko = '${solubility_pre}'
    activation_energy = '${solubility_energy}'
    p = '${solubility_exponent}'
    temperature = ${temperature}
  []
[]

[Postprocessors]
  # Pressure
  [pressure_upstream]
    type = ElementAverageValue
    variable = D2_pressure_upstream
  []
  [pressure_downstream]
    type = ElementAverageValue
    variable = D2_pressure_downstream
  []
  # Flux
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = D_concentration
    diffusivity = diffusivity_D_nonAD
    boundary = 'right'
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = D_concentration
    diffusivity = diffusivity_D_nonAD
    boundary = 'left'
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
  # scale the flux to get inward direction
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = -1
    value = flux_surface_left
    execute_on = 'initial timestep_end'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = -1
    value = flux_surface_right
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
  compute_scaling_once = false
  nl_rel_tol = 1e-12
  nl_abs_tol = 1e-12
  dtmax = 5
  end_time = ${simulation_time}
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    optimal_iterations = 12
    iteration_window = 1
    growth_factor = 1.1
    cutback_factor = 0.9
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
