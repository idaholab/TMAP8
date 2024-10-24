# Validation problem #2c from TMAP4/TMAP7 V&V document
# Test Cell Release Experiment based on
# D. F. Holland and R. A. Jalbert, "A Model for Tritium Concentration Following Tritium
# Release into a Test Cell and Subsequent Operation of an Atmospheric Cleanup Systen,"
# Proceedings, Eleventh Symposium of Fusion Engineering, Novermber 18-22, 1985,. Austin,
# TX, Vol I, pp. 638-43, IEEE Cat. No. CH2251-7.

# Note that the approach to model this validation case is different in TMAP4 and TMAP7.

[Mesh]
  [base_mesh]
    type = GeneratedMeshGenerator
    dim = 1
    nx = ${fparse mesh_num_nodes_paint + 2}
    xmax = ${length_domain}
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
  # T2 concentration in the enclosure in molecules/microns^3
  [t2_enclosure_concentration]
    block = 1
  []
  # HT concentration in the enclosure in molecules/microns^3
  [ht_enclosure_concentration]
    block = 1
  []
  # HTO concentration in the enclosure in molecules/microns^3
  [hto_enclosure_concentration]
    block = 1
  []
  # H2O concentration in the enclosure in molecules/microns^3
  [h2o_enclosure_concentration]
    block = 1
    initial_condition = ${initial_H2O_concentration}
  []
  # concentration of T2 in the paint in molecules/microns^3
  [t2_paint_concentration]
    block = 0
  []
  # concentration of HT in the paint in molecules/microns^3
  [ht_paint_concentration]
    block = 0
  []
  # concentration of HTO in the paint in molecules/microns^3
  [hto_paint_concentration]
    block = 0
  []
  # concentration of H2O in the paint in molecules/microns^3
  [h2o_paint_concentration]
    block = 0
  []
[]

[AuxVariables]
  # Used to prevent negative concentrations
  [bounds_dummy_t2_paint_concentration]
    order = FIRST
    family = LAGRANGE
  []
  [bounds_dummy_t2_enclosure_concentration]
    order = FIRST
    family = LAGRANGE
  []
  [bounds_dummy_hto_paint_concentration]
    order = FIRST
    family = LAGRANGE
  []
  [bounds_dummy_hto_enclosure_concentration]
    order = FIRST
    family = LAGRANGE
  []
  [bounds_dummy_h2o_paint_concentration]
    order = FIRST
    family = LAGRANGE
  []
  [bounds_dummy_h2o_enclosure_concentration]
    order = FIRST
    family = LAGRANGE
  []
[]

