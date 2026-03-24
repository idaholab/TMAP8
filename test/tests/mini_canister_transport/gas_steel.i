# Validation problem to address hydrogen concentration, trapping, and diffusion through a 304 stainless steel mini canister
# Reports:
# https://inldigitallibrary.inl.gov/sites/sti/sti/Sort_129733.pdf
# https://www.osti.gov/biblio/2477665

# Geometry
inner_radius = '${units 1.415 in -> mm}' # Radius of canister containing gases
steel_thickness = '${units 0.085 in -> mm}' # Thickness of steel enclosure
total_radius = '${units ${fparse inner_radius + steel_thickness} mm}'
height = '${units 7.06 in -> mm}'
# gas_volume_meters = '${units ${fparse pi*inner_radius^2*height} mm^3 -> m^3}' # CAREFUL IF USED ELSEWHERE. SHOULD BE mm^3
gas_volume = '${units ${fparse pi*inner_radius^2*height} mm^3}'

# Ambient Physical & Chemical Parameters
temperature = '${units 313.15 K}' # mild temp
initial_pressure_air = '${units 0.051 Pa}' # Hydrogen in atmosphere is negligible?
# initial_pressure_air = '${units 0 psi -> Pa}'
# estimated_pressure_gas = '${units ${fparse 24*0.00175} psi -> Pa}' # Anywhere from 1-10% of 24 psi
ideal_gas_constant = '${units 8.31446261815324 J/K/mol -> J/K/mumol}' # Not input directly into BC or interface

# Initial Concentrations
initial_concentration_steel = '${units 0 mumol/mm^3}'
# initial_concentration_steel = '${units ${fparse initial_pressure_air/(ideal_gas_constant*temperature)} mumol/m^3 -> mumol/mm^3}'
initial_concentration_gas = '${units 0 mumol/mm^3}'
# initial_concentration_gas = '${units ${fparse estimated_pressure_gas/(ideal_gas_constant*temperature)} mumol/m^3 -> mumol/mm^3}'

# Parameters related to Gas in Canister
diffusivity_H_in_gas = '${units 2.7 cm^2/s -> mm^2/day}' # Table 1 https://www.sciencedirect.com/science/article/pii/S1540748902801675

