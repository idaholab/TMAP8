# Validation Problem #2l from TMAP4/TMAP7 V&V document

# !include val-2l.params

# Physical constants
kb = '${units 1.380649e-23 J/K}' # Boltzmann constant J/K - from PhysicalConstants.h
eV_to_J = '${units 1.602176634e-19 J/eV}' # Conversion coefficient from eV to Joules - from PhysicalConstants.h
kb_eV = '${units ${fparse kb / eV_to_J} eV/K}' # Boltzmann constant eV/K

# Temporal Parameters
# simulation_time = '${units 2 h -> s}' # 2 h TDS with temperature ramp
simulation_time = '${units 1 h -> s}' # Should be enough time to model unirradiated case
dt_start = '${units 1 s}'
dt_max = '${units 4 s}'
dt_min = '${units 1e-6 s}'

# Geometry
tungsten_thickness = '${units 0.2 mm -> mum}' # Tungsten disc thickness, Shimada et al. 2010 (p. S667, Section 2.1)

# Gaussian-hill initial condition (diagnostic profile; not from Shimada et al. 2010).
gaussian_amplitude = '${units 1e26 at/m^3 -> at/mum^3}' # Peak concentration at the center (= 1 at/mum^3)
gaussian_center = '${fparse ${tungsten_thickness} / 5}' # Hill center
gaussian_sigma = '${fparse ${tungsten_thickness} / 20}' # Hill standard deviation

# Temperature-dependent deuterium diffusivity used by Shimada et al. 2010 (p. S668, Section 3)
diffusivity_preexponential_factor = '${units 2.9e-7 m^2/s -> mum^2/s}' # D0 prefactor, Shimada et al. 2010 (p. S668)
diffusivity_activation_energy = '${units 0.39 eV}' # Diffusion activation energy, Shimada et al. 2010 (p. S668)

# Recombination parameters: Shimada et al. 2010 (p. S668)
recombination_preexponential_factor = '${units 3.2e-15 m^4/at/s -> mum^4/at/s}'
recombination_energy = '${units 1.16 eV}'

# Thermal parameters
temperature_tds_start = '${units 300 K}' # TDS ramp start (room temperature), Shimada et al. 2010 (p. S668, Figs. 2-4)
temperature_tds_end = '${units 1173 K}' # TDS ramp peak temperature, Shimada et al. 2010 (p. S668, Fig. 1)
temperature_rate = '${units ${fparse 10 / 60} K/s}' # TDS ramp rate of 10 K/min, Shimada et al. 2010 (p. S668, Fig. 1)

# Trapping Parameters
trap_depth = '${units 0.7 mum}'
tungsten_density = '${units 6.25e28 at/m^3 -> at/mum^3}' # Ambrosek and Longhurst 2008
trap_fraction = 0.04
trap_site_density = '${fparse ${trap_fraction} * ${tungsten_density}}'
alpha_t_0 = '${units 9.1316e12 1/s}' # Pulled from val-2d since it is a similar example
trapping_energy = '${units ${fparse 0.39 / kb_eV} K}' # pulled from val-2d
trap_per_free = 1e4 # User specified

# Detrapping Parameters
alpha_r_0 = '${units 8.4e12 1/s}' # val-2d
detrapping_energy = '${units ${fparse 1.35 / kb_eV} K}' # Unclear if Shimida 2011 means trapping or detrapping energy

# TMAP7 fit A Trapping Parameters

# Mesh Parameters (Ensure that all trap endpoints have a node)
depth_A  = '${units 0.7 mum}'   # TMAP fit A trap boundary
depth_C  = '${units 1.2 mum}'   # TMAP fit C trap boundary (near-surface region end)
depth_E  = '${units 2.5 mum}'   # TMAP fit E trap boundary (neutron-irradiated)
near_end = '${units 1.0 mum}'   # near-surface / bulk interface
bulk_end = '${units 7.0 mum}'   # bulk / deep-material interface and TMAP fit B trap boundary

