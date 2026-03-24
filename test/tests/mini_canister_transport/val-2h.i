# Validation problem to address hydrogen concentration, trapping, and diffusion through a 304 stainless steel mini canister
# Report: https://inldigitallibrary.inl.gov/sites/sti/sti/Sort_129733.pdf

# Geometry
inner_radius = '${units 1.415 in -> mm}' # Radius of canister containing gases
steel_thickness = '${units 0.085 in -> mm}' # Thickness of steel enclosure
total_radius = '${fparse inner_radius + steel_thickness}'
# height = '${units 7.06 in -> m}' # Confused on unit conversion here and effect on initial concentration

# Ambient Physical & Chemical Parameters
temperature = '${units 313.15 K}' # mild temp
initial_pressure_gas = '${units 2.4 psi -> Pa}' # Anywhere from 1-10% of 24 psi
# initial_pressure_air = '${units 0.051 Pa}' # Dalton's Law: Total Pressure of Atmosphere times Volume Percentage
initial_pressure_air = '${units 0.0 psi -> Pa}'
ideal_gas_constant = '${units 8.31446261815324 J/K/mol}'

# Parameters related to Gas in Canister
diffusivity_H_in_gas = '${units 2.7 cm^2/s -> mm^2/day}' # Table 1 https://www.sciencedirect.com/science/article/pii/S1540748902801675

# Initial Concentrations
# initial_concentration_gas = '${units 10 mol/mm^3}'
# Do I need to input volume here?
# volume_gas = '${fparse pi *inner_radius^2 * height}' ### CHECK THIS AGAIN!!!! DO UNITS WORK OUT? ###
# volume_steel = '${fparse pi * total_radius^2 * height - volume_gas}'
initial_concentration_gas = '${units ${fparse initial_pressure_gas/(ideal_gas_constant*temperature)} mol/m^3 -> mol/mm^3}' # P = C_gRT from interface kernel
initial_concentration_steel = '${units ${fparse initial_pressure_air/(ideal_gas_constant*temperature)} mol/m^3 -> mol/mm^3}'
# initial_concentration_gas = '${units ${fparse volume_gas*initial_pressure_gas/(ideal_gas_constant*temperature)} mol/m^3 -> mol/mm^3}' # P = C_gRT from interface kernel
# initial_concentration_steel = '${units ${fparse volume_steel*initial_pressure_air/(ideal_gas_constant*temperature)} mol/m^3 -> mol/mm^3}'