# Hydrogen Diffusivity in 304 stainless Steel at roughly room temperature and ambient pressure (approx 1.20e-15 m^2/s)
diffusivity_preexponential_factor_in_steel = '${units 0.20e-6 m^2/s -> mm^2/day}'
diffusivity_activation_energy_in_steel = '${units 49.3 kJ/mol -> J/mumol}'
diffusivity_H_in_steel = '${units ${fparse diffusivity_preexponential_factor_in_steel * exp(-diffusivity_activation_energy_in_steel/(ideal_gas_constant*temperature))} mm^2/day}'
# Alternative from another paper
# diffusivity_H_in_steel = '${units 2.86e-13 m^2/s -> mm^2/day}' # https://pdf.sciencedirectassets.com/271609/1-s2.0-S0925838800X00473/1-s2.0-S0925838896028460/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEPj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJFMEMCH06lR8h%2BQeV%2F%2BWPSlTbpcAZM6nj0BCSME5n0nB3sYV8CIAx6yxTZ%2BJIpkpARYB7mbXS8CPq4eje8aIuikdKGreuDKrsFCJD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQBRoMMDU5MDAzNTQ2ODY1IgwwlLoItAwYQdJrUpMqjwUanStcho50OBvN4WhTU8b3xmuKS%2F3ER%2FwNgfvbKAi9UjXUNGdFWoc%2BcL%2B4bsml3oz1MwH%2BJP9H37JjQJbGyLj2VrKK4k0xhtPu9tE7kFOepedJvcjPmCe3PLBiFJPSI9a2SsLpq0Y%2Bd88w7DIB33OTYTvmVM8pYYrxWq20wVgo3RdIThsjHwxm%2FkDlYwSJpxPe1HcJVEdnRPofYhK4LEJKnjsGyUIFj4tABaAEjYKfg1d0aFgUrev%2BBKJq5rZbt39xr9YifnqRw%2FLQ%2BbIL4E0Cx3dcF%2BszcPkqAb%2FYRn2qBT51vrA444fXv295JpnMjk%2FYJlCfOdq8OrAClOfFt4oVb62bKHnqLK2GOfgXkG%2B1GW051vYghKXzf76SNNvEkcMOaBvJwqPVHk1U2XTA%2FwWli4m1ZwNbxAz%2BMQKdbATLecRit4N07B2eWUb%2FMT8seOcjR0vT2Ih3v6guOzHjmjgvuk61gsjFhhs2j5HqgsjbpTnHoEVuI2kSPGDoesiLjpSRsok4Rtyy%2FfcLy8H46PVs%2FfmEeQnYBicQ63JhAMZ1C6ghuGUGK0XCNs0o5decDxZgVxptfxRc2Kw9%2BZ63M8AQCpkGfHc%2FB3cz%2BL42jNz1GswcZvMKMB6lwvbJCkpa7NHbJViD7CYco3dMzq4xjyNlX92Tzr9r%2ByNpvTXv82kmPVVZkLh5Yh49%2BUxH9RZOOJgj6vdKmCwnQD6ak0Isxl%2BmXanjPXT0pvQLJs5jX%2F5X9z7u2274CLuesgeIOGxeHQJ4j9l7AxgnrDd%2F16wR76WS%2F50o1RZ6RClx9dSlNbK7icZjcODW8X6WATAyiXxeStLbX3jfm4Zh%2FkvbQaw6pQ%2Fjx7EHTOaPqYfDzX4VBrjWMOG2j8cGOrMBWMyoEJbJ9Aq255MIA6N9B%2BgVguUseD%2BbGbnCrjE1M1eBA0Dk9pTkaRKI9t5z0RIO8ajvPj%2F%2B3ia9Y52uwwH2WrV7dDfT8Xg90legndHUEuTBAKyq0sw%2FIm6nXA9bv8OXA3pq%2FY35%2Bwa%2FxK%2Bkp4zIOk7XOUU9Kku8vWN%2BxiMJmppSFPo2jcHkTM2GfAfEBFQ5RySxhPgqL0Pkn1RFzDogFsa396kO5KaUWRE1dZIiVn4kWwE%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20251006T155752Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYSO4WZR6Z%2F20251006%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=b344f187b722db2da048edb3013670503007a603e4fc950277ac4b2fb309062b&hash=d09ced7b2aa14f89e8b753abc7a3c3143071f7d4774644da6e7f73ca1e99fcd2&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S0925838896028460&tid=spdf-801f8509-398d-47ac-8572-298a70b38a7c&sid=48da626760d6e841fa58b19662bd1d4a88c7gxrqa&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&rh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=10145a5d075951075550&rr=98a65b63fb2da3b6&cc=us

# Hydrogen Solubility in Steel
# solubility_preexponential_factor_in_steel = '${units 266e-3 mol/m^3/Pa -> mumol/mm^3/Pa}' #sqrt Pa used in BC due to sievert's law
solubility_preexponential_factor_in_steel = '${units 266e-6 mumol/mm^3/Pa}' #sqrt Pa used in BC due to sievert's law
solubility_activation_energy_in_steel = '${units 6.86 kJ/mol -> J/mol}' # Leave as mol to cancel out with ideal gas constant
# solubility_H_in_steel = '${fparse solubility_preexponential_factor_in_steel * exp(-solubility_activation_energy_in_steel/(ideal_gas_constant*temperature))}'

# Mesh
num_intervals_steel = 5000
num_intervals_gas = '${fparse int(num_intervals_steel * inner_radius / steel_thickness)}' # Gives roughly same element length in two blocks

# Numerics
dt_max = '${units 7 day}'
dt_min = '${units 1 s -> day}'
endtime = '${units 10 year -> day}'
# endtime = '${units 0.25 year -> day}'
# dt_start = '${units 0.125 day -> day}'
# dt_start = '${units 300 s -> day}' # nonlinear source functions need smaller timestep for solver to converge

[Mesh]

  coord_type = 'RZ' # Specify 2D axisymmetric coordinates.
  rz_coord_axis = Y # Specifies X is radial direction and Y is axial coordinate

  [total_length]
    type = CartesianMeshGenerator
    dim = 1
    show_info = true
    dx = '${inner_radius} ${steel_thickness}'
    ix = '${num_intervals_gas} ${num_intervals_steel}'
    subdomain_id = '0 1'
  []
  [interface_left]
    type = SideSetsBetweenSubdomainsGenerator
    input = total_length
    primary_block = '0' # gas
    paired_block = '1' # steel
    new_boundary = 'interface_gas_to_steel'
  []
  [interface_right]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface_left
    primary_block = '1' # steel
    paired_block = '0' # gas
    new_boundary = 'interface_steel_to_gas'
  []
[]

