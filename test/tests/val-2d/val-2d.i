# General parameters
k = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)

# Model parameters
nx_scale = 2
simulation_time = '${units 6.8e3 s}'

# Diffusion parameters
flux_high = '${units 1e19 at/m^2/s -> at/mum^2/s}'
flux_low = '${units 0      at/mum^2/s}'
diffusivity_coefficient = '${units 4.1e-7 m^2/s -> mum^2/s}'
E_D = '${units 0.39 eV -> J}'
initial_concentration = '${units 1e-10 at/m^3 -> at/mum^3}'
width_source = '${units 3e-9 m -> mum}'
depth_source = '${units 4.6e-9 m -> mum}'

# Traps parameters
N = '${units 6.25e28 at/m^3 -> at/mum^3}'
initial_concentration_trap_2 = 4.4e-10 # (-)
initial_concentration_trap_3 = 1.4e-10 # (-)
trapping_energy = '${fparse ${units 0.39 eV -> J} / ${k}}'
detrapping_energy_1 = '${fparse ${units 1.2 eV -> J} / ${k}}'
detrapping_energy_2 = '${fparse ${units 1.6 eV -> J} / ${k}}'
detrapping_energy_3 = '${fparse ${units 3.1 eV -> J} / ${k}}'
trapping_site_fraction_1 = 0.002156 # (-)
trapping_site_fraction_2 = 0.00175 # (-) 0.00135
trapping_site_fraction_3 = 0.0020 # (-) 0.0010
trapping_rate_prefactor = '${units 9.1316e12 1/s}'
release_rate_profactor = '${units 8.4e12 1/s}'
trap_per_free_1 = 1e6 # (-)
trap_per_free_2 = 1e4 # (-)
trap_per_free_3 = 1e4 # (-)
width_trap1 = '${units 10e-9 m -> mum}'

# thermal parameters
temperature_low = '${units 300 K}'
temperature_high = '${units 1273 K}'

[Mesh]
  [cartesian_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${fparse 10 * ${units 1.5e-9 m -> mum}}
          ${units 1e-9 m -> mum}       ${units 1e-8 m -> mum}     ${units 1e-7 m -> mum}
          ${units 4e-6 m -> mum}     ${units 2e-6 m -> mum}  ${units 2.407e-6 m -> mum}   ${fparse 11 * ${units 7.407e-6 m -> mum}}'
    ix = '${fparse 10 * ${nx_scale}}
          ${fparse 1 * ${nx_scale}}    ${fparse 4 * ${nx_scale}}   ${fparse 4 * ${nx_scale}}
          ${fparse 30 * ${nx_scale}} ${fparse 15 * ${nx_scale}}  ${fparse 1 * ${nx_scale}}   ${fparse 11 * ${nx_scale}}'
    subdomain_id = '0 1 1 1 1 1 1 1'
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
    block = 0
  []
  [trapped_2]
    order = FIRST
    family = LAGRANGE
    initial_condition = '${fparse ${initial_concentration_trap_2} * ${trapping_site_fraction_2} * ${N}}'
  []
  [trapped_3]
    order = FIRST
    family = LAGRANGE
    initial_condition = '${fparse ${initial_concentration_trap_3} * ${trapping_site_fraction_3} * ${N}}'
  []
[]

[AuxVariables]
  [temperature]
  []
[]

[AuxKernels]
  [temperature_Aux]
    type = FunctionAux
    variable = temperature
    function = Temperature_func
  []
[]

[Kernels]
  [diffusion_implantation]
    type = ADMatDiffusion
    variable = concentration
    diffusivity = Diffusivity
    extra_vector_tags = ref
  []
  [time_diffusion_implantation]
    type = ADTimeDerivative
    variable = concentration
    extra_vector_tags = ref
  []
  [source]
    type = ADBodyForce
    variable = concentration
    function = concentration_source_norm_func
  []

  # trapping kernel
  [coupled_time_trap_1]
    type = ADCoefCoupledTimeDerivative
    variable = concentration
    v = trapped_1
    coef = ${trap_per_free_1}
    block = 0
    extra_vector_tags = ref
  []
  [coupled_time_trap_2_implan]
    type = ADCoefCoupledTimeDerivative
    variable = concentration
    v = trapped_2
    coef = ${trap_per_free_2}
    extra_vector_tags = ref
  []
  [coupled_time_trap_3_implan]
    type = ADCoefCoupledTimeDerivative
    variable = concentration
    v = trapped_3
    coef = ${trap_per_free_3}
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  # For first traps
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
    Ct0 = 'trap_1_distribution_func'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_1}
    extra_vector_tags = ref
  []
  [release_1]
    type = ReleasingNodalKernel
    variable = trapped_1
    alpha_r = '${release_rate_profactor}'
    detrapping_energy = '${detrapping_energy_1}'
    temperature = 'temperature'
  []

  # For second traps
  [time_2]
    type = TimeDerivativeNodalKernel
    variable = trapped_2
  []
  [trapping_2_implan]
    type = TrappingNodalKernel
    variable = trapped_2
    mobile_concentration = concentration
    alpha_t = '${trapping_rate_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${N}'
    Ct0 = '${trapping_site_fraction_2}'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_2}
    extra_vector_tags = ref
  []
  [release_2_implan]
    type = ReleasingNodalKernel
    variable = trapped_2
    alpha_r = '${release_rate_profactor}'
    detrapping_energy = '${detrapping_energy_2}'
    temperature = 'temperature'
  []

  # For third traps
  [time_3]
    type = TimeDerivativeNodalKernel
    variable = trapped_3
  []
  [trapping_3_implan]
    type = TrappingNodalKernel
    variable = trapped_3
    mobile_concentration = concentration
    alpha_t = '${trapping_rate_prefactor}'
    trapping_energy = '${trapping_energy}'
    N = '${N}'
    Ct0 = '${trapping_site_fraction_3}'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free_3}
    extra_vector_tags = ref
  []
  [release_3_implan]
    type = ReleasingNodalKernel
    variable = trapped_3
    alpha_r = '${release_rate_profactor}'
    detrapping_energy = '${detrapping_energy_3}'
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
  [Diffusivity_implantation]
    type = ADDerivativeParsedMaterial
    property_name = 'Diffusivity'
    functor_names = 'Temperature_func'
    functor_symbols = 'Temperature_func'
    expression = '${diffusivity_coefficient} * exp(- ${E_D} / ${k} / Temperature_func)'
    block = 0
    output_properties = 'Diffusivity'
  []
  [Diffusivity_Tungsten]
    type = ADDerivativeParsedMaterial
    property_name = 'Diffusivity'
    functor_names = 'Temperature_func'
    functor_symbols = 'Temperature_func'
    expression = '${diffusivity_coefficient} * exp(- ${E_D} / ${k} / Temperature_func) * 10'
    block = 1
    output_properties = 'Diffusivity'
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'Diffusivity'
    reg_props_out = 'Diffusivity_nonAD'
    outputs = none
  []
