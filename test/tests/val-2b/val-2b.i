endtime = 197860
scale = 1e20

[Mesh]
  [cmg]
    type = CartesianMeshGenerator
    dim = 1
    # #     0    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17
    # dx = '3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9 3e-9
    #       1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5 1e-5'
    # #     18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35

    #     0    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16   17
    dx = '0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9
          0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9 0.5e-9
        0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5
        0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5 0.5e-5'
    #     18   19   20   21   22   23   24   25   26   27   28   29   30   31   32   33   34   35   36   37

    subdomain_id = '0 0 0 0 0 0 0 0 0 0 0  0  0  0  0  0  0  0
                    0 0 0 0 0 0 0 0 0 0 0  0  0  0  0  0  0  0
                    1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1
                    1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1'
    #               18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37'

    #                 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1'
    # #               18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = cmg
    primary_block = '0' #BeO
    paired_block = '1' # Be
    new_boundary = 'interface'
  []
  [interface_other_side]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface
    primary_block = '1' #BeO
    paired_block = '0' # Be
    new_boundary = 'interface_other'
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
    penalty = 0.15
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
    # value = 'if(t<180000.0, 773.0, if(t<183600, 773.0-((1-exp(-(t-180000)/2700))*642.3), 300.0+3.0*(t-183600)/60))'
    value = 'if(t<180000.0, 773.0, if(t<182400.0, 773.0-((1-exp(-(t-180000)/2700))*475), 300+0.05*(t-182400)))'
  []

  [diffusivity_BeO_func]
    type = ParsedFunction
    vars = 'T'
    vals = 'temp_bc_func'
    # value = 'if(t<183600, 1.40e-4*exp(-24408/T), 7e-5*exp(-24408/T))'
    # value = 'if(t<182400, 1.40e-4*exp(-24408/T), 7e-5*exp(-24408/T))' # Paul's
    value = 'if(t<182400, 1.40e-4*exp(-24408/T), 7e-5*exp(-27000/T))' # TMAP7
  []

  [diffusivity_Be_func]
    type = ParsedFunction
    vars = 'T'
    vals = 'temp_bc_func'
    value = '8.0e-9*exp(-4220/T)'
  []

  [enclosure_pressure_func]
    type = ParsedFunction
    # value = 'if(t<180000.0, 13300.0, if(t<183600.0, 1e-6, 0.001))'
    value = 'if(t<180015.0, 13300.000001, if(t<182400.0, 1e-6, 0.001))' # Paul's

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

  [max_time_step_size_func]
    type = ParsedFunction
    expression = 'if(t < 170000, 10000, 100)'
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
  []
[]

[Postprocessors]
  [avg_flux_left]
    type = SideDiffusiveFluxAverage
    variable = conc_BeO
    boundary = left
    diffusivity = diffusivity_BeO_nonAD
  []
  [Temp]
    type = ElementAverageValue
    block = 1
    variable = temp
  []
  [diff_Be]
    type = ElementAverageValue
    block = 1
    variable = diffusivity_Be
  []
  [diff_BeO]
    type = ElementAverageValue
    block = 0
    variable = diffusivity_BeO
  []
  [sol_Be]
    type = ElementAverageValue
    block = 1
    variable = solubility_Be
  []
  [sol_BeO]
    type = ElementAverageValue
    block = 0
    variable = solubility_BeO
  []
  [gold_solubility_ratio]
    type = ParsedPostprocessor
    function = 'sol_BeO / sol_Be'
    pp_names = 'sol_BeO sol_Be'
  []
  [BeO_interface]
    type = SideAverageValue
    boundary = interface
    variable = conc_BeO
  []
  [Be_interface]
    type = SideAverageValue
    boundary = interface_other
    variable = conc_Be
  []
  [variable_ratio]
    type = ParsedPostprocessor
    function = 'BeO_interface / Be_interface'
    pp_names = 'BeO_interface Be_interface'
  []
  [dt]
    type = TimestepSize
  []
  [h0]
    type = AverageElementSize
    block = 0
  []
  [h1]
    type = AverageElementSize
    block = 1
  []
  [Fo0]
    type = ParsedPostprocessor
    function = 'diff_BeO * dt / h0^2'
    pp_names = 'dt h0 diff_BeO'
  []
  [Fo1]
    type = ParsedPostprocessor
    function = 'diff_Be * dt / h1^2'
    pp_names = 'dt h1 diff_Be'
  []
  [max_time_step_size_pp]
    type = FunctionValuePostprocessor
    function = max_time_step_size_func
    execute_on = 'INITIAL TIMESTEP_END'
    outputs = none
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
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-7
  l_tol = 1e-4
  end_time = ${endtime}
  automatic_scaling = true
  line_search = 'none'

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 4
    growth_factor = 1.1
    cutback_factor = 0.5

    timestep_limiting_postprocessor = max_time_step_size_pp
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  # execute_on = FINAL
  # exodus = true
  checkpoint = true
  csv = true
  hide = 'BeO_interface Be_interface sol_Be sol_BeO diff_BeO diff_Be dt h0 h1'
  [exodus]
    type = Exodus
    output_material_properties = true
  []
[]
