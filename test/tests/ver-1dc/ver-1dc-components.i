# This input shows the Component-Physics syntax for the ver-1dc case.
# The ver-1dc case is formed without this syntax by combining ver-1dc_base.i and ver-1dc.i

epsilon_1 = ${units 100 K}
epsilon_2 = ${units 500 K}
epsilon_3 = ${units 800 K}
temperature = ${units 1000 K}
trapping_site_fraction_1 = 0.10 # (-)
trapping_site_fraction_2 = 0.15 # (-)
trapping_site_fraction_3 = 0.20 # (-)
diffusivity = 1 # m^2/s

cl = ${units 3.1622e18 atom/m^3}
N = ${units 3.1622e22 atom/m^3}
nx_num = 1000 # (-)
trapping_rate_coefficient = ${units 1e15 1/s}
release_rate_coefficient = ${units 1e13 1/s}
simulation_time = ${units 60 s}
time_interval_max = ${units 0.3 s}
time_step = ${units 1e-6 s}
scheme = BDF2


[ActionComponents]
  [structure]
    type = Structure1D
    species = 'mobile trapped_1 trapped_2 trapped_3'
    physics = 'multi-D trapping'

    # Boundary conditions
    fixed_value_bc_variables = 'mobile'
    fixed_value_bc_boundaries = 'structure_left structure_right'
    fixed_value_bc_values = '${fparse cl / cl} 0'

    # Geometry
    nx = ${nx_num}
    xmax = 1
    length_unit_scaling = 1
  []
[]

[Physics]
  [Diffusion]
    [multi-D]
      variable_name = 'mobile'
      diffusivity_matprop = '1'

      # Does not work for the species trapping
      preconditioning = 'defer'
    []
  []
  [SpeciesTrapping]
    [trapping]
        species = 'trapped_1 trapped_2 trapped_3'
        mobile = 'mobile mobile mobile'
        species_initial_concentrations = '0 0 0' #'${units 1.0e-15 m^-3} ${units 1.0e-15 m^-3} ${units 1.0e-15 m^-3}'
        separate_variables_per_component = false

        temperature = '${temperature}'

        alpha_t = '${trapping_rate_coefficient} ${trapping_rate_coefficient} ${trapping_rate_coefficient}'
        trapping_energy = '0 0 0'
        N = '${fparse N / cl}'
        Ct0 = '${trapping_site_fraction_1} ${trapping_site_fraction_2} ${trapping_site_fraction_3}'
        trap_per_free = 1.0e0
        different_traps_for_each_species = true

        alpha_r = '${release_rate_coefficient} ${release_rate_coefficient} ${release_rate_coefficient}'
        detrapping_energy = '${epsilon_1} ${epsilon_2} ${epsilon_3}'
    []
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
  end_time = ${simulation_time}
  dtmax = ${time_interval_max}
  solve_type = NEWTON
  scheme = ${scheme}
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = 'none'

  automatic_scaling = true
  nl_abs_tol = 5e-8
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'structure_right'
    diffusivity = '${diffusivity}'
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = '${cl}'
  []
[]

[Executioner]
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${time_step}
    optimal_iterations = 9
    growth_factor = 1.1
    cutback_factor = 0.909
  []
[]

[Outputs]
  exodus = true
  csv = true
  [dof]
    type = DOFMap
    execute_on = initial
  []
  perf_graph = true
[]

[AuxVariables]
  [empty_sites_1]
  []
  [scaled_empty_sites_1]
  []
  [empty_sites_2]
  []
  [scaled_empty_sites_2]
  []
  [empty_sites_3]
  []
  [scaled_empty_sites_3]
  []
  [trapped_sites_1]
  []
  [trapped_sites_2]
  []
  [trapped_sites_3]
  []
  [total_sites]
  []
[]

[AuxKernels]
  [empty_sites_1]
    variable = empty_sites_1
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_1}'
    trapped_concentration_variables = trapped_1
  []
  [scaled_empty_1]
    variable = scaled_empty_sites_1
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_1
  []
  [empty_sites_2]
    variable = empty_sites_2
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_2}'
    trapped_concentration_variables = trapped_2
  []
  [scaled_empty_2]
    variable = scaled_empty_sites_2
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_2
  []
  [empty_sites_3]
    variable = empty_sites_3
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_3}'
    trapped_concentration_variables = trapped_3
  []
  [scaled_empty_3]
    variable = scaled_empty_sites_3
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_3
  []
  [trapped_sites_1]
    variable = trapped_sites_1
    type = NormalizationAux
    source_variable = trapped_1
  []
  [trapped_sites_2]
    variable = trapped_sites_2
    type = NormalizationAux
    source_variable = trapped_2
  []
  [trapped_sites_3]
    variable = trapped_sites_3
    type = NormalizationAux
    source_variable = trapped_3
  []
  [total_sites]
    variable = total_sites
    type = ParsedAux
    expression = 'trapped_sites_1 + trapped_sites_2 + trapped_sites_3 + empty_sites_1 + empty_sites_2 + empty_sites_3'
    coupled_variables = 'trapped_sites_1 trapped_sites_2 trapped_sites_3 empty_sites_1 empty_sites_2 empty_sites_3'
  []
[]