# ── Segment widths (derived — do not edit directly) ────────────────────────
# Segment layout:
#   [0,       depth_A ] : near-surface fine        (0.7  mum)
#   [depth_A, near_end] : near-surface remainder   (0.3  mum)
#   [near_end, depth_C] : bulk start               (0.2  mum)
#   [depth_C, depth_E ] : bulk middle              (1.3  mum)
#   [depth_E, bulk_end] : bulk end                 (4.5  mum)
#   [bulk_end, W_thick] : deep material            (193  mum)
  seg1 = '${fparse ${depth_A}}'
  seg2 = '${fparse ${near_end} - ${depth_A}}'
  seg3 = '${fparse ${depth_C}  - ${near_end}}'
  seg4 = '${fparse ${depth_E}  - ${depth_C}}'
  seg5 = '${fparse ${bulk_end} - ${depth_E}}'
  seg6 = '${fparse ${tungsten_thickness} - ${bulk_end}}'

  # ── Element counts ─────────────────────────────────────────────────────────
  # nx_scale uniformly refines all segments. Per-segment multipliers set the
  # relative resolution. Approximate element size at nx_scale = 1 shown below.
  #   seg1: 0.7  mum / (7  * nx_scale) ~ 100  nm/element
  #   seg2: 0.3  mum / (3  * nx_scale) ~ 100  nm/element
  #   seg3: 0.2  mum / (2  * nx_scale) ~ 100  nm/element
  #   seg4: 1.3  mum / (5  * nx_scale) ~ 260  nm/element
  #   seg5: 4.5  mum / (5  * nx_scale) ~ 900  nm/element
  #   seg6: 193  mum / (10 * nx_scale) ~ 19.3 mum/element
  nx_scale = 10

[Mesh]
  [temp_mesh]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${seg1}  ${seg2}  ${seg3}  ${seg4}  ${seg5}  ${seg6}'
    ix = '${fparse 50  * ${nx_scale}}
          ${fparse 3  * ${nx_scale}}
          ${fparse 2  * ${nx_scale}}
          ${fparse 5  * ${nx_scale}}
          ${fparse 5  * ${nx_scale}}
          ${fparse 10 * ${nx_scale}}'
    # subdomain_id = '1  2  2  2  2  2'  # block 1 = trap region, block 2 = bulk

  []
  [tungsten_disc]
    type = RenameBoundaryGenerator
    input = temp_mesh
    old_boundary = 'left right'
    new_boundary = 'upstream downstream'
  []
[]


[Variables]
  [mobile]
  []
  [trapped_1]
  []
[]

[ICs]
  # # Gaussian hill centered on the sample midplane (diagnostic, see header).
  # [mobile_ic]
  #   type = FunctionIC
  #   variable = mobile
  #   function = gaussian_hill_initial_condition
  # []
  [trapped_ic]
    type = FunctionIC
    function = trapped_initial_condition
    variable = trapped_1
  []
[]

# [Problem]
#   # Reference-based convergence: compare each variable's residual to the magnitude of the physical
#   # terms (diffusion + time derivative + source, tagged 'ref') rather than to the initial residual
#   type = ReferenceResidualProblem
#   extra_tag_vectors = 'ref'
#   reference_vector = 'ref'
# []

[Kernels]
  [mobile_time_derivative]
    type = ADTimeDerivative
    variable = mobile
    # extra_vector_tags = 'ref'
  []
  [mobile_diffusion]
    type = ADMatDiffusion
    variable = mobile
    diffusivity = diffusivity_mat
    # extra_vector_tags = 'ref'
  []
  [coupled_time]
    type = ADCoefCoupledTimeDerivative
    variable = mobile
    v = trapped_1
    coef = ${trap_per_free}
    # extra_vector_tags = 'ref'
  []
[]

[NodalKernels]
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    mobile_concentration = mobile
    alpha_t = '${alpha_t_0}'
    trapping_energy = '${trapping_energy}'
    N = '${tungsten_density}'
    Ct0 = 'trap_distribution_function'
    temperature = 'temperature'
    trap_per_free = ${trap_per_free}
    # extra_vector_tags = ref
  []
  [release_1]
    type = ReleasingNodalKernel
    variable = trapped_1
    # alpha_r = '${alpha_r_0}'
    alpha_r = '${alpha_r_0}' # Trapping is restricted to trapped region, so this variable beyond the trapped region will have no deuterium to release.
    detrapping_energy = '${detrapping_energy}'
    temperature = 'temperature'
  []
