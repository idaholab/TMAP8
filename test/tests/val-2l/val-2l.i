# Validation Problem #2l from TMAP4/TMAP7 V&V document

# !include val-2l.params

# General parameters
kB = '${units 1.380649e-23 J/K}' # Boltzmann constant (from PhysicalConstants.h - https://physics.nist.gov/cgi-bin/cuu/Value?r)

# Mesh and solver controls
nx_scale = 5 # mesh refinement multiplier (see [Mesh]); increase for convergence studies
dt_max = '${units 4 s}'
simulation_time = '${units 0.5 h -> s}' # 2 h plasma implantation + temperature ramp

# Geometry
tungsten_thickness = '${units 0.2 mm -> mum}' # Tungsten disc thickness, Shimada et al. 2010 (p. S667, Section 2.1)
# near_surface_length = '${units 1 mum}'
# bulk_material_length = '${units 6 mum}'
# deep_material_length = '${fparse total_length - bulk_material_length - near_surface_length}'

# Diffusion parameters
# Temperature-dependent deuterium diffusivity from Shimada et al. 2010 (p. S668, Section 3): D = 2.9e-7 * exp(-0.39 eV / kB / T) (m^2/s)
diffusivity_coefficient = '${units 2.9e-7 m^2/s -> mum^2/s}' # D0 prefactor, Shimada et al. 2010 (p. S668)
E_D = '${units 0.39 eV -> J}' # Diffusion activation energy, Shimada et al. 2010 (p. S668)

# Recombination parameters
# recombination_parameter = '${units ${fparse 3.2e-15*exp(-1.16)} m^4/at/s -> mum^4/at/s}' # Shimada et al. 2010 (p. S668), for recombination BC option
# recombination_parameter_enclos2 = '${units 2e-31 m^4/at/s -> mum^4/at/s}'
# recombination_coefficient_parameter_enclos1_TMAP4 = '${units 1e-27 m^4/at/s -> mum^4/at/s}'

# Implantation source parameters
# NOTE: the implantation depth and width are NOT reported in Shimada et al. 2010. Pulled from val-2i
width = '${units 3.58e-9 m -> mum}' # implantation profile standard deviation
depth = '${units 2.64e-9 m -> mum}' # implantation mean depth
flux_high = '${units 5e21 at/m^2/s -> at/mum^2/s}' # Incident D ion flux, Shimada et al. 2010 (p. S667, Section 2.3)
TPE_hold_time = '${units 2 h -> s}' # Deuterium plasma implantation for 2 h, Shimada et al. 2010 (p. S667, Section 2.3 & Fig. 1)

# Thermal parameters
# Plasma exposure is held at 473 K; after transfer (Section 2.4) the TDS ramp runs from room
# temperature to 1173 K at 10 K/min, per Shimada et al. 2010 (p. S668, Section 2.3 & Fig. 1)
temperature_implantation = '${units 473 K}' # Plasma exposure temperature, Shimada et al. 2010 (p. S668, Section 2.3 & Fig. 1)
temperature_tds_start = '${units 300 K}' # TDS ramp start (room temperature), Shimada et al. 2010 (p. S668, Figs. 2-4)
temperature_high = '${units 1173 K}' # TDS ramp peak temperature, Shimada et al. 2010 (p. S668, Fig. 1)
temperature_rate = '${units ${fparse 10 / 60} K/s}' # TDS ramp rate of 10 K/min, Shimada et al. 2010 (p. S668, Fig. 1)

[Variables]
  # Concentration of deuterium in tungsten (atoms/mum^3)
  [concentration]
  []
[]

[Mesh]
  # coord_type = 'RZ' # Look into how mesh axis and axis of symmetry being same effects postprocessor calculations
  # rz_coord_axis = X # Specifies x axis is axis of symmetry of y axis is radial direction
  # Graded mesh: sub-nm elements near the upstream surface to resolve the implantation Gaussian
  # (mean 2.64 nm, sigma 3.58 nm), coarsening into the bulk where the concentration is ~ 0.
  # Region lengths (near surface -> bulk): 20 nm, 80 nm, 0.9 um, 9 um, remainder to tungsten_thickness.
  [cartesian]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${units 2e-8 m -> mum}
          ${units 8e-8 m -> mum}
          ${units 9e-7 m -> mum}
          ${units 9e-6 m -> mum}
          ${fparse ${tungsten_thickness} - ${units 1e-5 m -> mum}}'
    ix = '${fparse 8 * nx_scale}
          ${fparse 4 * nx_scale}
          ${fparse 4 * nx_scale}
          ${fparse 4 * nx_scale}
          ${fparse 4 * nx_scale}'
  []
  [tungsten_disc] # Cross section through thickness of disk. Can scale measurements by 9*pi mm for full sample metrics
    type = RenameBoundaryGenerator
    input = cartesian
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
    variable = concentration
    diffusivity = diffusivity_D
    extra_vector_tags = 'ref'
  []
  [time_diffusion]
    type = ADTimeDerivative
    variable = concentration
    extra_vector_tags = 'ref'
  []
  [source]
    type = ADBodyForce
    variable = concentration
    function = concentration_source_norm_func
    extra_vector_tags = 'ref'
  []
