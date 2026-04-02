# Author: Evan Butterworth
# Contact: Evan.Butterworth@inl.gov

# This input file simulates the hydrogen permeation through only the steel wall
# within aluminum-clad used nuclear fuel (AUNF) mini-canister storage device at Savannah River National Laboratory (SRNL).

# Sources:
# INL Report: https://inldigitallibrary.inl.gov/sites/sti/sti/Sort_129733.pdf
# SRNL Report: https://www.osti.gov/biblio/2477665
# Ronnebro association/disassociation paper: https://pubmed.ncbi.nlm.nih.gov/36235066/​​
# Sandia Reports:
# https://www.sandia.gov/app/uploads/sites/158/2021/12/1500TechRef_ferriticSS.pdf​
# https://www.sandia.gov/app/uploads/sites/158/2021/12/2101TechRef_304SS.pdf​

### GEOMETRY ###
inner_radius = '${units 1.415 in -> mm}' # Radius of canister containing gases
steel_thickness = '${units 0.085 in -> mm}' # Thickness of steel enclosure
total_radius = '${units ${fparse inner_radius + steel_thickness} mm}'
height = '${units 7.06 in -> mm}' # Height/length of canister

### INPUT PARAMETERS ###

temperature = '${units 313.15 K}' # INL Report: Section 2.3
estimated_pressure_gas = '${units ${fparse 24*0.10} psi -> Pa}' # SRNL Report: Estimation of Partial Pressure of H_2 with HE backfill to 24 psi
ideal_gas_constant = '${units 8.31446261815324 J/K/mol -> J/K/mumol}' # Needed for concentration units in mumol/mm^3
initial_concentration_steel = '${units 0 mumol/mm^3}' # Initial Concentration of mobile hydrogen in steel C_s

# Sandia Report: Hydrogen Diffusivity & Solubility in 304 Stainless Steel
diffusivity_preexponential_factor_in_steel = '${units 0.20e-6 m^2/s -> mm^2/day}'
diffusivity_activation_energy_in_steel = '${units 49.3 kJ/mol -> J/mumol}'
diffusivity_H_in_steel = '${units ${fparse diffusivity_preexponential_factor_in_steel * exp(-diffusivity_activation_energy_in_steel/(ideal_gas_constant*temperature))} mm^2/day}'
solubility_preexponential_factor_in_steel = '${units 266e-6 mumol/mm^3/Pa}' # Actual units are mumol/mm^3/sqrt(Pa) due to Sievert's law in EquilibriumBC
solubility_activation_energy_in_steel = '${units 6.86 kJ/mol -> J/mol}' # J/mol needed since EquilibriumBC uses ideal gas constant in SI units from PhysicalConstants namespace

# Numerical discretization parameters
num_elements_steel = 5000
endtime = '${units 0.25 year -> day}'
dt_start = '${units 300 s -> day}'
dt_max = '${units 7 day}'
dt_min = '${units 1 s -> day}'

[Mesh]
  coord_type = 'RZ' # Specify 2D axisymmetric coordinates
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
  [H_mobile_steel] # Mobile H_2 concentration in steel
    initial_condition = '${initial_concentration_steel}'
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxVariables]
  [H_partial_pressure_gas] # Partial pressure of H_2 in internal gas chamber
    order = FIRST
    family = LAGRANGE
  []
  [H_mobile_steel_derivative] # dC_s/dx
    order = FIRST
    family = MONOMIAL
  []
  [T] # Temperature
  []
[]

[AuxKernels]
  [pressure_fit] # Comment out undesired pressure function type
    type = FunctionAux
    # function = time_ramp_pressure # Estimated pressure with time ramping over first few timesteps to avoid negative concentrations
    function = SRNL_pressure_data_fun # Data fit of SRNL reported pressure over time for As-Corroded No-Vaccum surrogate assembly in Table 7-5
    variable = H_partial_pressure_gas
  []

  [concentration_gradient_left_boundary] # dC_s/dx @ x = inner_radius
    type = DiffusionFluxAux
    component = x
    diffusion_variable = H_mobile_steel
    diffusivity = negative_unity # Gives gradient
    variable = H_mobile_steel_derivative
    boundary = '0'
  []

  [constant_temperature] # EquilibriumBC expects a variable for temperature
    type = ConstantAux
    variable = T
    value = '${temperature}'
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
  [gas_steel_boundary] # Species equilibrium condition between internal gas chamber and steel
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}'
    Ko_scaling_factor = 2 # Convert solubility to represent atomic H
    boundary = '0'
    activation_energy = '${solubility_activation_energy_in_steel}'
    enclosure_var = H_partial_pressure_gas
    variable = H_mobile_steel
    temperature = T
    p = 0.5 # Sievert's Law
  []

  [steel_air_boundary] # Boundary of outside edge of steel and open air
    type = DirichletBC
    boundary = '1'
    value = 0
    variable = H_mobile_steel
  []
[]

[Functions]
  # Pressure implementations
  [time_ramp_pressure]
    type = TimeRampFunction
    final_value = '${estimated_pressure_gas}'
    initial_value = 0
    ramp_duration = '${units 3 h -> day}'
  []
  [SRNL_pressure_data_fun]
    type = ParsedFunction
    expression = '376.7588*t^0.6177' # Pa
  []
[]

[VectorPostprocessors]
  [solution_profile]  # Generate Solution Profile
    type = NodalValueSampler
    sort_by = x
    variable = H_mobile_steel
  []
[]

[Postprocessors]

  ## Length of Diffusion Front ##

  [exact_diffusion_length]   # Analytical Diffusion length (non-temporal BC technically required for this to be accurate)
    type = ParsedPostprocessor
    expression = 'sqrt(pi*D*t)'
    constant_names = 'D pi'
    constant_expressions = '${diffusivity_H_in_steel} 3.1415926535897932' # How to put in pi properly
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
    expression = '-influx - outflux'
    pp_names = 'influx outflux'
    outputs = csv_data
  []

  [time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = flux_difference
    time_integration_scheme = trapezoidal-rule
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


  ### Miscellaneous

  [assumed_gas_total_mass]
    type = ParsedPostprocessor
    expression = '69.7055*t^0.6808' # Power model linear least squares fit of SRNL data
    use_t = True
    outputs = csv_data
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
