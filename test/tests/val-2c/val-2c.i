# Validation problem #2c from TMAP4/TMAP7 V&V document
# Test Cell Release Experiment based on
# D. F. Holland and R. A. Jalbert, "A Model for Tritium Concentration Following Tritium
# Release into a Test Cell and Subsequent Operation of an Atmospheric Cleanup Systen,"
# Proceedings, Eleventh Symposium of Fusion Engineering, Novermber 18-22, 1985,. Austin,
# TX, Vol I, pp. 638-43, IEEE Cat. No. CH2251-7.

# Note that the approach to model this validation case is different in TMAP4 and TMAP7.
# This input file reproduces the results shown in TMAP4.

# Physical Constants (from PhysicalConstant.h)
kb = ${units 1.380649e-23 J/K} # Boltzmann constant from PhysicalConstants
# R = ${units 8.31446261815324 J/mol/K} # Gas constant from PhysicalConstants
NA = ${units 6.02214076e23 at/mol} # Avogadro's number from PhysicalConstants

Curie = ${units 3.7e10 1/s} # desintegrations/s - activitiy of one curie
decay_rate_tritium = ${units 1.78199e-9 1/s/at} # desintegrations/s/atoms
conversion_Ci_atom = ${units ${fparse decay_rate_tritium / Curie} 1/at} # 1 Ci = ~4.81e-20 tritium at



# Data used in TMAP4/TMAP7 case
temperature = ${units 303 K}
paint_thickness = ${units 0.16 mm -> mum}
mesh_num_nodes_paint = 12 # impose by manual mesh
mesh_node_size_paint = ${fparse paint_thickness/mesh_num_nodes_paint}
volume_enclosure = ${units 0.96 m^3 -> mum^3}
#### surface_area = ${units 5.6 m^2 -> mum^2}

# Ci_per_gram_tritium = 9650 # Ci/g - from OSEH (Report). Radionuclide Safety Data Sheets. University of Michigan.
# tritium_mass = 3.01602932243 # u - from https://link.aps.org/doi/10.1103/PhysRevLett.114.013003
# # @article{PhysRevLett.114.013003,
# #   title = {Atomic Masses of Tritium and Helium-3},
# #   author = {Myers, E. G. and Wagner, A. and Kracke, H. and Wesson, B. A.},
# #   journal = {Phys. Rev. Lett.},
# #   volume = {114},
# #   issue = {1},
# #   pages = {013003},
# #   numpages = {5},
# #   year = {2015},
# #   month = {Jan},
# #   publisher = {American Physical Society},
# #   doi = {10.1103/PhysRevLett.114.013003},
# #   url = {https://link.aps.org/doi/10.1103/PhysRevLett.114.013003}
# # }
# conversion_u_g = 1.66053906892e-24 # g/u
# conversion_atoms_Ci = ${fparse 1 / tritium_mass / conversion_u_g / Ci_per_gram_tritium} # 2.0691312e+19 # atoms/Ci, i.e., number of atoms representing one Ci, used as conversion.


concentration_to_pressure_conversion_factor = '${units ${fparse kb * temperature} Pa*m^3 -> Pa*mum^3}' # J = Pa*m^3


diffusivity_elemental_tritium = ${units 4.0e-12 m^2/s -> mum^2/s}
diffusivity_artificial_enclosure = ${fparse diffusivity_elemental_tritium*10}
# diffusivity_tritiated_water = ${units 1.0e-14 m^2/s -> mum^2/s}

reaction_rate = '${units ${fparse 2.0e-10*conversion_Ci_atom} m^3/at/s -> mum^3/at/s}' # ~9.62e-30 m^3/at/s, close to the 1.0e-29 m3/atoms/s in TMAP4 ////// that seems OK, but I want to change it in my simulations to double check.
solubility_elemental_tritium = '${units ${fparse 4.0e19} 1/m^3/Pa -> 1/mum^3/Pa}' # molecules/microns^3/Pa = molecules*s^2/m^2/kg ////////// check starting units - might be mol/m^3/Pa, but the paper is unclear also, chcek molecule vs atoms.
# solubility_tritiated_water = '${units ${fparse 6.0e24} 1/m^3/Pa -> 1/mum^3/Pa}' # molecules/microns^3/Pa = molecules*s^2/m^2/kg ////////// check starting units - might be mol/m^3/Pa, but the paper is unclear

