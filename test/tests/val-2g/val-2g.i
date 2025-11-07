# General parameters
kB = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)

# Model parameters
TPE_hold_time = '${units 7200 s}'
TDS_initial_time = '${units 12000 s}'
TDS_ramp_end = '${units 17238 s}'
simulation_time = '${units 19038 s}'
outputs_initial_time = 0 #'${units 12000 s}'
step_interval_max = 50 # (-)
step_interval_mid = 15 # (-)
step_interval_min = 6 # (-)
# bound_value_max = '${units 2e4 at/mum^3}'
# bound_value_min = '${units -1e-10 at/mum^3}'

# Diffusion parameters
flux_high = '${units 7.1e21 at/m^2/s -> at/mum^2/s}'
flux_low = '${units 0      at/mum^2/s}'
diffusivity_coefficient = '${fparse ${units 4.1e-7 m^2/s -> mum^2/s} / sqrt(2)}'
E_D = '${units 0.39 eV -> J}'
initial_concentration = '${units 0.0 at/m^3 -> at/mum^3}' # '${units 1e-10 at/m^3 -> at/mum^3}'
width_source = '${units 3.58e-9 m -> mum}'
depth_source = '${units 2.64e-9 m -> mum}'

# Traps parameters
N = '${units 6.323e28 at/m^3 -> at/mum^3}'
initial_concentration_trap_1 = 2e-3 # (Trap/W)
activation_energy = '${fparse ${units 0.39 eV -> J} / ${kB}}' # Activation energy of D diffusion in W
trapping_energy = '${activation_energy}' # (K)
binding_energy = '${fparse ${units 1.41 eV -> J} / ${kB}}'
detrapping_energy_1 = '${fparse ${trapping_energy} + ${binding_energy}}' # (K)
W_lattice_constant = '${units 3.16e-10 m -> mum}'
trapping_rate_prefactor = '${fparse ${diffusivity_coefficient} / ${W_lattice_constant}^2}' # (1/s)
release_rate_prefactor = '${units 1e13 1/s}'
trap_per_free_1 = 1e4 # (-)


# Thermal parameters
temperature_exposure = '${units 400 degC -> K}'
time_constant = '${units 1200 s}'
temperature_TDS = '${units 1173 K}'
temperature_rate = '${fparse ${units 10 K} / ${units 60 s}}'
temperature_ambient = '${units 293 K}'
temperature_min = '${units 300 K}'

[Mesh]
  [cmg]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 500
    xmax = '${units 5e-4 m -> mum}'
  []
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  [concentration]
    order = FIRST
    family = LAGRANGE
    initial_condition = ${initial_concentration}
  []
  [trapped_1]
    order = FIRST
    family = LAGRANGE
    initial_condition = '${fparse initial_concentration_trap_1 * N}'
    #outputs = none
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
    execute_on = 'initial timestep_end linear'
  []
[]

[Kernels]
  [time_diffusion_implantation]
    type = ADTimeDerivative
    variable = concentration
    extra_vector_tags = ref
  []
  [diffusion_implantation]
    type = ADMatDiffusion
    variable = concentration
    diffusivity = diffusivity
    extra_vector_tags = ref
  []
  [source]
    type = ADBodyForce
    variable = concentration
    function = concentration_source_normal_function
  []

  # trapping kernel
  [coupled_time_trap_1]
    type = ADCoefCoupledTimeDerivative
    variable = concentration
    v = trapped_1
    coef = ${trap_per_free_1}
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  # First traps
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    mobile_concentration = concentration
    alpha_t = '${trapping_rate_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${N}'
    Ct0 = 0
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_1}
    extra_vector_tags = ref
  []
  [release_1]
    type = ReleasingNodalKernel
    variable = trapped_1
    alpha_r = '${release_rate_prefactor}'
    detrapping_energy = '${detrapping_energy_1}'
    temperature = 'temperature'
  []
[]

[BCs]
  [left]
    type = ADDirichletBC
    variable = concentration
    boundary = left
    value = 0
  []
  [right]
    type = ADDirichletBC
    variable = concentration
    boundary = right
    value = 0
  []
[]

[Materials]
  [diffusivity_tungsten]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity'
    functor_names = 'temperature_function'
    functor_symbols = 'temperature_function'
    expression = '${diffusivity_coefficient} * exp(- ${E_D} / ${kB} / temperature_function)'
    output_properties = 'diffusivity'
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity'
    reg_props_out = 'diffusivity_nonAD'
    outputs = none
  []
[]

[Functions]
  [temperature_function]
    type = ParsedFunction
    expression = 'if(t<${TPE_hold_time},   ${temperature_exposure},
                  if(t<${TDS_initial_time}, ${temperature_ambient} +
                       (${temperature_exposure} - ${temperature_ambient}) *
                       exp(-1.0 * (t - ${TPE_hold_time}) / ${time_constant}),
                  if(t<${TDS_ramp_end}, ${temperature_rate} * (t - ${TDS_initial_time}) +
                       ${temperature_min},
                  ${temperature_TDS})))'
  []

  [surface_flux_function]
    type = ParsedFunction
    expression = 'if(t<${TPE_hold_time}, ${flux_high}, ${flux_low})'
  []

  [source_distribution_function]
    type = ParsedFunction
    expression = '1 / ( ${width_source} * sqrt(2 * pi) ) * exp(-0.5 * ((x - ${depth_source}) / ${width_source} ) ^ 2)'
  []

  [concentration_source_normal_function]
    type = ParsedFunction
    symbol_names = 'source_distribution_function surface_flux_function'
    symbol_values = 'source_distribution_function surface_flux_function'
    expression = 'source_distribution_function * surface_flux_function'
  []

  [max_dt_size_function]
    type = ParsedFunction
    expression = 'if(t<${TDS_initial_time}, ${step_interval_mid}, ${step_interval_min})'
  []

  [max_dt_size_function_coarse]
    type = ParsedFunction
    expression = 'if(t<${TDS_initial_time}, ${step_interval_mid},
                  if(t<${TDS_ramp_end}, ${step_interval_min}, ${step_interval_max}))'
  []
[]

[Postprocessors]
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = 'diffusivity_nonAD'
    boundary = 'left'
    outputs = none
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${units 1 m^2 -> mum^2}'
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = 'diffusivity_nonAD'
    boundary = 'right'
    outputs = none
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${units 1 m^2 -> mum^2}'
    value = flux_surface_right
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_function
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
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -snes_type'
  petsc_options_value = 'lu vinewtonrsls'

  end_time = ${simulation_time}
  line_search = 'none'
  automatic_scaling = true
  nl_rel_tol = 1e-10
  nl_max_its = 34
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    iteration_window = 5
    optimal_iterations = 26
    growth_factor = 1.1
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Outputs]
  file_base = 'val-2g_out'
  [csv]
    type = CSV
    start_time = ${outputs_initial_time}
  []
  [exodus]
    type = Exodus
    start_time = ${outputs_initial_time}
    output_material_properties = true
    #time_step_interval = 20
  []
[]
