endtime = 199060.0
scale = 1e20

[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 2
    dx = '1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9 1e-9
          1e-9 1e-8 1e-7 1e-6 1e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5 1.888e-5'
    dy = '0.2e-4'
    subdomain_id = '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1'
  []
  [subdomain_id]
    input = cmg
    type = SubdomainBoundingBoxGenerator
    bottom_left = '18e-9  0 0'
    top_right = '1.99929e-4  0 0' # sum of all dx's
    block_id = 1
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = subdomain_id
    primary_block = '0' #BeO
    paired_block = '1' # Be
    new_boundary = 'interface'
  []
[]

[Variables]
  [conc_Be]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 1
  []
  [conc_BeO]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
    block = 0
  []
[]

[AuxVariables]
  [enclosure_pressure]
    family = SCALAR
    initial_condition = 13300.0
  []
  [temp]
    initial_condition = 300
  []
  [flux_x]
    order = FIRST
    family = MONOMIAL
  []
[]

[Kernels]
  [diff_Be]
    type = ADMatDiffusion
    variable = conc_Be
    diffusivity = diffusivity_Be
    block = 1
  []
  [diff_BeO]
    type = ADMatDiffusion
    variable = conc_BeO
    diffusivity = diffusivity_BeO
    block = 0
  []
  [time_diff_Be]
    type = TimeDerivative
    variable = conc_Be
    block = 1
  []
  [time_diff_BeO]
    type = TimeDerivative
    variable = conc_BeO
    block = 0
  []
[]
[InterfaceKernels]
  [tied]
    type = ADPenaltyInterfaceDiffusion
    variable = conc_BeO
    neighbor_var = conc_Be
    penalty = 1e-6
    jump_prop_name = solubility_ratio
    boundary = 'interface'
  []
[]

[AuxScalarKernels]
  [enclosure_pressure_aux]
    type = FunctionScalarAux
    variable = enclosure_pressure
    function = enclosure_pressure_func
  []
[]

[AuxKernels]
  [temp_aux]
    type = FunctionAux
    variable = temp
    function = temp_bc_func
    execute_on = 'INITIAL LINEAR'
  []
  [flux_x_Be]
    type = DiffusionFluxAux
    diffusivity = diffusivity_Be
    variable = flux_x
    diffusion_variable = conc_Be
    component = x
    block = 1
  []
  [flux_x_BeO]
    type = DiffusionFluxAux
    diffusivity = diffusivity_BeO
    variable = flux_x
    diffusion_variable = conc_BeO
    component = x
    block = 0
  []
[]

[BCs]
  [left_flux]
    type = EquilibriumBC
    Ko = 5.0
    activation_energy = -77966.2
    boundary = left
    enclosure_scalar_var = enclosure_pressure
    temp = temp
    variable = conc_BeO
    p = 0.5
  []
  [right_flux]
    type = ADNeumannBC
    boundary = right
    variable = conc_Be
    value = 0
  []
[]

[Functions]
  [temp_bc_func]
    type = ParsedFunction
    value = 'if(t<180000.0, 773.0, if(t<183600, 773.0-((1-exp(-(t-180000)/2700))*642.3), 300.0+3.0*(t-183600)/60))'
  []

  [diffusivity_BeO_func]
    type = ParsedFunction
    vars = 'T'
    vals = 'temp_bc_func'
    value = 'if(t<183600, 1.40e-4*exp(-24408/T), 7e-5*exp(-24408/T))'
  []

  [diffusivity_Be_func]
    type = ParsedFunction
    vars = 'T'
    vals = 'temp_bc_func'
    value = '8.0e-9*exp(-4220/T)'
  []

  [enclosure_pressure_func]
    type = ParsedFunction
    value = 'if(t<180000.0, 13300.0, if(t<183600.0, 1e-6, 0.001))'
  []

  [solubility_BeO_func]
    type = ParsedFunction
    vars = 'T'
    vals = 'temp_bc_func'
    value = '5.00e20 * exp(9377.7/T)/${scale}'
  []

  [solubility_Be_func]
    type = ParsedFunction
    vars = 'T'
    vals = 'temp_bc_func'
    value = '7.156e27 * exp(-11606/T)/${scale}'
  []
[]

[Materials]
  [diff_solu]
    type = ADGenericFunctionMaterial
    prop_names = 'diffusivity_BeO diffusivity_Be solubility_Be solubility_BeO'
    prop_values = 'diffusivity_BeO_func diffusivity_Be_func solubility_Be_func solubility_BeO_func'
    outputs = all
  []

  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_Be diffusivity_BeO'
    reg_props_out = 'diffusivity_Be_nonAD diffusivity_BeO_nonAD'
  []

  [interface_jump]
    type = SolubilityRatioMaterial
    solubility_primary = solubility_BeO
    solubility_secondary = solubility_Be
    boundary = interface
    concentration_primary = conc_BeO
    concentration_secondary = conc_Be
    output_properties = 'solubility_ratio solubility_ratio_primary solubility_ratio_secondary'
  []
[]

[Postprocessors]
  [avg_flux_left]
    type = SideDiffusiveFluxAverage
    variable = conc_BeO
    boundary = left
    diffusivity = diffusivity_BeO_nonAD
  []
  [solubility_ratio]
    type = ElementalVariableValue
    variable = solubility_ratio
    elementid = 17
  []
  [solubility_ratio_primary]
    type = ElementalVariableValue
    variable = solubility_ratio_primary
    elementid = 17
  []
  [solubility_ratio_secondary]
    type = ElementalVariableValue
    variable = solubility_ratio_secondary
    elementid = 17
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
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         101   preonly   ilu      1'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  l_tol = 1e-4
  dtmax = 600
  end_time = ${endtime}
  automatic_scaling = true
  compute_scaling_once = false

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 30
    iteration_window = 9
    growth_factor = 2.0
    cutback_factor = 0.5
  []
[]

[Outputs]
  # execute_on = FINAL
  # exodus = true
  csv = true
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
