# Author: Evan Butterworth
# Contact: Evan.Butterworth@inl.gov

# Geometry
inner_radius = '${units 1.415 in -> mm}' # Radius of canister containing gases
steel_thickness = '${units 0.085 in -> mm}' # Thickness of steel enclosure
# total_radius = '${units ${fparse inner_radius + steel_thickness} mm}'
height = '${units 7.06 in -> mm}'
gas_volume = '${units ${fparse pi*inner_radius^2*height} mm^3}'

# Misc
temperature = '${units 313.15 K}' # INL Report: Section 2.3
ideal_gas_constant = '${units 8.31446261815324 J/K/mol -> J/K/mumol}' # Note: InterfaceSorption uses in J/K/mol value from PhysicalConstants namespace
diffuisivity_H2_in_He = '${units 2.7 cm^2/s -> mm^2/day}'

# Sandia Technical Reference: Hydrogen Diffusivity & Solubility in 304 Stainless Steel
diffusivity_preexponential_factor_in_steel = '${units 0.20e-6 m^2/s -> mm^2/day}'
diffusivity_activation_energy_in_steel = '${units 49.3 kJ/mol -> J/mumol}'
diffusivity_H_in_steel = '${units ${fparse diffusivity_preexponential_factor_in_steel * exp(-diffusivity_activation_energy_in_steel/(ideal_gas_constant*temperature))} mm^2/day}'
solubility_preexponential_factor_in_steel = '${units 266e-6 mumol/mm^3/Pa}' # Actual units are mumol/mm^3/sqrt(Pa) due to Sievert's law in EquilibriumBC
solubility_activation_energy_in_steel = '${units 6.86 kJ/mol -> J/mol}' # J/mol needed since InterfaceSorption uses ideal_gas_constant in J/K/mol from PhysicalConstants namespace

# Numerics
num_elements_steel = 1500
# num_elements_gas = '${fparse int(num_elements_steel * inner_radius / steel_thickness)}' # Gives roughly same element length in two blocks
num_elements_gas = 250
endtime = '${units 0.25 year -> day}'
dt_start = '${units 300 s -> day}'
dt_max = '${units 7 day}'
dt_min = '${units 1 s -> day}'

[Mesh]
  coord_type = 'RZ' # Axisymmetric coordinates
  rz_coord_axis = Y # Specifies X axis is radial direction and Y axis is axis of symmetry
  [cannister_radius]
    type = CartesianMeshGenerator
    dim = 1
    dx = '${inner_radius} ${steel_thickness}'
    ix = '${num_elements_gas} ${num_elements_steel}'
    subdomain_id = '0 1'
  []
  [interface_left]
    type = SideSetsBetweenSubdomainsGenerator
    input = cannister_radius
    primary_block = '0' # gas chamber
    paired_block = '1' # steel wall
    new_boundary = 'interface_gas_to_steel'
  []
  [interface_right]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface_left
    primary_block = '1' # steel wall
    paired_block = '0' # gas chamber
    new_boundary = 'interface_steel_to_gas'
  []
[]

[Variables]
  [H_mobile_gas] # Mobile H_2 gas inside canister
    block = '0'
  []
  [H_mobile_steel] # Mobile H atoms within steel
    block = '1'
  []
[]

[AuxVariables]
  [T] #Temperature
    initial_condition = ${temperature}
  []
[]

[Kernels]
  [gas_mobile_time]
    type = ADTimeDerivative
    variable = H_mobile_gas
    block = 0
  []
  [gas_mobile_diff]
    type = ADMatDiffusion
    variable = H_mobile_gas
    diffusivity = '${diffuisivity_H2_in_He}'
    block = 0
  []
  [gas_source]
    type = ADBodyForce
    variable = H_mobile_gas
    block = 0
    function = gas_generation_rhs_fun
  []

  [steel_mobile_time]
    type = ADTimeDerivative
    variable = H_mobile_steel
    block = 1
  []
  [steel_mobile_diff]
    type = ADMatDiffusion
    variable = H_mobile_steel
    diffusivity = '${diffusivity_H_in_steel}'
    block = 1
  []
[]

[AuxKernels]
  [constant_temperature]
    type = ConstantAux
    variable = T
    value = '${temperature}'
  []
[]

