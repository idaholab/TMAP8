# Verification Problem #1a from TMAP4/TMAP7 V&V document
# Tritium diffusion through SiC layer with depleting source at 2100 C.
# No Soret effect, solubility, or trapping included.

# Physical Constants
# Note that we do NOT use the same number of digits as in TMAP4/TMAP7.
# This is to be consistent with PhysicalConstant.h
kb = 1.380649e-23 # Boltzmann constant J/K
R = 8.31446261815324 # Gas constant J/mol/K

# Data used in TMAP4/TMAP7 case
length_unit = 1e6 # conversion from meters to microns
temperature = 2373 # K
initial_pressure = 1e6 # Pa
volume_enclosure = '${fparse 5.20e-11*length_unit^3}' # microns^3
surface_area = '${fparse 2.16e-6*length_unit^2}' # microns^2
diffusivity_SiC = '${fparse 1.58e-4 * exp(-308000.0 / (R * temperature)) * length_unit^2}' # microns^2/s
solubility_constant = '${fparse 7.244e22 / (temperature)}' # atoms/microns^3/Pa
slab_thickness = '${fparse  3.30e-5 * length_unit}' # microns

# Useful equations/conversions
concentration_to_pressure_conversion_factor = '${fparse kb*temperature*length_unit^3}' # J = Pa*microns^3
pressure_unit = 1 # number of pressure units in a Pascal

[Physics]
  [SpeciesTrapping]
    [ODE]
      [0d_trapping]
        species = 'v'
        # should not be scaled
        equilibrium_constants = ${solubility_constant}

        # These parameters can be passed for each component here in lieu of fetching them from the components
        # initial_values = '${initial_pressure}'
        # temperatures = ${temperature}

        verbose = true

        # If the initial pressure had not been scaled (=1 right now)
        pressure_unit_scaling = ${pressure_unit}
        # Volume and area of the enclosure have not been pre-scaled
        length_unit_scaling = ${length_unit}
      []
    []
  []
  [Diffusion]
    [ContinuousGalerkin]
      [multi-D]
        variable_name = 'u'
        diffusivity_matprop = ${diffusivity_SiC}

        # To help coupling to trapping
        compute_diffusive_fluxes_on = 'structure_left'

        dirichlet_boundaries = 'structure_right'
        boundary_values = '0'
      []
    []
  []
[]

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'u'
    physics = 'multi-D'

    # Geometry
    nx = 150
    xmax = ${slab_thickness}
    length_unit_scaling = 1
  []

  [enc]
    type = Enclosure0D
    species = 'v'
    physics = '0d_trapping'

    # Conditions
    temperature = ${temperature}
    species_initial_pressures = '${initial_pressure}'

    # Geometry
    surface_area = 2.16e-6
    volume = 5.2e-11

    # Connection to structures
    connected_structure = 'structure'
    boundary = 'structure_left'
  []
[]

[Postprocessors]
  # flux of tritium through the outer SiC surface - compare to TMAP7
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = u
    diffusivity = '${diffusivity_SiC}'
    boundary = 'structure_right'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  # flux of tritium through the surface of SiC layer in contact with enclosure
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = u
    diffusivity = '${diffusivity_SiC}'
    boundary = 'structure_left'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = ''
  []
  # scale the flux to get inward direction
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = -1
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  # integral of the tritium flux through outer surface of SiC layer
  [integral_release_flux_right]
    type = PressureReleaseFluxIntegral
    variable = u
    boundary = 'structure_right'
    diffusivity = '${diffusivity_SiC}'
    surface_area = '${surface_area}'
    volume = '${volume_enclosure}'
    concentration_to_pressure_conversion_factor = '${concentration_to_pressure_conversion_factor}'
    outputs = 'console'
  []
  # cumulative sum of integral_release_flux_right over time (i.e. cumulative amount released)
  [cumulative_release_right]
    type = CumulativeValuePostprocessor
    postprocessor = 'integral_release_flux_right'
    outputs = 'console'
  []
  # released fraction based on outer layer flux - compare to TMAP4
  [released_fraction_right]
    type = ScalePostprocessor
    value = 'cumulative_release_right'
    scaling_factor = '${fparse 1./(initial_pressure)}'
    outputs = 'console csv exodus'
  []
  # Make a postprocessor take the value of the scalar value v
  [v_value]
    type = ScalarVariable
    variable = v_enc
  []
  # released fraction based on inner layer flux on v - compare to TMAP7
  [released_fraction_left]
    type = LinearCombinationPostprocessor
    pp_names = 'v_value'
    pp_coefs = '${fparse -1./(initial_pressure)}'
    b = 1
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

  # Time stepping and integration
  dt = .1
  end_time = 140
  dtmin = .1
  scheme = 'bdf2'
  timestep_tolerance = 1e-8

  # Nonlinear solver
  solve_type = PJFNK
  automatic_scaling = true
  l_max_its = 30
  nl_max_its = 5
  # petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  [csv]
    type = CSV
    execute_on = 'initial timestep_end'
  []
  [console]
    type = Console
    time_step_interval = 10
  []
[]
