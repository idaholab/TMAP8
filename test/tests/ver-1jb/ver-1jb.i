# Verification Problem #1a from TMAP7 V&V document
# Radioactive Decay of Mobile Tritium in a Slab

############################################### I NEED TO ADD DECAY FOR TRAPPED TRITIUM ###########
# need to deal with convergence

# Physical Constants
ideal_gas_constant = 8.31446261815324 # J/K/mol - from PhysicalConstants.h
boltzmann_constant = 8.6173303e-5 # eV/K - from PhysicalConstants.h

# Case and model parameters (adapted from TMAP7)
slab_length = 1.5 # m
tritium_concentration_initial = ${units 1 atoms/m3}
# trapping_sites_concentration_max = 5e25 # atoms/m3
trapping_sites_atomic_fraction_max = ${units 0.001 at.frac.}
trapping_sites_fraction_occupied_initial = 0.5 # (-)
normal_center_position = ${fparse slab_length/2} # m
normal_standard_deviation = ${fparse slab_length/4} # m
density_material = ${units 6.34e28 atoms/m^3} # for tungsten
temperature = ${units 300 K} # assumed (TMAP7's input file lists 273 K)
tritium_diffusivity_prefactor = ${units 1.58e-4 m^2/s} # from TMAP7 V&V input file
tritium_diffusivity_energy = ${units 308000.0 J/K} # from TMAP7 V&V input file
tritium_release_prefactor = ${units 1.0e13 1/s} # from TMAP7 V&V input file
tritium_release_energy = ${units 4.2 eV}
tritium_trapping_prefactor = ${units 2.096e15 1/s} # from TMAP7 V&V input file
tritium_trapping_energy = ${tritium_diffusivity_energy} # 1/s - from TMAP7 V&V input file
trap_per_free = 1 #1e25 # (-)
half_life_s = ${units 12.3232 year -> s}
decay_rate_constant = ${fparse 0.693/half_life_s} # 1/s

# Simulation parameters
num_mesh_element = 50
end_time = ${units 100 year -> s} # s
dt_start = ${fparse end_time/250} # s

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${num_mesh_element}
  xmax = ${slab_length}
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  # tritium mobile concentration in atoms/m^3
  [tritium_mobile_concentration]
    initial_condition = ${tritium_concentration_initial}
  []
  # tritium trapped concentration in atoms/m^3
  [tritium_trapped_concentration]
  []
  # helium concentration in atoms/m^3
  [helium_concentration]
    # scaling = 1e-55
  []
[]

[Functions]
  [trapping_sites_fraction_function] # (atomic fraction)
    type = ParsedFunction
    expression = '${trapping_sites_atomic_fraction_max} * 1/${normal_standard_deviation} / sqrt(2*pi) * exp(-1/2*((x-${normal_center_position})/${normal_standard_deviation})^2)'
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [density_material_function] # (atoms/m^3)
    type = ConstantFunction
    value = ${density_material}
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [trapping_sites_concentration_function] # (atoms/m^3)
    type = CompositeFunction
    functions = 'density_material_function trapping_sites_fraction_function'
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [initial_trapping_sites_occupied_function] # (-)
    type = ConstantFunction
    value = ${trapping_sites_fraction_occupied_initial}
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
  [tritium_trapped_concentration_initial_function] # (atoms/m^3)
    type = CompositeFunction
    functions = 'initial_trapping_sites_occupied_function trapping_sites_concentration_function'
    execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END'
  []
[]

[ICs]
  [tritium_trapped_concentration_IC]
    type = FunctionIC
    variable = tritium_trapped_concentration
    function = 'tritium_trapped_concentration_initial_function'
  []
[]

[AuxVariables]
  [empty_sites]
  []
  [scaled_empty_sites]
  []
  [trapped_sites]
  []
  [total_sites]
  []
  [temperature]
    initial_condition = ${temperature}
  []
[]

[AuxKernels]
  [empty_sites]
    variable = empty_sites
    type = EmptySitesAux
    N = ${fparse density_material} # atoms/m^3
    Ct0 = 'trapping_sites_fraction_function' # atomic fraction
    trap_per_free = ${trap_per_free}
    trapped_concentration_variables = tritium_trapped_concentration
  []
  [scaled_empty]
    variable = scaled_empty_sites
    type = NormalizationAux
    # normal_factor = ${cl}
    source_variable = empty_sites
  []
  [trapped_sites]
    variable = trapped_sites
    type = NormalizationAux
    normal_factor = ${trap_per_free}
    source_variable = tritium_trapped_concentration
  []
  [total_sites]
    variable = total_sites
    type = ParsedAux
    expression = 'trapped_sites + empty_sites'
    coupled_variables = 'trapped_sites empty_sites'
  []
[]