[InterfaceKernels]
  [Equilibrium_gas_to_steel]
    type = ADInterfaceSorption
    K0 = '${fparse 2 * solubility_preexponential_factor_in_steel}' # Convert solubility to represent H atoms
    boundary = interface_steel_to_gas
    Ea = '${solubility_activation_energy_in_steel}'
    neighbor_var = H_mobile_gas
    variable = H_mobile_steel
    temperature = T
    n_sorption = 0.5 # Sieverts' Law
    diffusivity = '${diffusivity_H_in_steel}'
    unit_scale_neighbor = 1e3 # Unit corrections for C_s = K*\sqrt{unit_scale_neighbor*C_g*R*T}
  []
[]

[BCs]
  [steel_air_boundary] # Boundary of steel and outside environment
    type = DirichletBC
    boundary = '1'
    value = 0
    variable = H_mobile_steel
  []
[]

[Functions]
  [gas_generation_fun] # Power model linear least sqaures fit to mumol vs days (assuming 124.7 Gy/min dosage rate from SRNL report)
    type = ParsedFunction
    expression = '69.7055*t^0.6808'
  []

  [gas_generation_rhs_fun] # Take time derivative of gas_generation_fun and divide by volume to get appropriate units for source term in concentration per unit time (mumol/mm^3/day)
    type = ParsedFunction
    expression = '69.7055*0.6808*t^(0.6808-1)/${gas_volume}'
  []
[]

[Postprocessors]

  # Conservation of mass: Total mass in domain

  [circle_concentration_gas_molecular] # Axisymmetric: 2D Integral of inner circle Cross section
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_gas
    block = '0'
    outputs = csv
  []

  [circle_concentration_gas]
    type = ScalePostprocessor
    value = circle_concentration_gas_molecular
    scaling_factor = 2 # Count H atoms
    outputs = csv
  []

  [annulus_concentration_steel] # Axisymmetric: 2D integral of annulus
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_steel
    block = '1'
    outputs = csv
  []

  [circle_concentration]
    type = SumPostprocessor
    values = 'circle_concentration_gas annulus_concentration_steel'
    outputs = csv
  []

  [cylinder_total_mass_steel]
    type = ScalePostprocessor
    value = annulus_concentration_steel
    scaling_factor = '${height}'
    outputs = csv
  []

  [cylinder_total_mass_gas]
    type = ScalePostprocessor
    value = circle_concentration_gas
    scaling_factor = '${height}'
    outputs = csv
  []

  [cylinder_total_mass]
    type = SumPostprocessor
    values = 'cylinder_total_mass_gas cylinder_total_mass_steel'
    outputs = csv
  []

  # Conservation of mass: Accumulated flux

  [circle_influx] # Influx at the center of canister should be zero
    type = ADSideDiffusiveFluxIntegral
    boundary = '0'
    variable = H_mobile_gas
    diffusivity = ${diffuisivity_H2_in_He}
    outputs = csv
  []

  [circle_outflux] # outflux on outside edges of steel.
    type = ADSideDiffusiveFluxIntegral
    boundary = '1'
    variable = H_mobile_steel
    diffusivity = ${diffusivity_H_in_steel}
    outputs = csv
  []

  [circle_flux_difference]
    type = ParsedPostprocessor
    # expression = 'circle_outflux - 2*circle_influx' # Account for atomic hydrogen
    expression = '-2*circle_influx-circle_outflux' # Change from Carson
    pp_names = 'circle_influx circle_outflux'
    outputs = csv
  []

  [circle_time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = circle_flux_difference
    time_integration_scheme = trapezoidal-rule
    outputs = csv
  []

  [cylinder_time_integrated_flux]
    type = ScalePostprocessor
    value = circle_time_integrated_flux
    scaling_factor = ${height}
    outputs = csv
  []

  # Conservation of mass: H generation source term

  [cylinder_total_generation]
    type = FunctionValuePostprocessor
    function = gas_generation_fun
    scale_factor = 2 # Count H atoms
    outputs = csv
  []

  # Pressure calculation

  [Mobile_gas_interface]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_gas
    outputs = csv
  []

  [H_partial_pressure_interface] # Use ideal gas law to approximate pressure
    type = ScalePostprocessor
    value = Mobile_gas_interface
    scaling_factor = '${fparse ideal_gas_constant * temperature*1e9}' # J/mm^3 = 1e9 J/m^3 = 1e9 Pa
    outputs = csv
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
  line_search = NONE
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-07
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
  csv = true
  exodus = true
  file_base = 'gas_steel_out'
[]
