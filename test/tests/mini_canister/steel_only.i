# Author: Evan Butterworth
# Contact: Evan.Butterworth@inl.gov

### Input parameters ###

# Geometry
inner_radius = '${units 1.415 in -> mm}' # Radius of canister containing gases
steel_thickness = '${units 0.085 in -> mm}' # Thickness of steel enclosure
total_radius = '${units ${fparse inner_radius + steel_thickness} mm}'
height = '${units 7.06 in -> mm}' # Height of canister

# Misc
temperature = '${units 313.15 K}' # INL Report: Section 2.3
estimated_pressure_gas = '${units ${fparse 24*0.10} psi -> Pa}' # SRNL Report: Estimation of Partial Pressure of H_2 with HE backfill to 24 psi
ideal_gas_constant = '${units 8.31446261815324 J/K/mol -> J/K/mumol}' # Needed for concentration units in mumol/mm^3

# Sandia Technical Reference: Hydrogen Diffusivity & Solubility in 304 Stainless Steel
diffusivity_preexponential_factor_in_steel = '${units 0.20e-6 m^2/s -> mm^2/day}'
diffusivity_activation_energy_in_steel = '${units 49.3 kJ/mol -> J/mumol}'
diffusivity_H_in_steel = '${units ${fparse diffusivity_preexponential_factor_in_steel * exp(-diffusivity_activation_energy_in_steel/(ideal_gas_constant*temperature))} mm^2/day}'
solubility_preexponential_factor_in_steel = '${units 266e-6 mumol/mm^3/Pa}' # Actual units are mumol/mm^3/sqrt(Pa) due to Sievert's law in EquilibriumBC
solubility_activation_energy_in_steel = '${units 6.86 kJ/mol -> J/mol}' # J/mol needed since EquilibriumBC uses ideal gas constant in SI units from PhysicalConstants namespace

# Numerics
num_elements_steel = 2000
endtime = '${units 0.25 year -> day}'
dt_start = '${units 300 s -> day}'
dt_max = '${units 7 day}'
dt_min = '${units 1 s -> day}'

[Mesh]
  coord_type = 'RZ' # Axisymmetric coordinates
  rz_coord_axis = Y # Specifies X axis is radial direction and Y axis is axis of symmetry
  [steel]
    type = GeneratedMeshGenerator
    dim = 1
    nx = '${num_elements_steel}'
    xmin = '${inner_radius}'
    xmax = '${total_radius}'
  []
[]

[Variables]
  [H_mobile_steel]
  []
[]

[AuxVariables]
  [H_partial_pressure_gas] # Partial pressure of H_2 in internal gas chamber in Pa
  []
  [H_mobile_steel_derivative] # dC_s/dx
    family = MONOMIAL # Need element rather than nodal family to define gradient at a node
  []
  [T] # Temperature
  []
[]

[Materials]
  [unity]
    type = ConstantMaterial
    property_name = negative_unity
    value = -1
    boundary = '0'
  []
[]

[Kernels]
  [steel_mobile_time]
    type = ADTimeDerivative
    variable = H_mobile_steel
  []
  [steel_mobile_diff]
    type = ADMatDiffusion
    variable = H_mobile_steel
    diffusivity = '${diffusivity_H_in_steel}'
  []
[]

[BCs]
  [gas_steel_boundary] # Species equilibrium condition between internal gas and steel wall
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}'
    Ko_scaling_factor = 2 # Convert from molecular to atomic solubility
    boundary = '0'
    activation_energy = '${solubility_activation_energy_in_steel}'
    enclosure_var = H_partial_pressure_gas
    variable = H_mobile_steel
    temperature = T
    p = 0.5 # Sieverts' Law
  []

  [steel_air_boundary] # Boundary of steel and outside environment
    type = DirichletBC
    boundary = '1'
    value = 0
    variable = H_mobile_steel
  []
[]

[Functions]
  [constant_pressure]
    type = ConstantFunction
    value = '${estimated_pressure_gas}'
  []
  [time_ramp_pressure]
    type = TimeRampFunction
    final_value = '${estimated_pressure_gas}'
    initial_value = 0
    ramp_duration = '${units 3 h -> day}'
  []
  [SRNL_pressure_data_fun]
    type = ParsedFunction
    expression = '376.7588*t^0.6177'
  []