# below is actually in molecules, not atoms
initial_T2_inventory = ${units ${fparse 10 / 2 / conversion_Ci_atom} at} # (equivalent to 10 Ci) - the 1/2 is to account for 2 tritium atoms per molecules, both contributing to activity
initial_T2_concentration = ${units ${fparse initial_T2_inventory / volume_enclosure} at/mum^3}
initial_T2_pressure = ${units ${fparse initial_T2_concentration * concentration_to_pressure_conversion_factor} Pa} # ~0.453 Pa (different from 0.434 in TMAP4 because of volume_enclosure = 0.96 m^3 != 1 m^3)
initial_H2O_pressure = ${fparse 714} # Pa ######## VERY WRONG FOR NOW FOR TESTING PURPOSES714 # ///////////

### purge_gas_H2O_concentration = 714 # ///////////

time_step = ${units 60 s}
time_end = ${units ${fparse 180000} s}



# [Mesh]
#   type = GeneratedMesh
#   dim = 1
#   nx = 2
#   xmax = 1
# []

# [Mesh]
#   [cmg]
#     type = CartesianMeshGenerator
#     dim = 1

#     dx = '${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint} ${mesh_node_size_paint}
#           ${mesh_node_size_paint}'

#     subdomain_id = '0 0 0 0 0 0 0 0 0 0 0 0
#                     1 '

#   []
#   [interface]
#     type = SideSetsBetweenSubdomainsGenerator
#     input = cmg
#     primary_block = '0' # paint
#     paired_block = '1' # enclosure
#     new_boundary = 'interface'
#   []
#   [interface_other_side]
#     type = SideSetsBetweenSubdomainsGenerator
#     input = interface
#     primary_block = '1' # enclosure
#     paired_block = '0' # paint
#     new_boundary = 'interface_other'
#   []
# []

[Mesh]
  [base_mesh]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${fparse mesh_num_nodes_paint + 2}
    xmax = ${fparse paint_thickness + 2*mesh_node_size_paint}
  []
  [subdomain_id]
    input = base_mesh
    type = SubdomainPerElementGenerator
    subdomain_ids = '0 0 0 0 0 0 0 0 0 0 0 0 1 1'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = subdomain_id
    primary_block = '0' # paint
    paired_block = '1' # enclosure
    new_boundary = 'interface'
  []
  [interface_other_side]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface
    primary_block = '1' # enclosure
    paired_block = '0' # paint
    new_boundary = 'interface_other'
  []
[]


[Variables]
  # T2 partial pressure in the enclosure in Pa
  [t2_enclosure_pressure]
    block = 1
    initial_condition = ${initial_T2_pressure}
  []
  # HT partial pressure in the enclosure in Pa
  [ht_enclosure_pressure]
    block = 1
  []
  # HTO partial pressure in the enclosure in Pa
  [hto_enclosure_pressure]
    block = 1
  []
  # H2O partial pressure in the enclosure in Pa
  [h2o_enclosure_pressure]
    block = 1
    initial_condition = ${initial_H2O_pressure}
  []
  # concentration of T2 in the paint in atoms/microns^3
  [t2_paint_concentration]
    block = 0
  []
  # # concentration of HT in the paint in atoms/microns^3
  # [ht_paint_concentration]
  #   block = 0
  # []
  # # concentration of HTO in the paint in atoms/microns^3
  # [hto_paint_concentration]
  #   block = 0
  # []
  # # concentration of H2O in the paint in atoms/microns^3
  # [h2o_paint_concentration]
  #   block = 0
  # []
[]

[AuxVariables]
  # T2 concentration in the enclosure in atoms/microns^3
  [t2_enclosure_concentration]
    block = 1
  []
  # HT concentration in the enclosure in atoms/microns^3
  [ht_enclosure_concentration]
    block = 1
  []
  # HTO concentration in the enclosure in atoms/microns^3
  [hto_enclosure_concentration]
    block = 1
  []
  # H2O concentration in the enclosure in atoms/microns^3
  [h2o_enclosure_concentration]
    block = 1
  []