[]

[AuxVariables]
  # Source term profile used for postprocessing
  [concentration_source]
  []
  # # Time-dependent recombination coefficient on the upstream side
  # [recombination_TMAP4]
  # []
[]

[AuxKernels]
  [concentration_source_aux]
    type = FunctionAux
    variable = concentration_source
    function = concentration_source_norm_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  # [recombination_aux_TMAP4]
  #   type = FunctionAux
  #   variable = recombination_TMAP4
  #   function = '${recombination_coefficient_parameter_enclos1_TMAP4}'
  #   execute_on = 'INITIAL TIMESTEP_END'
  # []
[]

[BCs]
  # Assume infinite recombination on upstream and downstream surfaces
  [left]
    type = ADDirichletBC
    boundary = upstream
    value = 0
    variable = concentration
  []
  [right]
    type = ADDirichletBC
    boundary = downstream
    value = 0
    variable = concentration
  []

  # Flux balance from recombination on upstream surface (left)
  # [left]
  #   type = ADMatNeumannBC
  #   variable = concentration
  #   boundary = upstream
  #   value = 1
  #   boundary_material = flux_on_upstream
  # []
  # # Flux balance from recombination on downstream surface (right)
  # [right]
  #   type = ADMatNeumannBC
  #   variable = concentration
  #   boundary = downstream
  #   value = 1
  #   boundary_material = flux_on_downstream
  # []
[]

[Materials]
  # Temperature-dependent deuterium diffusivity in tungsten
  [diffusivity_D]
    type = ADDerivativeParsedMaterial
    property_name = 'diffusivity_D'
    functor_names = 'Temperature_function'
    functor_symbols = 'temperature'
    expression = '${diffusivity_coefficient} * exp(- ${E_D} / ${kB} / temperature)'
    output_properties = 'diffusivity_D'
    outputs = 'exodus'
  []
  # # Recombination-driven flux on upstream boundary (left)
  # [flux_on_upstream]
  #   type = ADDerivativeParsedMaterial
  #   coupled_variables = 'concentration'
  #   property_name = 'flux_on_upstream'
  #   functor_names = 'Kr_upstream_func'
  #   functor_symbols = 'Kr_upstream_func'
  #   expression = '- 2 * Kr_upstream_func * concentration ^ 2'
  # []
  # # # Recombination-driven flux on downstream boundary (right)
  # [flux_on_downstream]
  #   type = ADDerivativeParsedMaterial
  #   coupled_variables = 'concentration'
  #   property_name = 'flux_on_downstream'
  #   expression = '- 2 * ${recombination_parameter_enclos2} * concentration ^ 2'
  # []
[]

