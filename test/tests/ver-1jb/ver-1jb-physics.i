# Verification Problem #1jb from TMAP7 V&V document
# Radioactive Decay of Tritium in a Distributed Trap

# Physical Constants
ideal_gas_constant = ${units 8.31446261815324 J/K/mol} # from PhysicalConstants.h
boltzmann_constant = ${units 1.380649e-23 J/K -> eV/K } # from PhysicalConstants.h

# Case and model parameters (adapted from TMAP7)
slab_length = ${units 1.5 m }
tritium_mobile_concentration_initial = ${units 1 atoms/m3}
trapping_sites_atomic_fraction_max = 0.001 # (-)
trapping_sites_fraction_occupied_initial = 0.5 # (-)
normal_center_position = ${fparse slab_length/2} # m
normal_standard_deviation = ${fparse slab_length/4} # m
density_material = ${units 6.34e28 atoms/m^3} # for tungsten
density_scalar = ${units 1e25 atoms/m^3} # used to scale variables and use a dimensionless system
temperature = ${units 300 K} # assumed (TMAP7's input file lists 273 K)
tritium_diffusivity_prefactor = ${units 1.58e-4 m^2/s} # from TMAP7 V&V input file
tritium_diffusivity_energy = ${units 308000.0 J/K} # from TMAP7 V&V input file
tritium_release_prefactor = ${units 1.0e13 1/s} # from TMAP7 V&V input file
tritium_release_energy = ${units 4.2 eV}
tritium_trapping_prefactor = ${units 2.096e15 1/s} # from TMAP7 V&V input file
tritium_trapping_energy = ${tritium_diffusivity_energy} # J/K - from TMAP7 V&V input file
trap_per_free = 1.e-25 # (-)
half_life_s = ${units 12.3232 year -> s}
decay_rate_constant = ${fparse 0.693/half_life_s} # 1/s

# Simulation parameters
num_mesh_element = 50
end_time = ${units 100 year -> s} # s
dt_start = ${fparse end_time/250} # s
dt_max = ${fparse end_time/100} # s

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${num_mesh_element}
  xmax = ${slab_length}
[]

[Functions]
  [trapping_sites_fraction_function] # (atomic fraction)
    type = ParsedFunction
    expression = '${trapping_sites_atomic_fraction_max} * exp(-1/2*((x-${normal_center_position})/${normal_standard_deviation})^2)'
  []
  [density_material_function] # (atoms/m^3)
    type = ConstantFunction
    value = ${density_material}
  []
  [trapping_sites_concentration_function] # (atoms/m^3)
    type = CompositeFunction
    functions = 'density_material_function trapping_sites_fraction_function'
  []
  [initial_trapping_sites_occupied_function] # (-)
    type = ConstantFunction
    value = ${trapping_sites_fraction_occupied_initial}
  []
  [tritium_trapped_concentration_initial_function] # (atoms/m^3)
    type = CompositeFunction
    functions = 'initial_trapping_sites_occupied_function trapping_sites_concentration_function'
  []
  [density_scalar_inverse_function] # (atoms/m^3)^(-1)
    type = ConstantFunction
    value = ${fparse 1/density_scalar}
  []
  [tritium_trapped_concentration_initial_function_scaled] # (-)
    type = CompositeFunction
    functions = 'density_scalar_inverse_function tritium_trapped_concentration_initial_function'
  []
[]

[AuxVariables]
  [empty_sites] # (-)
  []
  [scaled_empty_sites] # atoms/m^3
  []
  [trapped_sites] # (atoms/m^3)
  []
  [total_sites] # (atoms/m^3)
  []
  [temperature] # (K)
    initial_condition = ${temperature}
  []
  [tritium_mobile_concentration] # (atoms/m^3)
  []
  [tritium_trapped_concentration] # (atoms/m^3)
  []
  [helium_concentration] # (atoms/m^3)
  []
[]

[AuxKernels]
  [empty_sites]
    variable = empty_sites
    type = EmptySitesAux
    N = ${fparse density_material / density_scalar} # (-)
    Ct0 = 'trapping_sites_fraction_function' # atomic fraction
    trap_per_free = ${trap_per_free}
    trapped_concentration_variables = tritium_trapped_concentration_scaled
  []
  [scaled_empty_sites]
    variable = scaled_empty_sites
    type = NormalizationAux
    normal_factor = ${density_scalar}
    source_variable = empty_sites
  []
  [trapped_sites]
    variable = trapped_sites
    type = NormalizationAux
    normal_factor = ${density_scalar}
    source_variable = tritium_trapped_concentration_scaled
  []
  [total_sites]
    variable = total_sites
    type = ParsedAux
    coupled_variables = 'trapped_sites scaled_empty_sites'
    expression = 'trapped_sites + scaled_empty_sites'
  []
  [tritium_mobile_concentration]
    type = NormalizationAux
    variable = tritium_mobile_concentration
    normal_factor = ${density_scalar}
    source_variable = tritium_mobile_concentration_scaled
  []
  [tritium_trapped_concentration]
    type = NormalizationAux
    variable = tritium_trapped_concentration
    # Scaling here
    normal_factor = ${fparse density_scalar * trap_per_free}
    source_variable = tritium_trapped_concentration_scaled
  []
  [helium_concentration]
    type = NormalizationAux
    variable = helium_concentration
    normal_factor = ${density_scalar}
    source_variable = helium_concentration_scaled
  []
[]