# diffusivity_H_in_steel = '${units 2.86e-13 m^2/s -> mm^2/s}' # https://pdf.sciencedirectassets.com/271609/1-s2.0-S0925838800X00473/1-s2.0-S0925838896028460/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEPj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJFMEMCH06lR8h%2BQeV%2F%2BWPSlTbpcAZM6nj0BCSME5n0nB3sYV8CIAx6yxTZ%2BJIpkpARYB7mbXS8CPq4eje8aIuikdKGreuDKrsFCJD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQBRoMMDU5MDAzNTQ2ODY1IgwwlLoItAwYQdJrUpMqjwUanStcho50OBvN4WhTU8b3xmuKS%2F3ER%2FwNgfvbKAi9UjXUNGdFWoc%2BcL%2B4bsml3oz1MwH%2BJP9H37JjQJbGyLj2VrKK4k0xhtPu9tE7kFOepedJvcjPmCe3PLBiFJPSI9a2SsLpq0Y%2Bd88w7DIB33OTYTvmVM8pYYrxWq20wVgo3RdIThsjHwxm%2FkDlYwSJpxPe1HcJVEdnRPofYhK4LEJKnjsGyUIFj4tABaAEjYKfg1d0aFgUrev%2BBKJq5rZbt39xr9YifnqRw%2FLQ%2BbIL4E0Cx3dcF%2BszcPkqAb%2FYRn2qBT51vrA444fXv295JpnMjk%2FYJlCfOdq8OrAClOfFt4oVb62bKHnqLK2GOfgXkG%2B1GW051vYghKXzf76SNNvEkcMOaBvJwqPVHk1U2XTA%2FwWli4m1ZwNbxAz%2BMQKdbATLecRit4N07B2eWUb%2FMT8seOcjR0vT2Ih3v6guOzHjmjgvuk61gsjFhhs2j5HqgsjbpTnHoEVuI2kSPGDoesiLjpSRsok4Rtyy%2FfcLy8H46PVs%2FfmEeQnYBicQ63JhAMZ1C6ghuGUGK0XCNs0o5decDxZgVxptfxRc2Kw9%2BZ63M8AQCpkGfHc%2FB3cz%2BL42jNz1GswcZvMKMB6lwvbJCkpa7NHbJViD7CYco3dMzq4xjyNlX92Tzr9r%2ByNpvTXv82kmPVVZkLh5Yh49%2BUxH9RZOOJgj6vdKmCwnQD6ak0Isxl%2BmXanjPXT0pvQLJs5jX%2F5X9z7u2274CLuesgeIOGxeHQJ4j9l7AxgnrDd%2F16wR76WS%2F50o1RZ6RClx9dSlNbK7icZjcODW8X6WATAyiXxeStLbX3jfm4Zh%2FkvbQaw6pQ%2Fjx7EHTOaPqYfDzX4VBrjWMOG2j8cGOrMBWMyoEJbJ9Aq255MIA6N9B%2BgVguUseD%2BbGbnCrjE1M1eBA0Dk9pTkaRKI9t5z0RIO8ajvPj%2F%2B3ia9Y52uwwH2WrV7dDfT8Xg90legndHUEuTBAKyq0sw%2FIm6nXA9bv8OXA3pq%2FY35%2Bwa%2FxK%2Bkp4zIOk7XOUU9Kku8vWN%2BxiMJmppSFPo2jcHkTM2GfAfEBFQ5RySxhPgqL0Pkn1RFzDogFsa396kO5KaUWRE1dZIiVn4kWwE%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20251006T155752Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYSO4WZR6Z%2F20251006%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=b344f187b722db2da048edb3013670503007a603e4fc950277ac4b2fb309062b&hash=d09ced7b2aa14f89e8b753abc7a3c3143071f7d4774644da6e7f73ca1e99fcd2&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S0925838896028460&tid=spdf-801f8509-398d-47ac-8572-298a70b38a7c&sid=48da626760d6e841fa58b19662bd1d4a88c7gxrqa&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&rh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=10145a5d075951075550&rr=98a65b63fb2da3b6&cc=us

# Sandia Technical Report Table 2.1 last row #https://www.sandia.gov/app/uploads/sites/158/2021/12/1500TechRef_ferriticSS.pdf gives diffusivity, solubility, permeability

# Hydrogen Diffusivity in Steel
diffusivity_preexponential_factor_in_steel = '${units 0.20e-6 m^2/s -> mm^2/day}'
diffusivity_activation_energy_in_steel = '${units 49.3 kJ/mol -> J/mol}'
diffusivity_H_in_steel = '${fparse diffusivity_preexponential_factor_in_steel * exp(-diffusivity_activation_energy_in_steel/(ideal_gas_constant*temperature))}'

# Hydrogen Solubility in Steel
solubility_preexponential_factor_in_steel = '${units 2.66e5 mol/m^3/Pa -> mol/mm^3/Pa}' #https://www.sandia.gov/app/uploads/sites/158/2021/12/1500TechRef_ferriticSS.pdf
solubility_activation_energy_in_steel = '${units 6.86 kJ/mol -> J/mol}'
# solubility_H_in_steel = '${fparse solubility_preexponential_factor_in_steel * exp(-solubility_activation_energy_in_steel/(ideal_gas_constant*temperature))}'

# Hydrogen Permability in Steel
# permeability_preexponential_factor_in_steel = '${units 53.5e-6 mol/m/s/MPa^(1/2) -> mol/mm/day/Pa}'
# permeability_activation_energy_in_steel = '${units 56.1 kJ/mol -> J/mol}'
# permeability_H_in_steel = '${fparse permeability_preexponential_factor_in_steel * exp(-permeability_activation_energy_in_steel/(ideal_gas_constant*temperature))}'