[]

[Functions]
  [Temperature_func]
    type = ADParsedFunction
    expression = 'if(t<5000.0,                                                      ${temperature_low},
                  if(t<5000 + (${temperature_high} - ${temperature_low}) / (50/60), ${temperature_low} + (50/60) * (t - 5000),
                                                                                    ${temperature_high}))'
  []

  [surface_flux_func]
    type = ADParsedFunction
    expression = 'if(t<5000.0, ${flux_high}, ${flux_low})'
  []

  [source_distribution_func]
    type = ADParsedFunction
    expression = '1 / ( ${width_source} * sqrt(2 * pi) ) * exp(-0.5 * ((x - ${depth_source}) / ${width_source} ) ^ 2)'
  []

  [trap_1_distribution_func]
    type = ADParsedFunction
    expression = ' ${trapping_site_fraction_1} / ( ${width_trap1} * sqrt(2 * pi) ) * exp(-0.5 * ((x - ${depth_source}) / ${width_trap1}) ^ 2)'
  []

  [concentration_source_norm_func]
    type = ADParsedFunction
    symbol_names = 'source_distribution_func surface_flux_func'
    symbol_values = 'source_distribution_func surface_flux_func'
    expression = 'source_distribution_func * surface_flux_func'
  []

  [max_dt_size_func]
    type = ADParsedFunction
    expression = 'if(t<5000      , 15,
                  if(t<5405-5.0 , 80,
                  if(t<5405-1.0 ,  6,
                  if(t<6800     ,  80, 100))))'
  []
[]

[Postprocessors]
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = 'Diffusivity_nonAD'
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
    diffusivity = 'Diffusivity_nonAD'
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
    function = max_dt_size_func
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
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  end_time = ${simulation_time}
  line_search = 'none'
  automatic_scaling = true
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-5
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.5
    iteration_window = 3
    optimal_iterations = 10
    growth_factor = 1.1
    cutback_factor = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

[Outputs]
  file_base = 'val-2d_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
    time_step_interval = 4
  []
[]
