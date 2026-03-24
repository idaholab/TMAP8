# Validation problem to address hydrogen permeation through SRNL 304 stainless steel mini canisters.
# Reports:
# https://inldigitallibrary.inl.gov/sites/sti/sti/Sort_129733.pdf
# https://www.osti.gov/biblio/2477665

# Geometry
inner_radius = '${units 1.415 in -> mm}' # Radius of canister containing gases
steel_thickness = '${units 0.085 in -> mm}' # Thickness of steel enclosure
total_radius = '${units ${fparse inner_radius + steel_thickness} mm}'
height = '${units 7.06 in -> mm}'
# gas_volume_meters = '${units ${fparse pi*inner_radius^2*height} mm^3 -> m^3}' # CAREFUL IF USED ELSEWHERE. SHOULD BE mm^3
# gas_volume = '${units ${fparse pi*inner_radius^2*height} mm^3}'
# Ambient Physical & Chemical Parameters
temperature = '${units 313.15 K}' # mild temp
estimated_pressure_gas = '${units ${fparse 24*0.10} psi -> Pa}' # Anywhere from 1-10% of 24 psi

initial_pressure_air = '${units 0.051 Pa}' # Hydrogen in atmosphere is negligible?
# initial_pressure_air = '${units 0 psi -> Pa}'
ideal_gas_constant = '${units 8.31446261815324 J/K/mol -> J/K/mumol}'

# Initial Concentrations
# initial_concentration_steel = '${units ${fparse initial_pressure_air/(ideal_gas_constant*temperature)} mumol/m^3 -> mumol/mm^3}'
initial_concentration_steel = '${units 0 mumol/mm^3}'

### STEEL-ONLY MODEL MUST ASSUME TOTAL CONCENTRATION IN GAS ###
assumed_gas_total_mass = '${units 1466.5 mumol}' # molecular hydrogen peak from SRNL data
# assumed_gas_total_mass = '${units ${fparse estimated_pressure_gas*gas_volume_meters/(ideal_gas_constant*temperature)} mumol}' # Estimation using ideal gas law

# Hydrogen Diffusivity in Steel
diffusivity_preexponential_factor_in_steel = '${units 0.20e-6 m^2/s -> mm^2/day}'
diffusivity_activation_energy_in_steel = '${units 49.3 kJ/mol -> J/mumol}'
diffusivity_H_in_steel = '${units ${fparse diffusivity_preexponential_factor_in_steel * exp(-diffusivity_activation_energy_in_steel/(ideal_gas_constant*temperature))} mm^2/day}'

# Hydrogen Solubility in Steel
#https://www.sandia.gov/app/uploads/sites/158/2021/12/1500TechRef_ferriticSS.pdf
# solubility_preexponential_factor_in_steel = '${units 266e-3 mol/m^3/Pa -> mumol/mm^3/Pa}' #sqrt Pa used in BC due to sievert's law
solubility_preexponential_factor_in_steel = '${units 266e-6 mumol/mm^3/Pa}' #sqrt Pa used in BC due to sievert's law
solubility_activation_energy_in_steel = '${units 6.86 kJ/mol -> J/mol}' # Leave as mol to cancel out with ideal gas constant

# Mesh
num_intervals_steel = 5000

# Numerics
dt_max = '${units 7 day}'
dt_min = '${units 1 s -> day}'
# endtime = '${units 1 year -> day}'
# endtime = '${units 0.25 year -> day}'
endtime = '${units 10 year -> day}'
dt_start = '${units 300 s -> day}' # 3 hours does not give negative concentration for current input parameters

[Mesh]
  coord_type = 'RZ' # Specify 2D axisymmetric coordinates
  rz_coord_axis = Y # Specifies X is radial direction and Y is axial coordinate
  [steel]
    type = GeneratedMeshGenerator
    dim = 1
    nx = '${num_intervals_steel}'
    xmin = '${inner_radius}'
    xmax = '${total_radius}'
  []
[]

[Variables]
  [H_mobile_steel]
    initial_condition = '${initial_concentration_steel}'
  []
[]

[AuxVariables]
  [H_partial_pressure_gas]
    initial_condition = 0 # Pressured ramped in time or data fit to SRNL data, both of which have starting value of 0
    order = FIRST
    family = LAGRANGE
  []
  [H_partial_pressure_air]
    initial_condition = '${initial_pressure_air}'
    order = FIRST
    family = SCALAR
    outputs = none
  []
  [H_mobile_steel_derivative]
    order = FIRST
    family = MONOMIAL
  []
[]

[AuxKernels]
  [pressure_fit] # Pressure term starts at zero and ramps up over time
    type = FunctionAux
    # function = time_ramp_pressure
    function = SRNL_pressure_data_fun # Corrected or Uncorrected
    variable = H_partial_pressure_gas
  []

  [concentration_gradient_left_boundary] # For Diffusion length calculation
    type = DiffusionFluxAux
    component = x
    diffusion_variable = H_mobile_steel
    diffusivity = negative_unity
    variable = H_mobile_steel_derivative
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