[Functions]
  # Temperature history (K): hold at the implantation temperature while the beam is on, then an
  # instantaneous cooldown to room temperature at the end of implantation (approximating the air
  # transfer in Section 2.4), followed by a linear TDS ramp to the peak temperature and a hold
  [Temperature_function]
    type = ParsedFunction
    expression = 'if(t<${TPE_hold_time},   ${temperature_implantation},
                  if(t<${TPE_hold_time} + (${temperature_high} - ${temperature_tds_start}) /
                        ${temperature_rate},  ${temperature_tds_start} + ${temperature_rate} * (t - ${TPE_hold_time}),
                                              ${temperature_high}))'
  []
  # Upstream recombination coefficient (time-dependent exponential) in microns^4/at/s
  # [Kr_upstream_func]
  #   type = ParsedFunction
  #   expression = '${recombination_coefficient_parameter_enclos1_TMAP4} * (1 - 0.9999 * exp(-6e-5 * t))'
  # []
  # Beam flux schedule applied to upstream surface (atoms/mum^2/s)
  [surface_flux_func]
    type = ParsedFunction
    expression = 'if(t<${TPE_hold_time}, ${flux_high}, 0)'
  []
  # Normalized implantation distribution across tungsten thickness
  [source_distribution] # (-)
    type = ParsedFunction
    # expression = '1.5 / (${width} * sqrt(2 * pi)) * exp(-0.5 * ((x - ${depth}) / ${width})^2)'
    expression = '1 / ( ${width} * sqrt(2 * pi) ) * exp(-0.5 * ((x - ${depth}) / ${width} ) ^ 2)'
  []
  # Spatial-temporal source term from beam flux and implantation profile (atoms/microns^2/s)
  [concentration_source_norm_func] # atoms/microns^2/s
    type = ParsedFunction
    symbol_names = 'source_distribution surface_flux_func'
    symbol_values = 'source_distribution surface_flux_func'
    expression = 'source_distribution * surface_flux_func'
    # expression = 1e-5
  []

  # Adaptive timestepper ceiling
  [max_dt_size_func] # s
    type = ParsedFunction
    expression = ${dt_max}
  []
[]

[Postprocessors]

  ### Conservation of Mass ###

  [total_deuterium_retention] # atoms / mum^2
    type = ElementIntegralVariablePostprocessor
    variable = concentration
    outputs = csv
  []

  [upstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'upstream'
    variable = concentration
    diffusivity = diffusivity_D
    outputs = csv
  []

  [downstream_flux]
    type = ADSideDiffusiveFluxIntegral
    boundary = 'downstream'
    variable = concentration
    diffusivity = diffusivity_D
    outputs = csv
  []

  [deuterium_source] # Integral of Source function gives atoms/mum^2/s
    type = FunctionElementIntegral
    function = concentration_source_norm_func
    outputs = csv
  []

  # [analytical_total_mass_source]
  #   type = FunctionValuePostprocessor
  #   function = analytical_total_mass_fun
  # []

  [flux_difference_plus_source]
    type = ParsedPostprocessor
    expression = 'deuterium_source - upstream_flux - downstream_flux'
    pp_names = 'deuterium_source upstream_flux downstream_flux'
    outputs = csv
  []

  [time_integrated_desorbed_flux_difference]
    type = TimeIntegratedPostprocessor
    value = flux_difference_plus_source
    time_integration_scheme = trapezoidal-rule
    outputs = csv
  []

  ### Desorbed Flux on Upstream and Downstream Surfaces

  # Average flux on upstream surface (left) from recombination
  # [dcdx_upstream]
  #   type = ADSideAverageMaterialProperty
  #   boundary = upstream
  #   property = flux_on_upstream
  #   outputs = none
  # []
  # Output upstream recombination flux (scaled to atoms/mum^2/s)
  # [scaled_recombination_flux_upstream]
  #   type = ScalePostprocessor
  #   scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
  #   value = dcdx_upstream
  #   execute_on = 'initial nonlinear linear timestep_end'
  #   outputs = 'console csv exodus'
  # []
  # Average flux on downstream surface (right) from recombination
  # [dcdx_downstream]
  #   type = ADSideAverageMaterialProperty
  #   boundary = downstream
  #   property = flux_on_downstream
  #   outputs = none
  # []
  # # Output downstream recombination flux (scaled to atoms/mum^2/s)
  # [scaled_recombination_flux_downstream]
  #   type = ScalePostprocessor
  #   scaling_factor = '${fparse -1 * ${units 1 m^2 -> mum^2}}'
  #   value = dcdx_downstream
  #   execute_on = 'initial nonlinear linear timestep_end'
  #   outputs = 'console csv exodus'
  # []
  # Limit timestep size according to beam on/off schedule
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_func
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
[]

[VectorPostprocessors]
  [concentration_profile]
    type = LineValueSampler
    variable = concentration
    start_point = '0 0 0'
    end_point = '${tungsten_thickness} 0 0'
    num_points = 500
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
    # time_step_interval = 2
  []
  [profile_csv]
    type = CSV
    file_base = 'concentration_profile/val-2l_out'
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
  automatic_scaling = true
  # nl_rel_tol = 5e-7 # Borrowed from Val 2-a
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    optimal_iterations = 6
    growth_factor = 1.1
    cutback_factor_at_failure = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]