# Mesh
num_intervals_steel = 300
num_intervals_gas = '${fparse int(num_intervals_steel * inner_radius / steel_thickness)}' # How to round? Gives roughly same element length in two blocks

# Numerics
dt_max = '${units 0.5 day}'
dt_min = '${units 1e-6 day}'
endtime = '${units 1 year -> day}'
dt_start = '${units 0.125 day}' # 3 hours does not give negative concentration for current input parameters
# dt_second = '${units 1 h -> day}'
# ramp_time_concentration = '${units 14 day}' # How long the interior gas BC takes to reach its true value
# ramp_time_pressure = '${units  s -> day}'

[Mesh]
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
  [H_mobile_gas]
    block = '0'
    initial_condition = '${initial_concentration_gas}'
  []
  [H_mobile_steel]
    block = '1'
    initial_condition = '${initial_concentration_steel}'
  []
[]

[AuxVariables]
  [H_partial_pressure_air]
    initial_condition = '${initial_pressure_air}'
  []
[]

# [AuxKernels]
#   [ramping_pressure] # Pressure term starts at zero and ramps up over time
#     type = FunctionAux
#     function = pressure_ramp_air_function
#     variable = H_partial_pressure_air
#   []
# []

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
    K0 = '${solubility_preexponential_factor_in_steel}'
    n_sorption = 0.5 # Sievert
    temperature = '${temperature}'
    Ea = '${solubility_activation_energy_in_steel}'
    neighbor_var = H_mobile_gas
    variable = H_mobile_steel
    boundary = interface_steel_to_gas
    diffusivity = '${diffusivity_H_in_steel}'
    # sorption_penalty = 1
    # flux_penalty = 1
    # use_flux_penalty = false
  []
[]

[BCs]
  # [center_of_canister]
  #   type = ADFunctionDirichletBC
  #   boundary = '0'
  #   variable = H_mobile_gas
  #   function = concentration_ramp_gas_function
  #   # function = '${initial_concentration_gas}'
  # []

  [steel_air_boundary] # Boundary of outside edge of steel and open air
    type = EquilibriumBC
    Ko = '${solubility_preexponential_factor_in_steel}' # solubility or pre-exponential-factor??
    boundary = '1'
    activation_energy = '${solubility_activation_energy_in_steel}'
    enclosure_var = H_partial_pressure_air
    variable = H_mobile_steel
    temperature = '${temperature}'
    p = 0.5 #Sievert's Law
  []

  # [steel_air_boundary] # Sometimes Dirichlet boundary is not strongly enforced even with 0 pressure
  #   type = ADDirichletBC
  #   boundary = '1'
  #   value = 0
  #   variable = H_mobile_steel
  # []
[]

[Functions]
  [diffusion_length_steel_fun]
    type = ParsedFunction
    expression = '${inner_radius} + sqrt(${diffusivity_H_in_steel}*t)'
  []
#   [concentration_ramp_gas_function]
#     type = TimeRampFunction
#     final_value = '${initial_concentration_gas}'
#     initial_value = 0
#     ramp_duration = '${ramp_time_concentration}'
#   []
#   # [pressure_ramp_air_function]
#   #   type = TimeRampFunction
#   #   final_value = '${initial_pressure_air}'
#   #   initial_value = 0
#   #   ramp_duration = '${ramp_time_pressure}' # 10 minutes
#   # []
#   # [dt_func]
#   #   type = ParsedFunction
#   #   expression = 'if(t<${dt_start}, ${dt_start},${dt_second})'
#   # []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[VectorPostprocessors] # Interpolation based so boundaries not well measured
  [line_plot_gas]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${inner_radius} 0 0'
    num_points = '${fparse num_intervals_gas + 1}' # n intervals gives n+1 nodes
    sort_by = x
    execute_on = 'TIMESTEP_END'
    variable = 'H_mobile_gas'
  []
  [line_plot_steel]
    type = LineValueSampler
    start_point = '${inner_radius} 0 0'
    end_point = '${total_radius} 0 0'
    num_points = '${fparse num_intervals_steel + 1}' # n intervals gives n+1 nodes plus double node at interface
    sort_by = x
    variable = 'H_mobile_steel'
  []