[]

[AuxVariables]
  [temperature]
    initial_condition = ${temperature_tds_start}
  []
[]

[AuxKernels]
  [temperature_aux]
    type = FunctionAux
    variable = temperature
    function = temperature_function
    execute_on = 'INITIAL LINEAR TIMESTEP_END'
  []
[]


[BCs]
  active = 'left_recombination_flux right_recombination_flux'
  # active = 'left right'

  # Infinite recombination
  [left]
    type = ADDirichletBC
    boundary = upstream
    value = 0
    variable = mobile
  []
  [right]
    type = ADDirichletBC
    boundary = downstream
    value = 0
    variable = mobile
  []

  # Finite recombination
  [left_recombination_flux]
    type = ADMatNeumannBC
    variable = mobile
    boundary = upstream
    value = 1
    boundary_material = flux_recombination_surface
    # extra_vector_tags = 'ref'
  []

   [right_recombination_flux]
    type = ADMatNeumannBC
    variable = mobile
    boundary = downstream
    value = 1
    boundary_material = flux_recombination_surface
    # extra_vector_tags = 'ref'
  []
[]

[Materials]

  # Temperature-dependent deuterium diffusivity in tungsten
  [diffusivity_mat]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_mat'
    functor_names = 'temperature_function'
    functor_symbols = 'temperature'
    expression = '${diffusivity_preexponential_factor} * exp(- ${diffusivity_activation_energy} / ${kb_eV} / temperature)'
    output_properties = 'diffusivity_mat'
    outputs = 'exodus'
  []

  # Temperature-dependent recombination coefficient
  [recombination_rate_surface]
    type = ADDerivativeParsedMaterial
    property_name = 'Kr'
    functor_names = 'temperature_function'
    functor_symbols = 'temperature'
    expression = '${recombination_preexponential_factor} * exp(- ${recombination_energy} / ${kb_eV} / temperature)'
  []

  # Finite recombination Boundary Material
  [flux_recombination_surface]
    type = ADDerivativeParsedMaterial
    coupled_variables = 'mobile'
    property_name = 'flux_recombination_surface'
    material_property_names = 'Kr'
    expression = '- 2 * Kr * mobile ^ 2'
  []
[]

[Functions]
  # Gaussian hill, peak gaussian_amplitude at gaussian_center, standard deviation gaussian_sigma:
  #   c(x) = A * exp(-(x - x0)^2 / (2 sigma^2))
  [gaussian_hill_initial_condition]
    type = ParsedFunction
    expression = '${gaussian_amplitude} * exp(-(x - ${gaussian_center})^2 / (2 * ${gaussian_sigma}^2))'
  []

  # Linear TDS ramp from temperature_tds_start to temperature_tds_end and hold until end of simulation
  [temperature_function]
    type = ParsedFunction
    expression = 'if(t<(${temperature_tds_end} - ${temperature_tds_start}) /
                        ${temperature_rate},  ${temperature_tds_start} + ${temperature_rate} * t,
                                              ${temperature_tds_end})'
  []

  [trapped_initial_condition]
    type = ParsedFunction
    expression = 'if(x < ${trap_depth}, ${trap_site_density} / ${trap_per_free}, 0.0)'
  []

  # Fed to TrappingNodalKernel
  [trap_distribution_function]
    type = ParsedFunction
    expression = 'if(x < ${trap_depth}, ${trap_fraction}, 0.0)'
  []

[]

