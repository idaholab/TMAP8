# This input is used to test the error messages of the Enclosure0D
R = '${units 8.31446261815324 J/mol/K}' # Gas constant

# Data used in TMAP4/TMAP7 case
temperature = '${units 2373 K}'
initial_pressure = '${units 1e6 Pa}'
volume_enclosure = '${units 5.20e-11 m^3 -> mum^3}'
surface_area = '${units 2.16e-6 m^2 -> mum^2}'
diffusivity_SiC = '${units ${fparse 1.58e-4*exp(-308000.0/(R*temperature))} m^2/s -> mum^2/s}'
solubility_constant = '${units ${fparse 7.244e22 / temperature} at/m^3/Pa -> at/mum^3/Pa}'
slab_thickness = '${units 3.30e-5 m -> mum}'

[Physics]
  [SorptionExchange]
    [0d_solub]
      species = 'v'
      verbose = true
    []
  []
  [Diffusion]
    [multi-D]
      variable_name = 'u'
      diffusivity_matprop = 'diff'

      # Dont add the default preconditioning
      preconditioning = 'none'

      # To help coupling to trapping
      compute_diffusive_fluxes_on = 'structure_left structure_right'
    []
  []
[]

[ActionComponents]
  [structure]
    type = Structure1D
    species = 'u extra'
    physics = 'multi-D'

    # Material properties
    property_names = 'diff'
    property_values = '${diffusivity_SiC}'

    # Boundary conditions
    fixed_value_bc_variables = 'u'
    fixed_value_bc_boundaries = 'structure_right'
    fixed_value_bc_values = '0'

    # Geometry
    nx = 150
    xmax = ${slab_thickness}
    length_unit_scaling = 1
  []

  [enc]
    type = Enclosure0D
    species = 'v'
    physics = '0d_solub'
    verbose = true

    # Conditions
    temperature = '${temperature}'
    species_initial_pressures = '${initial_pressure}'

    # Material properties
    property_names = 'K_sol'
    property_values = '${solubility_constant}'
    equilibrium_constants = '2'

    # Geometry
    volume = '${volume_enclosure}'

    # Connection to structures
    connected_structures = 'structure'
    connection_boundaries = 'structure_left'
    connection_boundaries_area = '${fparse surface_area}'
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
  end_time = 20
  dtmin = .1
  scheme = 'bdf2'
  timestep_tolerance = 1e-8

  # Nonlinear solver
  solve_type = PJFNK
  automatic_scaling = true
  l_max_its = 30
  nl_max_its = 5
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
[]

[Outputs]
  csv = true
  execute_on = 'TIMESTEP_END'
[]