[Materials]
  [unity]
    type = ConstantMaterial
    property_name = negative_unity
    value = -1
    boundary = '0'
  []
[]

[BCs]
  [gas_steel_boundary] # Boundary of gas in canister and steel wall
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}'
    Ko_scaling_factor = 2 # Account for solubility given for molecular hydrogen
    boundary = '0'
    activation_energy = '${solubility_activation_energy_in_steel}' # used since ideal gas constant units cannot be changed
    enclosure_var = H_partial_pressure_gas # Pa = J/m^3
    variable = H_mobile_steel #
    temperature = '${temperature}'
    p = 0.5 # Sievert's Law
  []

  [steel_air_boundary] # Boundary of outside edge of steel and open air
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}'
    Ko_scaling_factor = 2 # Account for solubility given for molecular hydrogen
    boundary = '1'
    activation_energy = '${solubility_activation_energy_in_steel}'
    enclosure_var = H_partial_pressure_air
    variable = H_mobile_steel
    temperature = '${temperature}'
    p = 0.5 # Sievert's Law
  []
[]

[Functions]
  [time_ramp_pressure]
    type = TimeRampFunction
    final_value = '${estimated_pressure_gas}'
    initial_value = 0
    ramp_duration = '${units 3 h -> day}'
    # ramp_duration = '${endtime}'
  []
  [SRNL_pressure_data_fun]
    type = ParsedFunction
    expression = '376.7588*t^0.6177' # Pa
    # expression = '381.1436*t^0.6209' # Pa with average correction
  []
  [diffusion_length_fun]
    type = ParsedFunction
    expression = 'sqrt(pi*${diffusivity_H_in_steel}*t)'
  []
[]

[VectorPostprocessors]
  [solution_profile]
    type = NodalValueSampler
    sort_by = x
    variable = H_mobile_steel
  []
[]

[Postprocessors]

  ## Length of Diffusion Front ##

  [exact_diffusion_length] # Correct only for time independent boundary condition
    type = FunctionValuePostprocessor
    function = diffusion_length_fun
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

  [simulated_diffusion_length]
    type = ParsedPostprocessor
    expression = '-interface_concentration/gradient_left_boundary'
    constant_expressions = ${inner_radius}
    constant_names = interface_location
    pp_names = 'interface_concentration gradient_left_boundary'
    outputs = csv_data
  []

  ### 2D Conservation of Mass ###

  [mass_in_domain] # Axisymmetric: 2D Integral of Annulus Cross section ; Cartesian: 1D Integral of line cross section
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

  [flux_difference] # Ensure that we are accounting for atomic vs molecular hydrogen
    type = ParsedPostprocessor
    expression = 'outflux - influx'
    # expression = '-influx - outflux'
    pp_names = 'influx outflux'
    outputs = csv_data
  []

  [time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = flux_difference
    outputs = csv_data
  []

  ### 3D Conservation of Mass ###

  [3d_mass_in_domain] ## Extruded concentration of annulus
    type = ScalePostprocessor
    value = mass_in_domain
    scaling_factor = '${height}'
    # outputs = csv_data
  []

  [3d_time_integrated_flux]
    type = ScalePostprocessor
    value = time_integrated_flux
    scaling_factor = ${height}
    outputs = csv_data
  []


  ### Miscellaneous ###

  [assumed_gas_total_mass]
    type = ConstantPostprocessor
    value = '${assumed_gas_total_mass}' # Currently mols of H2 molecules
    execute_on = 'Initial'
    # outputs = csv_data
  []

  [min_steel] # Rough Check for Negative Concentrations
  type = ADElementExtremeFunctorValue
  functor = H_mobile_steel
  value_type = min
  # outputs = csv_data
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
  dtmax = '${dt_max}'
  dtmin = '${dt_min}'
  dt = '${dt_start}'
  solve_type = Newton
  automatic_scaling = true
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_type'
  # petsc_options_value = 'hypre boomeramg cg'
  # petsc_options = '-pc_svd_monitor -snes_test_jacobian '
  # petsc_options_iname = '-snes_linesearch_damping' # add -snes_type if bounds system active
  # petsc_options_value = '0.5' # add  vinewtonrsls if bounds system active
  line_search = NONE
  nl_max_its = 50
  # nl_abs_tol = 1e-50
  # nl_rel_tol = 1e-06
  end_time = ${endtime}
  # steady_state_detection = true
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${dt_start}
    optimal_iterations = 5
    growth_factor = 1.1
    cutback_factor_at_failure = .9
  []
[]

[Outputs]
  # print_linear_residuals = true
  exodus = true
  [csv_data]
    type = CSV
    file_base = 'csv_data_steel_only/verification_RZ'
    # file_base = 'csv_data_steel_only/verification'
    execute_on = 'TIMESTEP_END'
  []
[]