[Kernels]
  # kernels for the tritium concentration equation
  [time_tritium]
    type = TimeDerivative
    variable = tritium_mobile_concentration
    extra_vector_tags = ref
  []
  [diffusion]
    type = MatDiffusion
    variable = tritium_mobile_concentration
    diffusivity = diffusivity
    extra_vector_tags = ref
  []
  [decay_tritium]
    type = MatReaction
    variable = tritium_mobile_concentration
    v = tritium_mobile_concentration
    mob_name = '${fparse -decay_rate_constant}'
    extra_vector_tags = ref
  []
  [coupled_time_tritium]
    type = ScaledCoupledTimeDerivative
    variable = tritium_mobile_concentration
    v = tritium_trapped_concentration
    factor = ${trap_per_free}
    extra_vector_tags = ref
  []
  # re-adding it to the equation of mobile tritium because it is accounted for in coupled_time_tritium, and needs to be counter-balanced
  [decay_tritium_trapped]
    type = MatReaction
    variable = tritium_trapped_concentration
    v = tritium_trapped_concentration
    mob_name = '${fparse decay_rate_constant * trap_per_free}'
    extra_vector_tags = ref
  []
  # kernels for the helium concentration equation
  [time_helium]
    type = TimeDerivative
    variable = helium_concentration
    extra_vector_tags = ref
  []
  [decay_helium_mobile]
    type = MatReaction
    variable = helium_concentration
    v = tritium_mobile_concentration
    mob_name = '${decay_rate_constant}'
    extra_vector_tags = ref
  []
  [decay_helium_trapped]
    type = MatReaction
    variable = helium_concentration
    v = tritium_trapped_concentration
    mob_name = '${fparse decay_rate_constant * trap_per_free}'
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  [time]
    type = TimeDerivativeNodalKernel
    variable = tritium_trapped_concentration # (atoms/m^3) / trap_per_free
  []
  [trapping]
    type = TrappingNodalKernel
    variable = tritium_trapped_concentration # (atoms/m^3) / trap_per_free
    alpha_t = ${tritium_diffusivity_prefactor} # (1/s)
    trapping_energy = ${fparse tritium_diffusivity_energy/boltzmann_constant} # (K)
    N = ${fparse density_material} # (atoms/m^3)
    Ct0 = 'trapping_sites_fraction_function' # (atomic fraction)
    mobile_concentration = 'tritium_mobile_concentration' # (atoms/m^3)
    temperature = temperature # (K)
    trap_per_free = ${trap_per_free}
    extra_vector_tags = ref
  []
  [release]
    type = ReleasingNodalKernel
    variable = tritium_trapped_concentration # (atoms/m^3) / trap_per_free
    alpha_r = ${fparse tritium_release_prefactor} # (1/s)
    detrapping_energy = ${fparse tritium_release_energy / boltzmann_constant} # (K)
    temperature = temperature # (K)
  []
  [decay]
    type = ReleasingNodalKernel
    variable = tritium_trapped_concentration # (atoms/m^3) / trap_per_free
    alpha_r = ${decay_rate_constant} # (1/s) - decay rate
    detrapping_energy = 0 # (K) - The decay rate is not dependent on temperature
    temperature = temperature # (K)
  []
[]

[Materials]
  [diffusivity] # (m2/s) tritium diffusivity
    type = DerivativeParsedMaterial
    property_name = 'diffusivity'
    coupled_variables = 'temperature'
    expression = '${tritium_diffusivity_prefactor}*exp(-${tritium_diffusivity_energy}/${ideal_gas_constant}/temperature)'
  []
  [alpha_t_tot] # (1/s) - trapping rate
    type = ParsedMaterial
    property_name = 'alpha_t_tot'
    coupled_variables = 'temperature'
    expression = '${tritium_trapping_prefactor} * exp(- ${fparse tritium_trapping_energy/boltzmann_constant}/temperature)'
    outputs = 'all'
  []
  [alpha_r_tot] # (1/s) - detrapping rate
    type = ParsedMaterial
    property_name = 'alpha_r_tot'
    coupled_variables = 'temperature'
    expression = '${tritium_release_prefactor} * exp(- ${fparse tritium_release_energy / boltzmann_constant}/temperature)'
    outputs = 'all'
  []
[]

[Postprocessors]
  # Amount of mobile tritium in the sample in atoms/m^2
  [tritium_mobile_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_mobile_concentration
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Amount of trapped tritium in the sample (moles/m^2) / trap_per_free
  [deuterium_trapped_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_trapped_concentration
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Amount of helium in the sample in atoms/m^2
  [helium_inventory]
    type = ElementIntegralVariablePostprocessor
    variable = helium_concentration
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[VectorPostprocessors]
  [line]
      type = LineValueSampler
      start_point = '0 0 0'
      end_point = '${slab_length} 0 0'
      num_points = ${num_mesh_element}
      sort_by = 'x'
      variable = 'tritium_mobile_concentration tritium_trapped_concentration helium_concentration'
      execute_on = timestep_end
  []
[]

[Executioner]
  type = Transient
  dt = ${dt_start}
  end_time = ${end_time}
  solve_type = PJFNK
  scheme = 'bdf2'
  dtmin = 1
  l_max_its = 10
  nl_max_its = 5
  nl_rel_tol = 1e-07
  petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
[]

[Outputs]
  perf_graph = true
  csv = true
  exodus = true
[]
