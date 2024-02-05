# Verification Problem #1a from TMAP4/TMAP7 V&V document
# Tritium diffusion through SiC layer with depleting source at 2100 C.
# No Sorret effect, solubility, or trapping included.

# Physical Constants note that we do NOT use the same number of digits as in TMAP4/TMAP7.
# This is to be consistent with PhysicalConstant.h
kb = 1.380649e-23 # Boltzmann constant J/K
R = 8.31446261815324 # Gas constant J/mol/K

# Data used in TMAP4/TMAP7 case
length_unit = 1e6 # conversion from meters to microns
temperature = 2373 # K
initial_pressure = 1e6 # Pa
volume_enclosure = '${fparse 5.20e-11*length_unit^3}' # microns^3
surface_area = '${fparse 2.16e-6*length_unit^2}' # microns^2
diffusivity_SiC = '${fparse 1.58e-4*exp(-308000.0/(R*temperature))*length_unit^2}' # microns^2/s
solubility_constant = '${fparse  7.244e22/(temperature * length_unit^3)}' # atoms/microns^3*Pa = atoms*s^2/m^2/kg
slab_thickness = '${fparse  3.30e-5*length_unit}' # microns

# Useful equations/conversions
concentration_to_pressure_conversion_factor = '${fparse kb*temperature*length_unit^3}' # J = Pa*microns^3

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 10
  xmax = '${slab_thickness}'
[]

[Variables]
  # concentration in the SiC layer in atoms/microns^3
  [u]
  []
  # pressure of the enclosure in Pa
  [v]
    family = SCALAR
    order = FIRST
    initial_condition = '${fparse initial_pressure}'
  []
[]

[Kernels]
  [diff]
    type = MatDiffusion
    variable = u
    diffusivity = '${diffusivity_SiC}'
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]

[ScalarKernels]
  [time]
    type = ODETimeDerivative
    variable = v
  []
  [flux_sink]
    type = EnclosureSinkScalarKernel
    variable = v
    flux = scaled_flux_enclorure_surface
    surface_area = '${surface_area}'
    volume = '${volume_enclosure}'
    concentration_to_pressure_conversion_factor = '${concentration_to_pressure_conversion_factor}'
  []
[]

[BCs]
  # The concentration on the outer boundary of the SiC layer is kept at 0
  [right]
    type = DirichletBC
    value = 0
    variable = u
    boundary = 'right'
  []
  # The surface of the slab in contact with the source is assumed to be in equilibrium with the source enclosure
  [left]
    type = EquilibriumBC
    variable = u
    enclosure_scalar_var = v
    boundary = 'left'
    Ko = '${solubility_constant}'
    temp = ${temperature}
  []
[]

[Postprocessors]
  # flux of tritium through the surface of SiC layer in contact with enclosure
  [flux_enclorure_surface]
    type = SideDiffusiveFluxIntegral
    variable = u
    diffusivity = '${diffusivity_SiC}'
    boundary = 'left'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = ''
  []
  # scale the flux to get inward direction
  [scaled_flux_enclorure_surface]
    type = ScalePostprocessor
    scaling_factor = -1
    value = flux_enclorure_surface
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  # integral of the tritium flux through outer surface of SiC layer
  [integral_release_flux]
    type = PressureReleaseFluxIntegral
    variable = u
    boundary = 'right'
    diffusivity = '${diffusivity_SiC}'
    surface_area = '${surface_area}'
    volume = '${volume_enclosure}'
    concentration_to_pressure_conversion_factor = '${concentration_to_pressure_conversion_factor}'
    outputs = 'console'
  []
  # commulative sum of rhs_timestep over time (i.e. cummulative amount released)
  [commulative_release]
    type = CumulativeValuePostprocessor
    postprocessor = 'integral_release_flux'
    outputs = 'console'
  []
  # released fraction
  [released_fraction]
    type = ScalePostprocessor
    value = 'commulative_release'
    scaling_factor = '${fparse 1./(initial_pressure)}'
    outputs = 'console csv exodus'
  []
[]

[Executioner]
  type = Transient
  dt = .1
  end_time = 140
  solve_type = PJFNK
  automatic_scaling = true
  dtmin = .1
  l_max_its = 30
  nl_max_its = 5
  petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  petsc_options_iname = '-pc_type -mat_mffd_err'
  petsc_options_value = 'lu       1e-5'
  line_search = 'bt'
  scheme = 'bdf2'
  timestep_tolerance = 1e-8
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  perf_graph = true
  [dof]
    type = DOFMap
    execute_on = 'initial'
  []
  [csv]
    type = CSV
    execute_on = 'initial timestep_end'
  []
[]