[]

[AuxKernels]

  # List preferred pressure implementation here
  active = 'constant_pressure_fit
  constant_temperature concentration_gradient_left_boundary'

  [constant_pressure_fit]
    type = FunctionAux
    function = constant_pressure
    variable = H_partial_pressure_gas
  []

  [time_ramp_pressure_fit]
    type = FunctionAux
    function = time_ramp_pressure
    variable = H_partial_pressure_gas
  []

  [SRNL_pressure_fit]
    type = FunctionAux
    function = SRNL_pressure_data_fun
    variable = H_partial_pressure_gas
  []

  [concentration_gradient_left_boundary] # dC_s/dx @ x = inner_radius
    type = DiffusionFluxAux
    component = x
    diffusion_variable = H_mobile_steel
    diffusivity = negative_unity
    variable = H_mobile_steel_derivative
    boundary = '0'
  []

  [constant_temperature]
    type = ConstantAux
    variable = T
    value = '${temperature}'
  []
[]

[Postprocessors]

  ### DIFFUSION FRONT VERIFICATION ###

  [exact_diffusion_length]   # Analytical Diffusion length (time-independent BC required for this to be correct)
    type = ParsedPostprocessor
    expression = 'sqrt(pi*D*t)'
    constant_names = 'D pi'
    constant_expressions = '${diffusivity_H_in_steel} 3.1415926535897932'
    use_t = true
    outputs = csv_data
  []

  [gradient_left_boundary]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_steel_derivative
    outputs = csv_data
  []

  [interface_concentration]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_steel
    outputs = csv_data
  []

  [simulated_diffusion_length] # x-intercept of tangent line at interface
    type = ParsedPostprocessor
    expression = '-interface_concentration/gradient_left_boundary'
    constant_expressions = ${inner_radius}
    constant_names = interface_location
    pp_names = 'interface_concentration gradient_left_boundary'
    outputs = csv_data
  []

  ### 2D CONSERVATION OF MASS ###

  [mass_in_domain] # Axisymmetric: 2D integral of annulus
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_steel
    outputs = csv_data
  []

  [influx]
    type = ADSideDiffusiveFluxIntegral
    boundary = '0'
    variable = H_mobile_steel
    diffusivity = ${diffusivity_H_in_steel}
    outputs = csv_data
  []

  [outflux]
    type = ADSideDiffusiveFluxIntegral
    boundary = '1'
    variable = H_mobile_steel
    diffusivity = ${diffusivity_H_in_steel}
    outputs = csv_data
  []

  [flux_difference]
    type = ParsedPostprocessor
    expression = '-influx - outflux' # negative sign on influx to account for outward normal vector direction
    pp_names = 'influx outflux'
    outputs = csv_data
  []

  [time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = flux_difference
    time_integration_scheme = trapezoidal-rule
    outputs = csv_data
  []

  ### 3D CONSERVATION OF MASS ###

  [3d_mass_in_domain] # total mass in annulur cylinder
    type = ScalePostprocessor
    value = mass_in_domain
    scaling_factor = '${height}'
    outputs = csv_data
  []

  [3d_time_integrated_flux]
    type = ScalePostprocessor
    value = time_integrated_flux
    scaling_factor = ${height}
    outputs = csv_data
  []

  ### MISCELLANEOUS ###

  [assumed_gas_total_mass]
    type = ParsedPostprocessor
    expression = '69.7055*t^0.6808' # Power model linear least squares fit of SRNL data
    use_t = True
    outputs = csv_data
  []

  [min_concentration] # Check for negative concentrations
    type = ElementExtremeValue
    variable = H_mobile_steel
    value_type = min
    outputs = csv_data
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  dtmax = '${dt_max}'
  dtmin = '${dt_min}'
  dt = '${dt_start}'
  solve_type = LINEAR # Direct solve of linear system by LU factorization
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  end_time = ${endtime}
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start}
    optimal_iterations = 5
    growth_factor = 1.1
    cutback_factor_at_failure = .9
  []
[]

[Outputs]
  perf_graph = true
  exodus = true
  [csv_data]
    type = CSV
    file_base = 'steel_only_out'
    execute_on = 'TIMESTEP_END'
  []
[]
