# Validation Problem #2l from TMAP4/TMAP7 V&V document

# !include val-2l.params

# General parameters
kB = '${units 1.380649e-23 J/K}' # Boltzmann constant

# Mesh and solver controls
simulation_time = '${units 2 h -> s}' # 2 h TDS with temperature ramp
nx_scale = 5
dt_start = '${units 1 s}'
dt_max = '${units 4 s}'
dt_min = '${units 1e-6 s}'

# Geometry
tungsten_thickness = '${units 0.2 mm -> mum}' # Tungsten disc thickness, Shimada et al. 2010 (p. S667, Section 2.1)

# Gaussian-hill initial condition (diagnostic profile; not from Shimada et al. 2010).
gaussian_amplitude = '${units 1e26 at/m^3 -> at/mum^3}' # Peak concentration at the center (= 1 at/mum^3)
gaussian_center = '${fparse ${tungsten_thickness} / 5}' # Hill center (20 mum)
gaussian_sigma = '${fparse ${tungsten_thickness} / 20}' # Hill standard deviation (10 mum)

# Temperature-dependent deuterium diffusivity used by Shimada et al. 2010 (p. S668, Section 3)
diffusivity_coefficient = '${units 2.9e-7 m^2/s -> mum^2/s}' # D0 prefactor, Shimada et al. 2010 (p. S668)
E_D = '${units 0.39 eV -> J}' # Diffusion activation energy, Shimada et al. 2010 (p. S668)

# Recombination parameters: Shimada et al. 2010 (p. S668)
# recombination_parameter = '${units ${fparse 3.2e-15*exp(-1.16)} m^4/at/s -> mum^4/at/s}'
# recombination_parameter_enclos2 = '${units 2e-31 m^4/at/s -> mum^4/at/s}'
# recombination_coefficient_parameter_enclos1_TMAP4 = '${units 1e-27 m^4/at/s -> mum^4/at/s}'

# Thermal parameters
temperature_tds_start = '${units 300 K}' # TDS ramp start (room temperature), Shimada et al. 2010 (p. S668, Figs. 2-4)
temperature_tds_end = '${units 1173 K}' # TDS ramp peak temperature, Shimada et al. 2010 (p. S668, Fig. 1)
temperature_rate = '${units ${fparse 10 / 60} K/s}' # TDS ramp rate of 10 K/min, Shimada et al. 2010 (p. S668, Fig. 1)

[Variables]
  [deuterium_mobile_concentration]
  []
[]

[ICs]
  # Gaussian hill centered on the sample midplane (diagnostic, see header).
  [deuterium_mobile_concentration_ic]
    type = FunctionIC
    variable = deuterium_mobile_concentration
    function = gaussian_hill_initial_condition
  []
[]

[Mesh]

  [temp_mesh]
    type = CartesianMeshGenerator
    dim = 1
    # Graded mesh: fine at the upstream surface, coarse in the bulk. The last block fills the
    # remainder of the disc so the total thickness equals tungsten_thickness (0.2 mm).
    dx = '${fparse 5 * ${units 4e-9 m -> mum}}  ${units 1e-8 m -> mum}  ${units 1e-7 m -> mum}
          ${units 1e-6 m -> mum}                ${units 1e-5 m -> mum}
          ${fparse ${tungsten_thickness} - 5 * ${units 4e-9 m -> mum} - ${units 1e-8 m -> mum}
                   - ${units 1e-7 m -> mum} - ${units 1e-6 m -> mum} - ${units 1e-5 m -> mum}}'
    ix = '${fparse 5 * ${nx_scale}}             ${nx_scale}             ${nx_scale}
          ${nx_scale}                           ${nx_scale}             ${fparse 10 * ${nx_scale}}'
  []

  [tungsten_disc]
    type = RenameBoundaryGenerator
    input = temp_mesh
    old_boundary = 'left right'
    new_boundary = 'upstream downstream'
  []
[]

[Problem]
  # Reference-based convergence: compare each variable's residual to the magnitude of the physical
  # terms (diffusion + time derivative + source, tagged 'ref') rather than to the initial residual
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Kernels]
  [diffusion]
    type = ADMatDiffusion
    variable = deuterium_mobile_concentration
    diffusivity = diffusivity_mat
    extra_vector_tags = 'ref'
  []
  [time_diffusion]
    type = ADTimeDerivative
    variable = deuterium_mobile_concentration
    extra_vector_tags = 'ref'
  []
[]

[BCs]
  # Assume infinite recombination on upstream and downstream surfaces
  [left]
    type = ADDirichletBC
    boundary = upstream
    value = 0
    variable = deuterium_mobile_concentration
  []
  [right]
    type = ADDirichletBC
    boundary = downstream
    value = 0
    variable = deuterium_mobile_concentration
  []
[]

[Materials]
  # Temperature-dependent deuterium diffusivity in tungsten
  [diffusivity_mat]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_mat'
    functor_names = 'Temperature_function'
    functor_symbols = 'temperature'
    expression = '${diffusivity_coefficient} * exp(- ${E_D} / ${kB} / temperature)'
    output_properties = 'diffusivity_mat'
    outputs = 'exodus'
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
  [Temperature_function]
    type = ParsedFunction
    expression = 'if(t<(${temperature_tds_end} - ${temperature_tds_start}) /
                        ${temperature_rate},  ${temperature_tds_start} + ${temperature_rate} * t,
                                              ${temperature_tds_end})'
  []
[]

[Postprocessors]

  ### Temperature ramp and resulting diffusivity (for post-processing/plots) ###

  [temperature] # K
    type = FunctionValuePostprocessor
    function = Temperature_function
    outputs = csv
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
  [total_deuterium_retention] # atoms / mum^2
    type = ElementIntegralVariablePostprocessor
    variable = deuterium_mobile_concentration
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = csv
  []

  # Desorption flux through each face (upstream_flux is also used for the experimental desorption
  # comparison). With c = 0 Dirichlet faces and c > 0 inside, -D grad(c).n is positive (outward) on
  # each face, so the two are the per-face desorption rates.
  [upstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'upstream'
    variable = deuterium_mobile_concentration
    diffusivity = diffusivity_mat
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = csv
  []

  [downstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'downstream'
    variable = deuterium_mobile_concentration
    diffusivity = diffusivity_mat
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = csv
  []

  # Total desorption rate through both faces (cf. val-2k deuterium_release_flux_total).
  [deuterium_release_flux_total] # atoms / mum^2 / s
    type = SumPostprocessor
    values = 'upstream_flux downstream_flux'
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
  []

  # Cumulative deuterium released through both faces (time-integrated release rate), = M(0) - M(t).
  [deuterium_released_physical] # atoms / mum^2
    type = TimeIntegratedPostprocessor
    value = deuterium_release_flux_total
    time_integration_scheme = trapezoidal-rule
    execute_on = 'INITIAL TIMESTEP_END'
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
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = 'csv'
  []
[]

[VectorPostprocessors]
  [deuterium_mobile_concentration_profile]
    type = NodalValueSampler
    variable = deuterium_mobile_concentration
    sort_by = x
    execute_on = 'TIMESTEP_END'
    outputs = profile_csv
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
  nl_abs_tol = 1e-10
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = ${simulation_time}
  automatic_scaling = true
  dtmin = ${dt_min}
  dtmax = ${dt_max}
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start}              # initial step only
    optimal_iterations = 5
    growth_factor = 1.1
    cutback_factor_at_failure = 0.9
  []
[]
