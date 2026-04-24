### This input file models the transport of H2 through only the steel wall of the mini_canister,
### using EquilibriumBC to model the interface between the gas chamber and steel

# Model parameters
!include mini_canister.params
# Geometry
total_radius = '${units ${fparse inner_radius + steel_thickness} mm}'
# Pressure implementation: constant_pressure | time_ramp_pressure | SRNL_pressure_data_fun
estimated_pressure_gas = '${units ${fparse 24*0.10} psi -> Pa}' # For constant or time_ramp pressure. % estimation of partial pressure of H_2 with HE backfill to 24 psi
pressure_function = 'constant_pressure'

# Shared objects between two models
!include mini_canister_base.i

[Mesh]
  coord_type = 'RZ' # Axisymmetric coordinates
  rz_coord_axis = Y # Specifies X axis is radial direction and Y axis is axis of symmetry
  [steel]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${num_elements_steel}
    xmin = '${inner_radius}'
    xmax = '${total_radius}'
    subdomain_ids = '1'
  []
[]

[AuxVariables]
  [H_partial_pressure_gas] # Partial pressure of H_2 in internal gas chamber in Pa
  []
  [H_mobile_steel_derivative] # dC_s/dx
    family = MONOMIAL # Need element rather than nodal family to define gradient at a node
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

[AuxKernels]
  [pressure_aux]
    type = FunctionAux
    function = ${pressure_function}
    variable = H_partial_pressure_gas
    boundary = '0'
  []

  [concentration_gradient_left_boundary] # dC_s/dx @ x = inner_radius
    type = DiffusionFluxAux
    component = x
    diffusion_variable = H_mobile_steel
    diffusivity = negative_unity
    variable = H_mobile_steel_derivative
    boundary = '0'
  []
[]

[BCs]
  [gas_steel_boundary] # Species equilibrium condition between internal gas and steel wall
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}'
    Ko_scaling_factor = 2 # Convert solubility to represent H atoms
    boundary = '0'
    activation_energy = '${solubility_activation_energy_in_steel}'
    enclosure_var = H_partial_pressure_gas
    variable = H_mobile_steel
    temperature = T
    p = 0.5 # Sieverts' Law
  []
[]

[Functions]
  [constant_pressure] # Assumed
    type = ConstantFunction
    value = '${estimated_pressure_gas}'
  []
  [time_ramp_pressure]
    type = TimeRampFunction
    initial_value = 0
    final_value = '${estimated_pressure_gas}'
    ramp_duration = '${units 3 h -> day}'
  []
  [SRNL_pressure_data_fun] # Power model linear least sqaures fit to Pa vs days
    type = ParsedFunction
    expression = '376.7588*t^0.6177'
  []
[]

[Postprocessors]

  # Diffusion front verification

  [exact_diffusion_length]   # Analytical Diffusion length (time-independent BC required for this to be correct)
    type = ParsedPostprocessor
    expression = 'sqrt(pi*D*t)'
    constant_names = 'D pi'
    constant_expressions = '${diffusivity_H_in_steel} 3.1415926535897932'
    use_t = true
    outputs = csv
  []

  [gradient_left_boundary]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_steel_derivative
    outputs = none
  []

  [interface_concentration]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_steel
    outputs = none
  []

  [simulated_diffusion_length] # x-intercept of tangent line at interface
    type = ParsedPostprocessor
    expression = '-interface_concentration/gradient_left_boundary'
    constant_expressions = ${inner_radius}
    constant_names = interface_location
    pp_names = 'interface_concentration gradient_left_boundary'
    outputs = csv
  []

  # Conservation of mass: Accumulated flux

  [interface_influx] # Influx at interface
    type = ADSideDiffusiveFluxIntegral
    boundary = '0'
    variable = H_mobile_steel
    diffusivity = ${diffusivity_H_in_steel}
    outputs = none
  []

  [annulus_flux_difference]
    type = ParsedPostprocessor
    expression = '-interface_influx - outer_edge_outflux' # negative sign on influx to account for outward normal vector direction
    pp_names = 'interface_influx outer_edge_outflux'
    outputs = none
  []

  [annulus_time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = annulus_flux_difference
    time_integration_scheme = trapezoidal-rule
    outputs = none
  []

  [annular_cylinder_time_integrated_flux]
    type = ScalePostprocessor
    value = annulus_time_integrated_flux
    scaling_factor = ${height}
    outputs = csv
  []
[]

[Executioner]
  solve_type = LINEAR # Direct solve of linear system by LU factorization
[]

[Outputs]
  file_base = 'steel_only_out'
[]