[]

[Postprocessors]

  ### GENERAL ###

  [time]
    type = TimePostprocessor
    outputs = csv_data
  []

  [min_steel] # Rough Check for Negative Concentrations
    type = ElementExtremeFunctorValue
    functor = H_mobile_steel
    block = 1
    value_type = min
  []

  ### POINTS OF INTEREST ###

  [Mobile_gas_interface] # Needed to replace malfunctioning vpp
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_gas
    # outputs = csv_data
  []
  [Mobile_steel_interface]
    type = PointValue
    point = '${inner_radius} 0 0'
    variable = H_mobile_steel
    # outputs = csv_data
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
    # outputs = csv_data
  []

  ### CONSERVATION OF MASS ###

  [influx]
    type = SideDiffusiveFluxIntegral
    boundary = '0'
    variable = H_mobile_gas
    diffusivity = ${diffusivity_H_in_gas}
    outputs = none
  []
  [outflux]
    type = SideDiffusiveFluxIntegral
    boundary = '1'
    variable = H_mobile_steel
    diffusivity = ${diffusivity_H_in_steel}
    outputs = csv_data
  []
  [mass_in_gas] # Are we properly accounting for the mass in the interface?
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_gas
    block = 0
    outputs = none
  []
  [mass_in_steel]
    type = ElementIntegralVariablePostprocessor
    variable = H_mobile_steel
    block = 1
    outputs = none
  []
  [total_mass]
    type = SumPostprocessor
    values = 'mass_in_gas mass_in_steel'
    outputs = csv_data
  []
  [flux_difference]
    type = ParsedPostprocessor
    expression = 'outflux - influx'
    pp_names = 'influx outflux'
    outputs = none
  []
  [time_integrated_flux]
    type = TimeIntegratedPostprocessor
    value = flux_difference
    outputs = csv_data
  []

  ### DIFFUSION LENGTH CHECK ###

  [exact_diffusion_length_steel]
    type = FunctionValuePostprocessor
    function = diffusion_length_steel_fun
    outputs = csv_data
  []

[]

[Executioner]
  type = Transient
  scheme = bdf2
  dtmax = '${dt_max}'
  dtmin = '${dt_min}'
  solve_type = Newton
  automatic_scaling = true ### IMPORTANT ###
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_type'
  # petsc_options_value = 'hypre boomeramg gmres'
  # petsc_options = '-pc_svd_monitor'
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'svd'
  # petsc_options_iname = '-snes_linesearch_damping' # add -snes_type if bounds system active
  # petsc_options_value = '0.5' # add  vinewtonrsls if bounds system active
  line_search = NONE
  nl_max_its = 50
  # nl_abs_tol = 1e-50
  # nl_rel_tol = 1e-08
  end_time = ${endtime}
  # steady_state_detection = true
  [TimeSteppers]
    # [Constantdt]
    #   type = ConstantDT
    #   dt ='${dt_start}'
    # []
    # [functiondt]
    #   type = FunctionDT
    #   function = dt_func
    # []
    # [AB2]
    #   type = AB2PredictorCorrector
    #   dt = '${dt_start}'
    #   e_max = 10
    #   e_tol = 1
    # []
    [Iteration_time]
      type = IterationAdaptiveDT
      dt = ${dt_start}
      optimal_iterations = 5
      growth_factor = 1.1
      cutback_factor_at_failure = .9
    []
  []
[]

[Outputs]
  print_linear_residuals = true
  # perf_graph = true
  # exodus = true
  [csv_data]
    type = CSV
    file_base = 'csv_data/verification'
    execute_on = 'TIMESTEP_END'
  []
[]

[Debug]
  show_var_residual_norms = true
[]