[]

[Kernels]
  # In the enclosure
  [t2_time_derivative]
    type = TimeDerivative
    variable = t2_enclosure_pressure
    block = 1
  []
  [t2_diffusion]
    type = MatDiffusion
    variable = t2_enclosure_pressure
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  [ht_time_derivative]
    type = TimeDerivative
    variable = ht_enclosure_pressure
    block = 1
  []
  [ht_diffusion]
    type = MatDiffusion
    variable = ht_enclosure_pressure
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  [hto_time_derivative]
    type = TimeDerivative
    variable = hto_enclosure_pressure
    block = 1
  []
  [hto_diffusion]
    type = MatDiffusion
    variable = hto_enclosure_pressure
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  [h2o_time_derivative]
    type = TimeDerivative
    variable = h2o_enclosure_pressure
    block = 1
  []
  [h2o_diffusion]
    type = MatDiffusion
    variable = h2o_enclosure_pressure
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  # reaction T2+H2O->HTO+HT
  [reaction_1_t2]
    type = ADMatReactionFlexible
    variable = t2_enclosure_pressure
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_t2
  []
  [reaction_1_h2o]
    type = ADMatReactionFlexible
    variable = h2o_enclosure_pressure
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_t2
  []
  [reaction_1_hto]
    type = ADMatReactionFlexible
    variable = hto_enclosure_pressure
    block = 1
    coeff = 1
    reaction_rate_name = reaction_rate_t2
  []
  [reaction_1_ht]
    type = ADMatReactionFlexible
    variable = ht_enclosure_pressure
    block = 1
    coeff = 1
    reaction_rate_name = reaction_rate_t2
  []
  # reaction HT+H2O->HTO+H2
  [reaction_2_HT]
    type = ADMatReactionFlexible
    variable = ht_enclosure_pressure
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_ht
  []
  [reaction_2_h2o]
    type = ADMatReactionFlexible
    variable = h2o_enclosure_pressure
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_ht
  []
  [reaction_2_hto]
    type = ADMatReactionFlexible
    variable = hto_enclosure_pressure
    block = 1
    coeff = 1
    reaction_rate_name = reaction_rate_ht
  []


  # Injection of purge gas /////////////////////////////
  # extraction for analysis ////////////////////////////


  # In the paint
  [t2_paint_time]
    type = TimeDerivative
    variable = t2_paint_concentration
    block = 0
  []
  [t2_paint_diffusion]
    type = MatDiffusion
    variable = t2_paint_concentration
    block = 0
    diffusivity = '${diffusivity_elemental_tritium}'
  []
  # [ht_paint_time]
  #   type = TimeDerivative
  #   variable = ht_paint_concentration
  #   block = 0
  # []
  # [ht_paint_diffusion]
  #   type = MatDiffusion
  #   variable = ht_paint_concentration
  #   block = 0
  #   diffusivity = '${diffusivity_elemental_tritium}'
  # []
  # [hto_paint_time]
  #   type = TimeDerivative
  #   variable = hto_paint_concentration
  #   block = 0
  # []
  # [hto_paint_diffusion]
  #   type = MatDiffusion
  #   variable = hto_paint_concentration
  #   block = 0
  #   diffusivity = '${diffusivity_tritiated_water}'
  # []
  # [h2o_paint_time]
  #   type = TimeDerivative
  #   variable = h2o_paint_concentration
  #   block = 0
  # []
  # [h2o_paint_diffusion]
  #   type = MatDiffusion
  #   variable = h2o_paint_concentration
  #   block = 0
  #   diffusivity = '${diffusivity_tritiated_water}'
  # []
[]