[Variables]
  [H_mobile_gas] # Molecular mobile H_2 gas inside canister
    block = '0'
    initial_condition = '${initial_concentration_gas}'
  []
  [H_mobile_steel] # Atomic mobile H within steel
    block = '1'
    initial_condition = '${initial_concentration_steel}'
  []
[]

[AuxVariables]
  [H_partial_pressure_air] # Need this for EquilibriumBC even though it is constant
    order = First
    family = SCALAR
    initial_condition = '${initial_pressure_air}'
    outputs = none
  []
[]

[Kernels]
  [gas_mobile_time]
    type = ADTimeDerivative
    variable = H_mobile_gas
    block = 0
  []
  [gas_mobile_diff]
    type = ADMatDiffusion # What is diffusivity of Hydrogen in hydrogen-helium gas mix?
    variable = H_mobile_gas
    diffusivity = '${diffusivity_H_in_gas}'
    block = 0
  []
  [gas_source] ## SRNL data can be used here for crude generation term
    type = ADBodyForce
    variable = H_mobile_gas
    block = 0
    function = gas_generation_rhs_fun  # Function fit of time vs total mass from SRNL data
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

[InterfaceKernels]
  [Equilibrium_gas_to_steel]
    type = ADInterfaceSorption
    K0 = '${fparse 2 * solubility_preexponential_factor_in_steel}'
    n_sorption = 0.5 # Sievert
    temperature = '${temperature}'
    Ea = '${solubility_activation_energy_in_steel}'
    neighbor_var = H_mobile_gas
    variable = H_mobile_steel
    boundary = interface_steel_to_gas
    diffusivity = '${diffusivity_H_in_steel}'
    unit_scale = 1 # correction factor to go from atomic hydrogen to molecular for C_s
    unit_scale_neighbor = 1e3 # Unit corrections for u_s*C_s = K*\sqrt{u_{sn}*C_g*R*T}
    # unit_scale_neighbor = '${fparse ideal_gas_constant * temperature * 1e9}' # Converts C_gas [mumol/mm^3] to P [Pa]: R*T*1e9 = 2.604e6 FROM CLAUDE
    # sorption_penalty = 1e3 # Why do you exist???
  []
[]

[BCs]
  [steel_air_boundary] # Boundary of outside edge of steel and open air
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}'
    Ko_scaling_factor = 2 # Accounting for solubility given for H_2
    boundary = '1'
    activation_energy = '${solubility_activation_energy_in_steel}'
    enclosure_var = H_partial_pressure_air
    variable = H_mobile_steel
    temperature = '${temperature}'
    p = 0.5 #Sievert's Law
  []
[]

[Functions]
  [gas_generation_fun] # fit for total mass data against time (mumol vs days assuming 124.7 Gy/min dosage rate)
    type = ParsedFunction
    # expression = '(15.2312 * t + 197.2501)' # linear least squares fit
    expression = '69.7055*t^0.6808' # Power model linear least squares fit
    # expression = '1035.1*log(t+29.1299) - 3498.9' # Custom Log fit
    # expression = '143.8883*sqrt(t)' # Square root fit
  []

  [gas_generation_rhs_fun] # Take time derivative and divide by volume to get mumol/mm^3/day
    type = ParsedFunction
    # expression = '15.2312/${gas_volume}' # derivative of linear fit
    expression = '69.7055*0.6808*t^(0.6808-1)/${gas_volume}' # derivative of power fit
    # expression = '1035.1/(t+29.1299)/${gas_volume}'
    # expression = '143.8883/(2*sqrt(t)*${gas_volume})'
  []
[]

[VectorPostprocessors]
  [solution_profile_gas]
    type = NodalValueSampler
    sort_by = x
    variable = H_mobile_gas
    block = '0'
  []
  [solution_profile_steel]
    type = NodalValueSampler
    sort_by = x
    variable = H_mobile_steel
    block = '1'
  []
[]