[Physics]
  [SpeciesDiffusionReaction]
    [decays]
      species                    = 'tritium_mobile_concentration_scaled                             helium_concentration_scaled'
      initial_conditions_species = '${fparse tritium_mobile_concentration_initial / density_scalar} 0'
      diffusivity_matprops       = 'diffusivity                                                     0'

      # we dont set the decay for the trapped helium concentration because it's using nodal
      # kernels in the original input which we are trying to reproduce
      reacting_species      = 'tritium_mobile_concentration_scaled'
      product_species       = 'helium_concentration_scaled'
      reaction_coefficients = '${decay_rate_constant}'
    []
  []
  [SpeciesTrapping]
    [trapped]
      species = 'tritium_trapped_concentration_scaled'
      mobile = 'tritium_mobile_concentration_scaled'
      species_initial_concentrations = 'tritium_trapped_concentration_initial_function_scaled'

      # Since we are not using components, we specify all the species trapping parameters here
      temperature = 'temperature'
      trap_per_free = ${trap_per_free}
      alpha_t = ${tritium_trapping_prefactor} # (1/s)
      trapping_energy = ${fparse tritium_trapping_energy/ideal_gas_constant} # (K)
      N = ${fparse density_material / density_scalar} # (-)
      Ct0 = 'trapping_sites_fraction_function' # (atomic fraction)
      alpha_r = ${fparse tritium_release_prefactor} # (1/s)
      detrapping_energy = ${fparse tritium_release_energy / boltzmann_constant} # (K)
    []
  []
[]


# Alternatively, we could create a nodal decay Physics OR add decay reactions to SpeciesTrapping
# Note that this approach, used by the reference input, is not conservative because of the differences
# in integration of the flux from one species to the other between the nodal and volumetric kernels.
[Kernels]
  [decay_trapped_to_helium]
    type = ADMatReactionFlexible
    reaction_rate_name = ${fparse decay_rate_constant}
    variable = helium_concentration_scaled
    vs = tritium_trapped_concentration_scaled
  []
[]
[NodalKernels]
  [decay_trapped_to_helium]
    type = ReleasingNodalKernel
    variable = tritium_trapped_concentration_scaled # (atoms/m^3) / density_scalar = (-)
    alpha_r = ${decay_rate_constant} # (1/s) - decay rate
    detrapping_energy = 0 # (K) - The decay rate is independent of temperature
    temperature = temperature # (K)
  []
[]

[Materials]
  [diffusivity] # (m2/s) tritium diffusivity
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity'
    coupled_variables = 'temperature'
    expression = '${tritium_diffusivity_prefactor}*exp(-${tritium_diffusivity_energy}/${ideal_gas_constant}/temperature)'
  []
  [alpha_t_tot] # (1/s) - trapping rate
    type = ADParsedMaterial
    property_name = 'alpha_t_tot'
    coupled_variables = 'temperature'
    expression = '${tritium_trapping_prefactor} * exp(- ${tritium_trapping_energy}/${ideal_gas_constant}/temperature)'
    outputs = 'all'
  []
  [alpha_r_tot] # (1/s) - detrapping rate
    type = ADParsedMaterial
    property_name = 'alpha_r_tot'
    coupled_variables = 'temperature'
    expression = '${tritium_release_prefactor} * exp(- ${tritium_release_energy} / ${boltzmann_constant}/temperature)'
    outputs = 'all'
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
  end_time = ${end_time}
  solve_type = NEWTON
  scheme = 'bdf2'
  dtmin = 1
  dtmax = ${dt_max}
  petsc_options = '-snes_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start}
    optimal_iterations = 9
    growth_factor = 1.2
    cutback_factor = 0.9
  []
[]

[Outputs]
  perf_graph = true
  file_base = ver-1jb-physics_out
  [time_dependent_out]
    type = CSV
    execute_vector_postprocessors_on = NONE
    file_base = ver-1jb-physics_time_dependent_out
  []
  [profile_out]
    type = CSV
    sync_only = true
    sync_times = '${units 45 year -> s}'
    execute_postprocessors_on = NONE
    file_base=ver-1jb-physics_profile_out
  []
[]

[Postprocessors]
  # Amount of mobile tritium in the sample in (atoms/m^3) / density_scalar * m = (m)
  [tritium_mobile_inventory_scaled]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_mobile_concentration_scaled
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [tritium_mobile_inventory] # (atoms/m^2)
    type = ScalePostprocessor
    value = tritium_mobile_inventory_scaled
    scaling_factor = ${density_scalar}
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Amount of trapped tritium in the sample (atoms/m^3) / density_scalar * m = (m)
  [tritium_trapped_inventory_scaled]
    type = ElementIntegralVariablePostprocessor
    variable = tritium_trapped_concentration_scaled
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [tritium_trapped_inventory] # (atoms/m^2)
    type = ScalePostprocessor
    value = tritium_trapped_inventory_scaled
    scaling_factor = ${density_scalar}
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # Amount of helium in the sample in atoms/m^3 / density_scalar * m = (m)
  [helium_inventory_scaled]
    type = ElementIntegralVariablePostprocessor
    variable = helium_concentration_scaled
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [helium_inventory] # (atoms/m^2)
    type = ScalePostprocessor
    value = helium_inventory_scaled
    scaling_factor = ${density_scalar}
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # check mass conservation - this should remain constant - (atoms/m^2)
  [total_inventory] # (atoms/m^2)
    type = SumPostprocessor
    values = 'tritium_mobile_inventory tritium_trapped_inventory helium_inventory'
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
      execute_on = 'timestep_end'
  []
[]