[Bounds]
  # To prevent negative concentrations
  [t2_paint_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_t2_paint_concentration
    bounded_variable = t2_paint_concentration
    bound_type = lower
    bound_value = ${lower_value_threshold}
  []
  [t2_enclosure_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_t2_enclosure_concentration
    bounded_variable = t2_enclosure_concentration
    bound_type = lower
    bound_value = ${lower_value_threshold}
  []
  [hto_paint_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_hto_paint_concentration
    bounded_variable = hto_paint_concentration
    bound_type = lower
    bound_value = ${lower_value_threshold}
  []
  [hto_enclosure_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_hto_enclosure_concentration
    bounded_variable = hto_enclosure_concentration
    bound_type = lower
    bound_value = ${lower_value_threshold}
  []
  [h2o_paint_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_h2o_paint_concentration
    bounded_variable = h2o_paint_concentration
    bound_type = lower
    bound_value = -1e-4
  []
  [h2o_enclosure_concentration_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy_h2o_enclosure_concentration
    bounded_variable = h2o_enclosure_concentration
    bound_type = lower
    bound_value = -1e-4
  []
[]

[Kernels]
  # In the enclosure
  [t2_time_derivative]
    type = TimeDerivative
    variable = t2_enclosure_concentration
    block = 1
  []
  [t2_outflow]
    type = MaskedBodyForce
    variable = t2_enclosure_concentration
    value = '-1'
    mask = t2_enclosure_concentration_outflow
    block = 1
  []
  [t2_diffusion]
    type = MatDiffusion
    variable = t2_enclosure_concentration
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  [ht_time_derivative]
    type = TimeDerivative
    variable = ht_enclosure_concentration
    block = 1
  []
  [ht_outflow]
    type = MaskedBodyForce
    variable = ht_enclosure_concentration
    value = '-1'
    mask = ht_enclosure_concentration_outflow
    block = 1
  []
  [ht_diffusion]
    type = MatDiffusion
    variable = ht_enclosure_concentration
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  [hto_time_derivative]
    type = TimeDerivative
    variable = hto_enclosure_concentration
    block = 1
  []
  [hto_outflow]
    type = MaskedBodyForce
    variable = hto_enclosure_concentration
    value = '-1'
    mask = hto_enclosure_concentration_outflow
    block = 1
  []
  [hto_diffusion]
    type = MatDiffusion
    variable = hto_enclosure_concentration
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []
  [h2o_time_derivative]
    type = TimeDerivative
    variable = h2o_enclosure_concentration
    block = 1
  []
  [h2o_inflow]
    type = MaskedBodyForce
    variable = h2o_enclosure_concentration
    mask = ${inflow_concentration}
    block = 1
  []
  [h2o_outflow]
    type = MaskedBodyForce
    variable = h2o_enclosure_concentration
    value = '-1'
    mask = h2o_enclosure_concentration_outflow
    block = 1
  []
  [h2o_diffusion]
    type = MatDiffusion
    variable = h2o_enclosure_concentration
    block = 1
    diffusivity = ${diffusivity_artificial_enclosure}
  []

  # reaction T2+H2O->HTO+HT
  [reaction_1_t2]
    type = ADMatReactionFlexible
    variable = t2_enclosure_concentration
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_t2
  []
  [reaction_1_h2o]
    type = ADMatReactionFlexible
    variable = h2o_enclosure_concentration
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_t2
  []
  [reaction_1_hto]
    type = ADMatReactionFlexible
    variable = hto_enclosure_concentration
    block = 1
    coeff = 1
    reaction_rate_name = reaction_rate_t2
  []
  [reaction_1_ht]
    type = ADMatReactionFlexible
    variable = ht_enclosure_concentration
    block = 1
    coeff = 1
    reaction_rate_name = reaction_rate_t2
  []
  # reaction HT+H2O->HTO+H2
  [reaction_2_HT]
    type = ADMatReactionFlexible
    variable = ht_enclosure_concentration
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_ht
  []
  [reaction_2_h2o]
    type = ADMatReactionFlexible
    variable = h2o_enclosure_concentration
    block = 1
    coeff = -1
    reaction_rate_name = reaction_rate_ht
  []
  [reaction_2_hto]
    type = ADMatReactionFlexible
    variable = hto_enclosure_concentration
    block = 1
    coeff = 1
    reaction_rate_name = reaction_rate_ht
  []

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
  [ht_paint_time]
    type = TimeDerivative
    variable = ht_paint_concentration
    block = 0
  []
  [ht_paint_diffusion]
    type = MatDiffusion
    variable = ht_paint_concentration
    block = 0
    diffusivity = '${diffusivity_elemental_tritium}'
  []
  [hto_paint_time]
    type = TimeDerivative
    variable = hto_paint_concentration
    block = 0
  []
  [hto_paint_diffusion]
    type = MatDiffusion
    variable = hto_paint_concentration
    block = 0
    diffusivity = '${diffusivity_tritiated_water}'
  []
  [h2o_paint_time]
    type = TimeDerivative
    variable = h2o_paint_concentration
    block = 0
  []
  [h2o_paint_diffusion]
    type = MatDiffusion
    variable = h2o_paint_concentration
    block = 0
    diffusivity = '${diffusivity_tritiated_water}'
  []
[]

[InterfaceKernels]
  # solubility at the surface of the paint
  [t2_solubility]
    type = ADInterfaceSorption
    variable = t2_paint_concentration
    neighbor_var = t2_enclosure_concentration # molecules/microns^3
    unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
    K0 = ${solubility_elemental_tritium}
    Ea = 0
    n_sorption = 1 # Henry's law
    temperature = ${temperature}
    diffusivity = diffusivity_elemental_tritium
    boundary = 'interface'
  []
  [ht_solubility]
    type = ADInterfaceSorption
    variable = ht_paint_concentration
    neighbor_var = ht_enclosure_concentration # molecules/microns^3
    unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
    K0 = ${solubility_elemental_tritium}
    Ea = 0
    n_sorption = 1 # Henry's law
    temperature = ${temperature}
    diffusivity = diffusivity_elemental_tritium
    boundary = 'interface'
  []
  [hto_solubility]
    type = ADInterfaceSorption
    variable = hto_paint_concentration
    neighbor_var = hto_enclosure_concentration # molecules/microns^3
    unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
    K0 = ${solubility_tritiated_water}
    Ea = 0
    n_sorption = 1 # Henry's law
    temperature = ${temperature}
    diffusivity = diffusivity_tritiated_water
    boundary = 'interface'
  []
  [h2o_solubility]
    type = ADInterfaceSorption
    variable = h2o_paint_concentration
    neighbor_var = h2o_enclosure_concentration # molecules/microns^3
    unit_scale_neighbor = ${fparse 1e18/NA} # to convert neighbor concentration to mol/m^3
    K0 = ${solubility_tritiated_water}
    Ea = 0
    n_sorption = 1 # Henry's law
    temperature = ${temperature}
    diffusivity = diffusivity_tritiated_water
    boundary = 'interface'
  []
[]

[Materials]
  [reaction_rate_t2]
    type = ADDerivativeParsedMaterial
    coupled_variables = 't2_enclosure_concentration ht_enclosure_concentration hto_enclosure_concentration'
    expression = '${reaction_rate} * 2 * t2_enclosure_concentration * (2*t2_enclosure_concentration + ht_enclosure_concentration + hto_enclosure_concentration)'
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
  [diffusivity_elemental_tritium_paint]
    type = ADConstantMaterial
    value = ${diffusivity_elemental_tritium}
    property_name = 'diffusivity_elemental_tritium'
    block = 0
  []
  [diffusivity_elemental_tritium_enclosure]
    type = ADConstantMaterial
    value = ${diffusivity_artificial_enclosure}
    property_name = 'diffusivity_elemental_tritium'
    block = 1
  []
  [diffusivity_tritiated_water_paint]
    type = ADConstantMaterial
    value = ${diffusivity_tritiated_water}
    property_name = 'diffusivity_tritiated_water'
    block = 0
  []
  [diffusivity_tritiated_water_enclosure]
    type = ADConstantMaterial
    value = ${diffusivity_artificial_enclosure}
    property_name = 'diffusivity_tritiated_water'
    block = 1
  []

  [t2_enclosure_concentration_outflow]
    type = DerivativeParsedMaterial
    coupled_variables = 't2_enclosure_concentration'
    expression = 't2_enclosure_concentration * ${outflow} / ${volume_enclosure}'
    property_name = 't2_enclosure_concentration_outflow'
    block = 1
  []
  [ht_enclosure_concentration_outflow]
    type = DerivativeParsedMaterial
    coupled_variables = 'ht_enclosure_concentration'
    expression = 'ht_enclosure_concentration * ${outflow} / ${volume_enclosure}'
    property_name = 'ht_enclosure_concentration_outflow'
    block = 1
  []
  [hto_enclosure_concentration_outflow]
    type = DerivativeParsedMaterial
    coupled_variables = 'hto_enclosure_concentration'
    expression = 'hto_enclosure_concentration * ${outflow} / ${volume_enclosure}'
    property_name = 'hto_enclosure_concentration_outflow'
    block = 1
  []
  [h2o_enclosure_concentration_outflow]
    type = DerivativeParsedMaterial
    coupled_variables = 'h2o_enclosure_concentration'
    expression = 'h2o_enclosure_concentration * ${outflow} / ${volume_enclosure}'
    property_name = 'h2o_enclosure_concentration_outflow'
    block = 1
  []
[]

[Postprocessors]
  # Pressures in enclosure
  [t2_enclosure_edge_concentration] # (molecules/mum^3)
    type = PointValue
    point = '${length_domain} 0 0' # on the far side of the enclosure
    variable = t2_enclosure_concentration
    execute_on = 'initial timestep_end'
  []
  [ht_enclosure_edge_concentration] # (molecules/mum^3)
    type = PointValue
    point = '${length_domain} 0 0' # on the far side of the enclosure
    variable = ht_enclosure_concentration
    execute_on = 'initial timestep_end'
  []
  [hto_enclosure_edge_concentration] # (molecules/mum^3)
    type = PointValue
    point = '${length_domain} 0 0' # on the far side of the enclosure
    variable = hto_enclosure_concentration
    execute_on = 'initial timestep_end'
  []
  [h2o_enclosure_edge_concentration] # (molecules/mum^3)
    type = PointValue
    point = '${length_domain} 0 0' # on the far side of the enclosure
    variable = h2o_enclosure_concentration
    execute_on = 'initial timestep_end'
  []

  # Inventory in enclosure
  [t2_enclosure_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = t2_enclosure_concentration
    execute_on = 'initial timestep_end'
    block = 1
  []
  [ht_enclosure_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = ht_enclosure_concentration
    execute_on = 'initial timestep_end'
    block = 1
  []
  [hto_enclosure_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = hto_enclosure_concentration
    execute_on = 'initial timestep_end'
    block = 1
  []
  [h2o_enclosure_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = h2o_enclosure_concentration
    execute_on = 'initial timestep_end'
    block = 1
  []

  # Inventory in paint
  [t2_paint_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = t2_paint_concentration
    execute_on = 'initial timestep_end'
    block = 0
  []
  [ht_paint_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = ht_paint_concentration
    execute_on = 'initial timestep_end'
    block = 0
  []
  [hto_paint_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = hto_paint_concentration
    execute_on = 'initial timestep_end'
    block = 0
  []
  [h2o_paint_inventory] # (molecules/mum^2)
    type = ElementIntegralVariablePostprocessor
    variable = h2o_paint_concentration
    execute_on = 'initial timestep_end'
    block = 0
  []

  [tritium_total_inventory]
    type = LinearCombinationPostprocessor
    pp_names = 't2_enclosure_inventory ht_enclosure_inventory hto_enclosure_inventory t2_paint_inventory ht_paint_inventory hto_paint_inventory'
    pp_coefs = '2                      1                      1                       2                  1                  1'
    execute_on = 'initial timestep_end'
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
  solve_type = NEWTON
  scheme = 'bdf2'

  petsc_options_iname = '-pc_type -sub_pc_type -snes_type'
  petsc_options_value = 'asm      lu           vinewtonrsls' # This petsc option helps prevent negative concentrations with bounds'

  nl_rel_tol = 1.e-10
  automatic_scaling = true
  compute_scaling_once = false

  end_time = ${time_end}
  dtmax = ${dtmax}
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
  perf_graph = true
  [csv]
    type = CSV
    execute_on = 'initial timestep_end'
  []
[]