[Postprocessors]

  ### POINTS OF INTEREST ###

  [Mobile_gas_interface]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_gas
    outputs = csv_data
  []
  [Mobile_steel_interface]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_steel
    outputs = csv_data
  []
  [Mobile_gas_center]
    type = PointValue
    point = '0 0 0'
    variable = H_mobile_gas
    outputs = csv_data
  []
  [Mobile_steel_edge_air]
    type = PointValue
    point = '${total_radius} 0 0'
    variable = H_mobile_steel
    outputs = csv_data
  []

  # Volume Integral Calculations #

  [circle_concentration_gas] # Axisymmetric: 2D Integral of inner circle Cross section
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_gas
    block = '0'
    outputs = csv_data
  []

  [circle_concentration_steel] # Axisymmetric: 2D Integral of outer Ring Cross section
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_steel
    block = '1'
    outputs = csv_data
  []

  [circle_concentration] # Account for Atomic hydrogen
    type = ParsedPostprocessor
    expression = '2*circle_concentration_gas + circle_concentration_steel'
    pp_names = 'circle_concentration_gas circle_concentration_steel'
    outputs = csv_data
  []

  [cylinder_total_mass_steel]
    type = ScalePostprocessor
    value = circle_concentration_steel
    scaling_factor = '${height}'
    outputs = csv_data
  []

  [cylinder_total_mass_gas]
    type = ScalePostprocessor
    value = circle_concentration_gas
    scaling_factor = '${fparse 2*height}'
    outputs = csv_data
  []

  [cylinder_total_mass]
    type = ScalePostprocessor
    value = circle_concentration
    scaling_factor = '${height}'
    outputs = csv_data
  []

  ### Source Term Adjustments ###

  [circle_generation_molecular] # Integral of Source function on circlular cross section giving units of mumol/mm/day
    type = FunctionElementIntegral
    function = gas_generation_rhs_fun
    block = '0'
    outputs = csv_data
  []

  [circle_generation]
    type = ScalePostprocessor
    value = circle_generation_molecular
    scaling_factor = 2
    outputs = csv_data
  []

  [circle_time_integrated_generation] # Integrate in time to get mumol/mm
    type = TimeIntegratedPostprocessor
    value = circle_generation
    outputs = csv_data
  []

  [cylinder_time_integrated_generation] # Extrude source to cylinder giving total mass with units of mumol and account for atomic hydrogen
    type = ScalePostprocessor
    value = circle_time_integrated_generation
    scaling_factor = '${height}'
    outputs = csv_data
  []

  # Flux Calculations

  [circle_influx] # Influx at the center of canister should be zero
    type = ADSideDiffusiveFluxIntegral
    boundary = '0'
    variable = H_mobile_gas
    diffusivity = ${diffusivity_H_in_gas}
    outputs = csv_data
  []

  [circle_outflux] # outflux on outside edges of steel.
    type = ADSideDiffusiveFluxIntegral
    boundary = '1'
    variable = H_mobile_steel
    diffusivity = ${diffusivity_H_in_steel}
    outputs = csv_data
  []

  [circle_flux_difference]
    type = ParsedPostprocessor
    expression = 'circle_outflux - 2*circle_influx' # Account for atomic hydrogen
    pp_names = 'circle_influx circle_outflux'
    outputs = csv_data
  []

  [circle_time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = circle_flux_difference
    outputs = csv_data
  []

  [cylinder_time_integrated_flux]
    type = ScalePostprocessor
    value = circle_time_integrated_flux
    scaling_factor = ${height}
    outputs = csv_data
  []

  ### Miscellaneous ###

  [min_steel] # Rough Check for Negative Concentrations
    type = ADElementExtremeFunctorValue
    functor = H_mobile_steel
    value_type = min
    outputs = csv_data
    block = '1'
  []

  [H_partial_pressure_interface]
    type = ScalePostprocessor
    value = Mobile_gas_interface
    scaling_factor = '${fparse ideal_gas_constant * temperature*1e9}' # Pa # Result gives J/mm^3 = 1e9 J/m^3 = 1e9 Pa
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
  # dt = '${dt_start}'
  solve_type = Newton
  automatic_scaling = true
  # compute_scaling_once = false
  # steady_state_detection = true
  # steady_state_tolerance = 1e-04
  # steady_state_start_time = 365.25
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
  # nl_rel_tol = 1e-08
  # nl_abs_tol = 1e-20
  # nl_rel_tol = 1e-07
  end_time = ${endtime}
  [TimeSteppers]
    [Match] # Take same number of timesteps as steel_only model
      type = ExodusTimeSequenceStepper
      mesh = steel_only_out.e
    []
    # [Adaptive]
    #   type = IterationAdaptiveDT
    #   dt = ${dt_start}
    #   optimal_iterations = 5
    #   growth_factor = 1.1
    #   cutback_factor_at_failure = .9
    # []
  []
[]

[Outputs]
  # print_linear_residuals = true
  # exodus = true
  [csv_data]
    type = CSV
    file_base = 'csv_data/verification_RZ'
    execute_on = 'TIMESTEP_END'
  []
[]

# [Debug]
#   show_var_residual_norms = true
# []