[AuxKernels]
  [t2_enclosure_concentration]
    type = ParsedAux
    variable = 't2_enclosure_concentration'
    coupled_variables = 't2_enclosure_pressure'
    expression = 't2_enclosure_pressure / ${concentration_to_pressure_conversion_factor}'
    block = 1
  []
  [ht_enclosure_concentration]
    type = ParsedAux
    variable = 'ht_enclosure_concentration'
    coupled_variables = 'ht_enclosure_pressure'
    expression = 'ht_enclosure_pressure / ${concentration_to_pressure_conversion_factor}'
    block = 1
  []
  [hto_enclosure_concentration]
    type = ParsedAux
    variable = 'hto_enclosure_concentration'
    coupled_variables = 'hto_enclosure_pressure'
    expression = 'hto_enclosure_pressure / ${concentration_to_pressure_conversion_factor}'
    block = 1
  []
  [h2o_enclosure_concentration]
    type = ParsedAux
    variable = 'h2o_enclosure_concentration'
    coupled_variables = 'h2o_enclosure_pressure'
    expression = 'h2o_enclosure_pressure / ${concentration_to_pressure_conversion_factor}'
    block = 1
  []
[]

[InterfaceKernels]
  # solubility at the surface of the paint
  [t2_solubility]
    type = ADInterfaceSorption
    variable = t2_paint_concentration
    neighbor_var = t2_enclosure_concentration # atoms/microns^3
    unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
    K0 = ${solubility_elemental_tritium}
    Ea = 0
    n_sorption = 1 # Henry's law
    temperature = ${temperature}
    diffusivity = ${diffusivity_elemental_tritium}
    # use_flux_penalty = true
    # sorption_penalty = 8 #2.5 # default = 1
    boundary = 'interface'
  []
#   [ht_solubility]
#     type = ADInterfaceSorption
#     variable = ht_paint_concentration
#     neighbor_var = ht_enclosure_concentration # atoms/microns^3
#     unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
#     K0 = ${solubility_elemental_tritium}
#     Ea = 0
#     n_sorption = 1 # Henry's law
#     temperature = ${temperature}
#     diffusivity = ${diffusivity_elemental_tritium}
#     sorption_penalty = 1 # default
#     boundary = 'interface'
#   []
#   [hto_solubility]
#     type = ADInterfaceSorption
#     variable = hto_paint_concentration
#     neighbor_var = hto_enclosure_concentration # atoms/microns^3
#     unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
#     K0 = ${solubility_tritiated_water}
#     Ea = 0
#     n_sorption = 1 # Henry's law
#     temperature = ${temperature}
#     diffusivity = ${diffusivity_tritiated_water}
#     sorption_penalty = 1 # default
#     boundary = 'interface'
#   []
#   [h2o_solubility]
#     type = ADInterfaceSorption
#     variable = h2o_paint_concentration
#     neighbor_var = h2o_enclosure_concentration # atoms/microns^3
#     unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
#     K0 = ${solubility_tritiated_water}
#     Ea = 0
#     n_sorption = 1 # Henry's law
#     temperature = ${temperature}
#     diffusivity = ${diffusivity_tritiated_water}
#     sorption_penalty = 1 # default
#     boundary = 'interface'
#   []
[]

[Materials]
  [reaction_rate_t2]
    type = ADDerivativeParsedMaterial
    coupled_variables = 't2_enclosure_concentration ht_enclosure_concentration hto_enclosure_concentration'
    expression = '2 * ${reaction_rate} * t2_enclosure_concentration * (2*t2_enclosure_concentration + ht_enclosure_concentration + hto_enclosure_concentration)'
    property_name = reaction_rate_t2
    block = 1
  []
  [reaction_rate_ht]
    type = ADDerivativeParsedMaterial
    coupled_variables = 't2_enclosure_concentration ht_enclosure_concentration hto_enclosure_concentration'
    expression = '${reaction_rate} * ht_enclosure_concentration * (2*t2_enclosure_concentration + ht_enclosure_concentration + hto_enclosure_concentration)'
    property_name = reaction_rate_ht
    block = 1
  []
  # [reaction_rate_t2]  ###########################
  #   type = ADDerivativeParsedMaterial
  #   coupled_variables = 't2_enclosure_concentration'
  #   expression = '2 * ${reaction_rate} * t2_enclosure_concentration * (2*t2_enclosure_concentration + 0)'
  #   property_name = reaction_rate_t2
  #   block = 1
  # []
  [blank_material]
    type = ConstantMaterial
    value = 0
    property_name = constant
    block = 0
  []
[]

[BCs]
  # No flux toward the foil behind the paint, and no flux outside the enclosure
  # The inflow and outflow in the enclosure are modeled as volumetric sources
  # [right]
  #   type = NeumannBC
  #   value = 0
  #   variable = 'all'
  #   boundary = 'right left'
  # []