[Postprocessors]

  [trap_region]
    type = ConstantPostprocessor
    value = ${trap_depth}
    execute_on = 'initial'
    outputs = csv
  []

  ### Temperature ramp and resulting diffusivity (for post-processing/plots) ###

  [temperature] # K
    type = FunctionValuePostprocessor
    function = temperature_function
    outputs = csv
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [diffusivity_pp] # mum^2/s; uniform in space, depends only on temperature
    type = ADElementAverageMaterialProperty
    mat_prop = diffusivity_mat
    outputs = csv
  []

  ### Conservation of Mass (replicates val-2k_base.i: residual computed in MOOSE) ###

  # Total deuterium inventory currently in the sample, M(t) (cf. val-2k deuterium_inventory_in_sample).
  # Runs on INITIAL so its t=0 row is the initial inventory M(0), which the comparison script reads to
  # normalize the residual.

  [total_mobile_retention]
    type = ElementIntegralVariablePostprocessor
    variable = mobile
    execute_on = 'INITIAL TIMESTEP_END'
  []

  [total_trapped_retention]
    type = ElementIntegralVariablePostprocessor
    variable = trapped_1
    # Physical concentration = variable * trap_per_free
    # Handle scaling in post-processing script, or use ParsedPostprocessor to multiply.
    execute_on = 'INITIAL TIMESTEP_END'
  []

  # Replace old total_deuterium_retention:
  [total_deuterium_retention]
    type = ParsedPostprocessor
    expression = 'total_mobile_retention + total_trapped_retention * ${trap_per_free}'
    pp_names = 'total_mobile_retention total_trapped_retention'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = csv
  []

  # Desorption flux through each face (upstream_flux is also used for the experimental desorption
  # comparison). With c = 0 Dirichlet faces and c > 0 inside, -D grad(c).n is positive (outward) on
  # each face, so the two are the per-face desorption rates.
  [upstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'upstream'
    variable = mobile
    diffusivity = diffusivity_mat
    execute_on = 'TIMESTEP_END'
    # outputs = csv
  []

  [downstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'downstream'
    variable = mobile
    diffusivity = diffusivity_mat
    execute_on = 'TIMESTEP_END'
    # outputs = csv
  []

  # Total desorption rate through both faces (cf. val-2k deuterium_release_flux_total).
  [deuterium_release_flux_total] # atoms / mum^2 / s
    type = SumPostprocessor
    values = 'upstream_flux downstream_flux'
    execute_on = 'TIMESTEP_END'
    outputs = csv
  []

  # Cumulative deuterium released through both faces (time-integrated release rate), = M(0) - M(t).
  [deuterium_released_physical] # atoms / mum^2
    type = TimeIntegratedPostprocessor
    value = deuterium_release_flux_total
    time_integration_scheme = IMPLICIT-EULER
    execute_on = 'TIMESTEP_END'
    outputs = csv
  []

  # Change in domain inventory relative to the initial state, M(t) - M(0).
  [deuterium_inventory_change] # atoms / mum^2
    type = ChangeOverTimePostprocessor
    postprocessor = total_deuterium_retention
    change_with_respect_to_initial = true
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []

  # Conservation residual = (M(t) - M(0)) + released; ideally 0 at all times. The comparison script
  # divides this by the initial inventory M(0) to report the relative mass-balance residual (cf.
  # val-2k deuterium_mass_conservation_residual). The decomposition generalizes directly to
  # trapped + mobile once traps land: sum them into total_deuterium_retention.
  [deuterium_mass_conservation_residual] # atoms / mum^2
    type = ParsedPostprocessor
    expression = 'deuterium_inventory_change + deuterium_released_physical'
    pp_names = 'deuterium_inventory_change deuterium_released_physical'
    execute_on = 'TIMESTEP_END'
    outputs = 'csv'
  []
[]

[VectorPostprocessors]
  [mobile_profile]
    type = NodalValueSampler
    variable = mobile
    sort_by = x
    execute_on = 'TIMESTEP_END'
    outputs = profile_csv
  []
  [trapped_1_profile]
    type = NodalValueSampler
    variable = trapped_1
    sort_by = x
    execute_on = 'TIMESTEP_END'
    outputs = trapped_profile_csv
  []
[]

[Outputs]
  file_base = 'val-2l_out'
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
  [profile_csv]
    type = CSV
    file_base = 'deuterium_mobile_concentration_profile/val-2l_out'
  []
  [trapped_profile_csv]
    type = CSV
    file_base = 'deuterium_trapped_concentration_profile/val-2l_out'
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
  line_search = 'none'
  nl_abs_tol = 1e-12
  nl_rel_tol = 1e-6
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = ${simulation_time}
  automatic_scaling = true
  dtmin = ${dt_min}
  dtmax = ${dt_max}
  [TimeStepper]
      type = IterationAdaptiveDT
      dt = ${dt_start}
      optimal_iterations = 5
      growth_factor = 1.1
      cutback_factor_at_failure = 0.9
  []
[]