[]

[Postprocessors]
  # Pressures in enclosure
  [t2_enclosure_pressure] # (Pa)
    type = PointValue
    point = '${fparse paint_thickness} 0 0' # on the far side of the enclosure ##################################
    variable = t2_enclosure_pressure
  []
  [ht_enclosure_pressure] # (Pa)
  type = PointValue
  point = '${fparse paint_thickness} 0 0' # on the far side of the enclosure ##################################
    variable = ht_enclosure_pressure
  []
  [hto_enclosure_pressure] # (Pa)
  type = PointValue
  point = '${fparse paint_thickness} 0 0' # on the far side of the enclosure ##################################
    variable = hto_enclosure_pressure
  []
  [h2o_enclosure_pressure] # (Pa)
  type = PointValue
  point = '${fparse paint_thickness} 0 0' # on the far side of the enclosure ##################################
    variable = h2o_enclosure_pressure
  []

  # Inventory in enclosure
  [t2_enclosure_inventory] # (atoms/m^2)
    type = ElementIntegralVariablePostprocessor
    variable = t2_enclosure_concentration
    block = 1
  []
  [ht_enclosure_inventory] # (atoms/m^2)
    type = ElementIntegralVariablePostprocessor
    variable = ht_enclosure_concentration
    block = 1
  []
  [hto_enclosure_inventory] # (atoms/m^2)
    type = ElementIntegralVariablePostprocessor
    variable = hto_enclosure_concentration
    block = 1
  []
  [h2o_enclosure_inventory] # (atoms/m^2)
    type = ElementIntegralVariablePostprocessor
    variable = h2o_enclosure_concentration
    block = 1
  []

  # Inventory in paint
  [t2_paint_inventory] # (atoms/m^2)
    type = ElementIntegralVariablePostprocessor
    variable = t2_paint_concentration
    block = 0
  []
  # [ht_paint_inventory] # (atoms/m^2)
  #   type = ElementIntegralVariablePostprocessor
  #   variable = ht_paint_concentration
  #   block = 0
  # []
  # [hto_paint_inventory] # (atoms/m^2)
  #   type = ElementIntegralVariablePostprocessor
  #   variable = hto_paint_concentration
  #   block = 0
  # []
  # [h2o_paint_inventory] # (atoms/m^2)
  #   type = ElementIntegralVariablePostprocessor
  #   variable = h2o_paint_concentration
  #   block = 0
  # []

  [tritium_total_inventory]
    type = LinearCombinationPostprocessor
    pp_names = 't2_paint_inventory t2_enclosure_inventory ht_enclosure_inventory hto_enclosure_inventory'
    pp_coefs = '2                  2                      1                      1'
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON #PJFNK
  scheme = 'bdf2'
  # automatic_scaling = true
  dtmin = 1e-1
  # l_max_its = 15
  # nl_abs_tol = 1e-40 ###########
  nl_rel_tol = 1e-7 ###########
  # l_max_its = 10000
  # l_abs_tol = 1e-50
  # l_tol = 1e-05
  # petsc_options = '-snes_converged_reason -ksp_monitor_true_residual'
  # petsc_options_iname = '-pc_type -mat_mffd_err'
  # petsc_options_value = 'lu       1e-5'
  # petsc_options = '-snes_converged_reason'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  # line_search = 'bt'
  # line_search = 'none'

  end_time = ${time_end}
  nl_max_its = 16
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = ${time_step}
    optimal_iterations = 12
    iteration_window = 1
    growth_factor = 1.1
    cutback_factor = 0.9
  []

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



# //////////////////////////////////////////////////////////////////////////////////

# [ScalarKernels]
#   [time]
#     type = ODETimeDerivative
#     variable = v
#   []
#   [flux_sink]
#     type = EnclosureSinkScalarKernel
#     variable = v
#     flux = scaled_flux_surface_left
#     surface_area = '${surface_area}'
#     volume = '${volume_enclosure}'
#     concentration_to_pressure_conversion_factor = '${concentration_to_pressure_conversion_factor}'
#   []
# []

